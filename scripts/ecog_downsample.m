function [data_ds, params] = ecog_downsample(data, params)


    % downsample data
    length_out = ceil(size(data, 2) / params.analysis.compression);

    data_ds = nan(size(data, 1), length_out);
    
    compression = params.analysis.compression;
    
    parfor iChan = 1:size(data, 1)
       
        data_ds(iChan, :) = decimate(data(iChan, :), compression); 
        
    end
    
    % update params
    params.recording.samp_rate = params.recording.samp_rate / params.analysis.compression;
    
    msg = sprintf('downsampled, compression = %.1f', params.analysis.compression);
    if ~isfield(params, 'log') 
        params.log{1} = msg;
    else
        params.log{end + 1} = msg;
    end