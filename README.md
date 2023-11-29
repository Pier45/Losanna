# Losanna
 Analysis of the synchronization between ECG and respiration

### Algorithm
**First part**
Denoising, outliers identification, cycles identification

**Second part**
Identify the synchronization segments and the percentage respect to all the cycles.

### Test
In the test folder there is 'Simulator.m' that allows to create the data to test the sync functions.

### Software used
Matlab 2023a

### Next features
- :white_check_mark: Read only part of the mat file raw_data [matfile function](https://ch.mathworks.com/help/matlab/ref/matlab.io.matfile.html) [large mat files](https://ch.mathworks.com/help/matlab/large-mat-files.html)
> The file on the server are larger than 2Gb so are automatically saved in v7.3 format, the partial loading is possible.
- [ ] Improve sync algorithm, m different from 1
- [ ] Implement the functions in Start_analysis_server
- [ ] Test the algorithm with Matlab 2019a

### Info
Author: Piero Policastro
email: *piero.policastro@gmail.com*

