function params =  ecog_rename_files(params)

%% if specified, replace string in all relevant files
if ~isempty(params.blocks.stripstring) && ~isempty(params.blocks.replacestring)
    
    fprintf('\nReplacing all instances of %s with %s, for subject %s, block %s\n', params.blocks.stripstring, params.blocks.replacestring, params.subj, params.blocks.thisblock) 
    
    strip   = params.blocks.stripstring;
    replace = params.blocks.replacestring;
    
    %% rename raw data directory block
    
    % get new block name
    [base, direc] = fileparts(params.dir.raw);
    new_block     = strrep(direc, strip, replace);
    new_dir       = fullfile(base, new_block);
    
    % replace raw data directory
    cmd = sprintf('mv %s %s', params.dir.raw, new_dir);
    system(cmd);
    
    %% rename photodiode files (if exist)
    
    p_files = dir(fullfile(params.dir.behav, sprintf('*pdioevents_%s*', params.blocks.thisblock)));
    
    for iPfile = 1:length(p_files)
       
        cmd = sprintf('mv %s %s', fullfile(params.dir.behav, p_files(iPfile).name), fullfile(params.dir.behav, strrep(p_files(iPfile).name, strip, replace)));
        system(cmd);
        
    end

    %% rename relevant parameter fields
    
    % replace directories
    fields = fieldnames(params.dir);
    fields = setdiff(fields, 'base');
    
    for iFields = 1:length(fields)
       
        [base, direc] = fileparts(params.dir.(fields{iFields}));
        params.dir.(fields{iFields}) = fullfile(base, strrep(direc, strip, replace));
        
    end
    
    % replace block list
    for iBlock = 1:length(params.blocks.blocklist)
        
        params.blocks.blocklist{iBlock} = strrep(params.blocks.blocklist{iBlock}, strip, replace); 
        
    end

    % replace thisblock
    params.blocks.thisblock = new_block;
    
    % replace me
    [base, mfile, suff] = fileparts(params.blocks.me);
    params.blocks.me = fullfile(base, sprintf('%s%s', strrep(mfile, strip, replace), suff));
    
    
    %% rename raw data channel files
    
    chan_files = dir(fullfile(params.dir.raw, sprintf('*%s*', strip)));
    
    for iChan = 1:length(chan_files)
        
        cmd = sprintf('mv %s %s', fullfile(params.dir.raw, chan_files(iChan).name), fullfile(params.dir.raw, strrep(chan_files(iChan).name, strip, replace)));
        system(cmd);
        
    end
    
    %% re-save parameter file (with potentially new name)
    
    save(params.blocks.me, 'params')
    
end

%% if specified, change field name in data files
if ~isempty(params.chans.stripfield) && ~isempty(params.chans.replacefield)
    
    fprintf('\nChanging field in data files that contains %s to %s, for subject %s, block %s ...', params.chans.stripfield, params.chans.replacefield, params.subj, params.blocks.thisblock) 
    
    chan_files = dir(fullfile(params.dir.raw, sprintf('*%s*', params.chans.rawprefix)));
    
    for iChan = 1:length(chan_files)
        
        tmpchan = load(fullfile(params.dir.raw, chan_files(iChan).name));
        
        fields  = fieldnames(tmpchan);
        
        if length(fields) > 1
            
            fprintf('File %s has multiple fields, skipping replacement\n', chan_files(iChan).name);
            
        elseif strmatch(params.chans.stripfield, fields{1})
            
            tmpchan.(params.chans.replacefield) = tmpchan.(fields{1});
            tmpchan = rmfield(tmpchan, fields{1}); %#ok<NASGU>
            save(fullfile(params.dir.raw, chan_files(iChan).name), '-struct', 'tmpchan');
            
        end
        
    end
    
    fprintf(' done\n');
    
end
