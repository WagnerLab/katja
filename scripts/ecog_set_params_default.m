function params = ecog_set_params_default()

% default ecog parameters (for AIN study)
% k larocque

%% path info
params.dir.base     = '/Users/anthonywagner/biac4-wagner/biac3/wagner7/ecog/AIN/';

%% recording info
params.recording.ieegrate = 3051.76; % fixed, is recording rate
params.recording.samp_rate = 3051.76; % changes, is sampling rate of *current* form of data
params.recording.pdiorate = 24414.1;
params.recording.rescale = -1; % -1 if the recording signal was inverted such that the sign of the data should be flipped, 1 otherwise

%% analysis info
params.analysis.compression     = 7;

params.analysis.sign_out_thresh = 5;
params.analysis.grad_out_thresh = 5;

params.analysis.lowpass         = 180;
params.analysis.hipass          = .5;
params.analysis.notch           = (1:floor(params.analysis.lowpass/60))*60;

params.analysis.decompfreq      = [1 2.5; 2.5 5; 5 10; 10 12; 12 30; 30 70; 30 80; 80 180; 70 180; 30 50; 50 70];