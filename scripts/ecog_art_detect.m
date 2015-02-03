function [art] = ecog_art_detect(data, params)

    art.signal   = nan(size(data));
    art.gradient = nan(size(data));

    for iChan = 1:size(data,1)
        
        if ~all(isnan(data(iChan, :)))
        
            art.signal(iChan, :)   = art_detect(data(iChan, :), params.analysis.sign_out_thresh, 'signal');
            art.gradient(iChan, :) = art_detect(data(iChan, :), params.analysis.grad_out_thresh, 'gradient');
            
        end
        
    end
