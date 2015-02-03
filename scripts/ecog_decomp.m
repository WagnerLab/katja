function [data_analytic, params] = ecog_decomp(data, params, band, chans)

    assert(numel(band) == 2, 'band needs to be two numbers [low high]')
    assert(band(2) > band(1), 'band(2) must be > band(1)')

    % bandpass data
    data_analytic = nan(size(data));
    
    fs = params.recording.samp_rate;
    lp = band(2);
    hp = band(1);
    
    parfor iChan = 1:size(data, 1)
        
        if ismember(iChan, chans)
       
            filtered = channel_filt(data(iChan, :), fs, lp, hp, []);
            data_analytic(iChan, :) = hilbert(filtered);
            
        end
        
    end
    
    % update params
    msg = sprintf('analytic, %.2f - %.2f', hp, lp);
    if ~isfield(params, 'log') 
        params.log{1} = msg;
    else
        params.log{end + 1} = msg;
    end