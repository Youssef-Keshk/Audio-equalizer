# MATLAB Audio Equalizer Project

This repository contains a MATLAB-based implementation of an **Audio Equalizer**, developed as part of the **Digital Signal Processing (DSP) coursework**.
## 📌 Project Description

An **audio equalizer** is a tool used to adjust the volume of different frequency ranges in a sound signal. This project enables users to:
- Boost or cut bass, mids, or treble.
- Shape the tone of music, speech, or recordings.
- Fix audio issues such as harshness or lack of clarity.

The program provides a customizable audio filtering system using FIR or IIR filters, and outputs a modified version of the input wave file based on user-defined gain and frequency bands.

## 🚀 Features

- Load any `.wav` file using a file dialog.
- Two modes of operation:
  - **Standard Mode:** 9 predefined frequency bands from 0Hz to 20kHz.
  - **Custom Mode:** User-defined bands (5–10 bands), with constraints on range.
- FIR and IIR filter support:
  - **FIR:** Choose between Hamming, Hanning, or Blackman windows.
  - **IIR:** Choose between Butterworth, Chebyshev Type I, or Chebyshev Type II.
- Manual or default filter order selection.
- Analyze and export:
  - Magnitude and phase response
  - Impulse and step response
  - Filter order and poles/zeros
- Amplify filtered signals using user-defined gains (in dB).
- Time-domain and frequency-domain plotting.
- Composite signal generation by summing filtered components.
- Comparison between original and processed signals.
- Play and save the final output wave signal.
- Adjustable output sample rate (e.g., ×4 or ÷2).

## 🧾 Inputs Required

The program prompts the user to input the following:
1. Wave file name (via file browser).
2. Gain (in dB) for each frequency band.
3. Filter type: FIR or IIR.
4. Filter specifications (order, window/type).
5. Output sample rate.

## 📝 Assignment Requirements (Covered)

- ✅ UI via command line inputs and menus
- ✅ Custom/standard band selection
- ✅ FIR/IIR with order and type selection
- ✅ Filter response analysis
- ✅ Signal visualization (time & frequency)
- ✅ Gain application and composite output
- ✅ Output playback and file saving

## 🎓 University

> Alexandria University  
> Faculty of Engineering  
> Computer and Communication Program  

