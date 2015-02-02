function [data, params] = ecog_notch(data, params)


    % notch filter data
    
    fs = params.recording.samp_rate;
    notch_list = params.analysis.notch;
    
    for iNotch = 1:length(notch_list)
        
        notch = notch_list(iNotch);
    
        parfor iChan = 1:size(data, 1)
        
            data(iChan, :) = channel_filt(data(iChan, :), fs, [], [], notch);
            
        end

    end
    
    % update params
    msg = sprintf('notch %s', sprintf('%d ', notch_list));
    if ~isfield(params, 'log') 
        params.log{1} = msg;
    else
        params.log{end + 1} = msg;
    end