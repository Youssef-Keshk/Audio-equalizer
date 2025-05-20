% Open a file dialog box to select a .wav audio file
[filename, filepath] = uigetfile('*.wav');
if isequal(filename, 0)
    error('No file selected.');
end
fullFilePath = fullfile(filepath, filename);

% Read the selected audio file
[sig, fs] = audioread(fullFilePath);
% Nyquist check
if fs/2 < 20000
    error('Sampling rate %.1f Hz is too low for filters up to 20kHz. Please use a wave file with fs >= 40kHz.', fs);
else 
    fprintf('\nFilter bands at original rate %.1f Hz:\n', fs);
end

% Calculate length of the audio signal
n = length(sig);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

% Choose mode
mode = input('1: Standard Mode     2: Custom Mode     ');

while ~isnumeric(mode) || ~isscalar(mode) || ~ismember(mode, [1, 2])
    mode = input('Invalid choice. Enter 1 (Standard) or 2 (Custom): ');
end

if (mode == 1) % Standard Mode
    k = 9; % Set 9 bands
    bands = [0.01, 200, 500, 800, 1200, 3000, 6000, 12000, 16000, 20000]; % Define band edges
    
    % Initialize output matrices y (time domain) and Y (frequency domain)
    y = zeros(9, n); % 9 bands, so 9 outputs
    Y = zeros(9, n); % in freq domain 

    % Initialize gain array
    gains = zeros(1, 9);

elseif (mode == 2) % Custom Mode
   k = input('Enter number of bands (5-10): ');
    while ~isnumeric(k) || ~isscalar(k) || k < 5 || k > 10 || mod(k,1) ~= 0
        k = input('Invalid. Enter integer between 5-10: ');
    end

    bands = [0.01, zeros(1, k-1)]; % Initialize with 0.01Hz
    for i = 1:k-1
        while true
            bands(i+1) = input(sprintf('Enter band %d frequency (Hz): ', i));
            if bands(i+1) <= bands(i)
                fprintf('Frequency must be > previous band (%.1f Hz)\n', bands(i));
            elseif bands(i+1) >= 20000
                fprintf('Frequency must be < 20kHz\n');
            else
                break;
            end
        end
    end
end
bands(end+1) = 20000; % Force final band to 20kHz

%---------------------------------------------------------------------------
%---------------------------------------------------------------------------

for i = 1 : k
        gains(i) = input(sprintf('Enter gain in db of band %d : ', i));
        gains(i) = 10^(gains(i) / 20); % Convert from dB to linear scale because digital filters work with linear amplitudes
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

% Desired output sampling frequency for playback/saving
desired_rate = input('Enter desired sampling frequeny: ');

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

% Create test signals for filter analysis
step_input = ones(1, fs);
impulse_input = [1 zeros(1 , fs-1)];

%------------------------------------------------------------------------
%------------------------------------------------------------------------

% Display filter type menu
type = input( sprintf( ['1: FIR Filter (Hamming) ' ...
    '\n2: FIR Filter (Hanning) ' ...
    '\n3: FIR Filter (Blackman) ' ...
    '\n4: IIR Filter (Butterworth) ' ...
    '\n5: IIR Filter (Chebyshev I) ' ...
    '\n6: IIR Filter (Chebyshev II)' ...
    '\n7: Enter filter type (1–6):  ']) ...
    );

while ~isnumeric(type) || ~isscalar(type) || ~ismember(type, 1:6)
    type = input('Invalid. Enter a number from 1 to 6: ');
end


order = input('Enter the order of the filter (press Enter to use default): ');

% Set default values
if isempty(order)
    if ismember(type, [1 2 3])  % FIR filter types
        order = 64;
    elseif ismember(type, [4 5 6])  % IIR filter types
        order = 4;
    else
        error('Invalid filter type.');
    end
end

% Input Validation
if any(bands >= fs/2)
    error('Band frequencies cannot exceed Nyquist frequency (%.1f Hz)', fs/2);
end

