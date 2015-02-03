function [data, params] = ecog_make_data_matrix(params)

    % preallocate
    try
        rawdatafile = fullfile(params.dir.raw, sprintf('%s%s_%02d.mat', params.chans.rawprefix, params.blocks.thisblock, 1));
        x           = load(rawdatafile);
    catch %#ok<CTCH>  % if this file isn't found try without the zero-padding  
        rawdatafile = fullfile(params.dir.raw, sprintf('%s_%d.mat', params.chans.rawprefix, 1));
        x           = load(rawdatafile);
    end

    data = nan(params.chans.nchan, length(x.wave));
    data(1,:) = double(x.wave);
    
    % assemble into matrix
    for iChan = 2:params.chans.nchan
        
        try
            rawdatafile = fullfile(params.dir.raw, sprintf('%s%s_%02d.mat', params.chans.rawprefix, params.blocks.thisblock, iChan));
            x           = load(rawdatafile);
        catch %#ok<CTCH> % if this file isn't found try without the zero-padding    
            rawdatafile = fullfile(params.dir.raw, sprintf('%s_%d.mat', params.chans.rawprefix, iChan)); 
            x           = load(rawdatafile);
        end
        
        data(iChan,:) = double(x.wave);
        
    end
    
    % rescale signal (-1 if signal was inverted, 1 to leave as is)
    data = data * params.recording.rescale;
    
    % update parameters
    msg = sprintf('raw * %.1e', params.recording.rescale);
    if ~isfield(params, 'log') 
        params.log{1} = msg;
    else
        params.log{end + 1} = msg;
    end