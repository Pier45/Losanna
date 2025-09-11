# Losanna
 Analysis of the synchronization between ECG and respiration

### Algorithm
**First part**
Denoising, outliers identification, cycles identification

**Second part**
Identify the synchronization segments and the percentage respect to all the cycles.

### Test
In the test folder there is 'Simulator.m' that allows to create the data to test the sync functions.

### Tested on
Matlab 2025a
Matlab 2019a

### Next features
:white_check_mark: Read only part of the mat file raw_data [matfile function](https://ch.mathworks.com/help/matlab/ref/matlab.io.matfile.html)
> The file on the server are larger than 2Gb so are automatically saved in v7.3 format. Loading only the needed part of the dataset reduce a lot use of memory (TESTED ALREADY).
:white_check_mark: Improve sync algorithm, m different from 1
:white_check_mark: Implement the functions in Start_analysis_server
:white_check_mark: Test the algorithm with Matlab 2019a
> The function xregion is not compatible with 2019 version, so an specific version was designed to overcome this problem
> The function xline is not compatible with 2019 version for multiple input cell arrays 

### Info
Author: Piero Policastro
email: *piero.policastro@gmail.com*

