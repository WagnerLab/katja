function [data_band, params] = ecog_bandpass(data, params)


    % bandpass data
    data_band = nan(size(data));
    
    fs = params.recording.samp_rate;
    lp = params.analysis.lowpass;
    hp = params.analysis.hipass;
    
    parfor iChan = 1:size(data, 1)
       
        data_band(iChan, :) = channel_filt(data(iChan, :), fs, lp, hp, []); 
        
    end
    
    % update params
    msg = sprintf('bandpass, %.2f - %.2f', params.analysis.hipass, params.analysis.lowpass);
    if ~isfield(params, 'log') 
        params.log{1} = msg;
    else
        params.log{end + 1} = msg;
    end