% Create appropriate filter coefficients
for i = 1 : k
    switch type
        case 1
            num = fir1(order, [bands(i) bands(i+1)] / (fs/2), hamming(order + 1));
            den = 1;
        case 2
            num = fir1(order, [bands(i) bands(i+1)] / (fs/2), hanning(order + 1));
            den = 1;
        case 3
            num = fir1(order, [bands(i) bands(i+1)] / (fs/2), blackman(order + 1));
            den = 1;
        case 4
            [num,den] = butter(order, [bands(i) bands(i+1)] / (fs/2));
        case 5
            [num,den] = cheby1(order, 1, [bands(i) bands(i+1)] / (fs/2));
        case 6
            [num,den] = cheby2(order, 40, [bands(i) bands(i+1)] / (fs/2));
    end

    fprintf('Band %d: %.2f-%.2f Hz (normalized: %.4f-%.4f)\n', ...
                i, bands(i), bands(i+1), bands(i)/(fs/2), bands(i+1)/(fs/2));
    
    % Apply filter to audio signal and scale by gain
    if size(sig, 2) == 2
        signal = mean(sig, 2); % Mix stereo to mono
    else
        signal = sig; % Use as is for mono
    end

    % Convolution operation
    y(i,:) = gains(i) * filter(num, den, signal); % filter() applies difference equation

    % Filter test signals to analyze filter characteristics
    step = filter(num, den, step_input);
    impulse = filter(num, den, impulse_input);

    % Compute complex frequency response H(e^jω)
    [H, f] = freqz(num, den, fs/2, fs); % freqz() uses DFT on filter coefficients

%------------------------------------------------------------------------

    % Filter Visualization
    figure();

    % Magnitude response
    subplot(3, 2, 1);
    plot(f, abs(H));
    title('Magnitude', 'Color', 'm');
    grid on

    % Phase response
    subplot(3, 2, 2);
    plot(f, angle(H) * 180 / pi);
    title('Phase', 'Color', 'm');
    grid on;

    % Impulse response
    subplot(3, 2, 3);
    plot(impulse);
    title('Impulse Response', 'Color', 'm'); 
    grid on;

    % Step response
    subplot(3, 2, 4);
    plot(step);
    title('Step Response', 'Color', 'm');
    grid on;

    % Pole-zero plot
    subplot(3, 2, [5 6])
    zplane(num, den);
    title('Poles and Zeros', 'Color', 'm');
    grid on;
end

%------------------------------------------------------------------------
%------------------------------------------------------------------------

% Frequency Domain Analysis
x_axis = (-n/2 : n/2-1) * (fs/n);

for i = 1:k
    Y(i, :) = (1/fs) * fftshift(fft(y(i, :))); % Computes FFT of filtered signal (shifted for correct frequency display)

    % Display frequency spectrum and time-domain signal
    figure();

    subplot(2, 1, 1);
    stem(x_axis, abs(Y(i, :)))
    subplot(2, 1, 2);
    plot(y(i, :))
end

% Combine all filtered bands by summing their time-domain signals.
filtered_sig = zeros(1, n);
for i = 1 : n 
    filtered_sig(i) = sum(y(:, i));
end 

filtered_sig = sum(y, 1); % Sum all bands along rows
filtered_sig = filtered_sig / max(abs(filtered_sig)); % Normalize to prevent clipping

%------------------------------------------------------------------------
%------------------------------------------------------------------------

SIG = (1/fs) * fftshift(fft(sig));
FILTERED_SIG = (1/fs) * fftshift(fft(filtered_sig));

% Show comparison between original and filtered signals in frequency domain
figure();

subplot(2, 1, 1);
stem(x_axis, abs(SIG))
title('Original Signal','Color','m');
xlabel('Frequency (Hz)'); ylabel('Magnitude');

subplot(2, 1, 2)
stem(x_axis, abs(FILTERED_SIG))
title('Filtered Signal','Color','m');
xlabel('Frequency (Hz)'); ylabel('Magnitude');


% Plays the filtered audio at desired sampling rate
if max(abs(filtered_sig)) < 1e-6
    warning('Filtered signal appears to be silent!');
else
    % Digital-to-analog conversion
    sound(filtered_sig, desired_rate);
end

% Save filtered audio
audiowrite('new_multiplied_by_4.wav', filtered_sig, desired_rate*4); % 4x desired rate
audiowrite('new_decreased_to_half.wav', filtered_sig, desired_rate/2); % 0.5x desired rate