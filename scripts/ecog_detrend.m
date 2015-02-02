function [data_detr, params] = ecog_detrend(data, params)


    % detrend data
    data_detr = nan(size(data));
        
    parfor iChan = 1:size(data, 1)
       
        data_detr(iChan, :) = detrend(data(iChan, :), 'linear'); 
        
    end
    
    % update params
    msg = 'detrended, linear';
    if ~isfield(params, 'log') 
        params.log{1} = msg;
    else
        params.log{end + 1} = msg;
    end