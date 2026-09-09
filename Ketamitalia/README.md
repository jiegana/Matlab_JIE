SEDLINE EEG ANALYSIS & CLINICAL EVENT PIPELINE (KETAMITALIA)
============================================================
Author: José Ignacio Egaña T. (Plastikfaith) 2026 = jiegana@uchile.cl

DESCRIPTION
-----------
This MATLAB pipeline processes Sedline EEG data (EDF format) to compute multitaper spectrograms and extract advanced spectral features. It includes a custom graphical interface to log clinical events (such as ketamine boluses or intubation) based on the monitor's absolute clock time. 

The script dynamically segments the recording based on these user-defined events and generates statistical comparisons across epochs.

REQUIREMENTS
------------
* MATLAB (R2021a or newer recommended for boxchart rendering)
* Signal Processing Toolbox
* Chronux Toolbox (for mtspecgramc)

HOW TO USE
----------
1. Run the script in MATLAB.
2. A folder selection window will appear. Select the patient's root folder containing the `.edf` files.
3. The script will automatically concatenate the files, fill missing time gaps with zeros, and apply a 0.5 - 45 Hz bandpass filter.
4. An Event Logging GUI will appear. 
   * Enter the Event Name (e.g., "Bolus 1").
   * Enter the exact Absolute Time (HH:MM:SS) that the event occurred.
   * Click "Add Row" for additional events.
   * Click "Done / Plot" when finished.

OUTPUTS
-------
The script generates two main visualizations:
1. Spectrogram Figure: Displays Channel 3 power (dB) with overlaid SEF95 tracking and labeled, alternating vertical red markers for all logged clinical events.
2. Epoch Comparison Figure: A 3x3 grid of colored, notched box plots (outliers removed) comparing the inter-event epochs across nine extracted metrics.

METRICS EXTRACTED
-----------------
* Total Power
* Relative Alpha Power
* Relative Beta Power
* Spectral Edge Frequency 95 (SEF95)
* Peak Centroid Alpha
* Phase-Amplitude Coupling (PAC) Alpha-Delta
* Phase-Amplitude Coupling (PAC) Beta-Delta
* Phase-Amplitude Coupling (PAC) Gamma-Delta
* Lempel-Ziv Complexity (LZC)