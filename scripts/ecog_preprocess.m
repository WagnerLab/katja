function ecog_preprocess(subj_file, flags)

% preprocess raw ecog data for specified subject and block
% preprocessing includes:
% 
%     
% inputs:
%     subj_file: path to subject variable file; this file should be
%     specific to a single block
%     flags: indicate desired steps
%         'f' file renaming
%         's' put data into chan x time matrix and downsample
%         't' detrend
%         'b' bandpass filter
%         'n' notch filter
%         'c' common average reference
%         'd' decompose
%         
% usage: ecog_preprocess('subj02', 1, 'fst')
% 
% signal processing dependencies:
% art_detect.m
% channel_filt.m
%
% requires ecog toolbox (katja)
% 
% authors: karen larocque

%% load subject variables
if exist(subj_file, 'file')
    
    tmp = load(subj_file);
    params = tmp.params;
    clear('tmp')
    
    % to do: check to make sure that subject parameter file has all required
    % parameters
    
else 
    
    sprintf('Subject file %s does not exist, exiting!', subj_file)
    return
    
end

%% file rename
if ismember('f', flags)
    
    fprintf('Renaming files for %s ... ', params.blocks.thisblock);
    
    params = ecog_rename_files(params);
    
    fprintf('done\n');
    
end

%% downsample
if ismember('s', flags)
    
    fprintf('Downsampling %s ... ', params.blocks.thisblock);
    
    % make data matrix
    [data, params] = ecog_make_data_matrix(params);
    
    % downsample
    data_raw = data;
    params_raw = params;
    [data, params] = ecog_downsample(data_raw, params_raw);
    
    fprintf('done\n');
    
    fprintf('QA %s ... ', params.blocks.thisblock);
    
    % qa
    art_raw = ecog_art_detect(data_raw, params_raw);
    art     = ecog_downsample_artifacts(art_raw, params);
    ecog_qa_compare(data_raw, data, art_raw, art, params_raw, params, 'raw_comp');
    
    fprintf('done\n');
    
    fprintf('Saving downsampled %s ... ', params.blocks.thisblock);
 
    % save data, params, art
    if ~exist(fileparts(params.dir.comp),'dir') % main comp dir
        system(sprintf('mkdir %s', fileparts(params.dir.comp)));
    end
    if ~exist(params.dir.comp, 'dir')
        system(sprintf('mkdir %s', params.dir.comp));
    end
    
    save(fullfile(params.dir.comp, sprintf('%s_data_compressed.mat',   params.blocks.thisblock)), 'data');
    save(fullfile(params.dir.comp, sprintf('%s_params_compressed.mat', params.blocks.thisblock)), 'params');
    save(fullfile(params.dir.comp, sprintf('%s_art_compressed.mat',    params.blocks.thisblock)), 'art');
    
    clear('data_raw', 'params_raw', 'art_raw')
    
    fprintf('done\n');
    
end

%% prep for filtering
if any(ismember('tbn', flags))
    
    if ~exist('data', 'var')
        fprintf('Loading saved compressed data for %s ... ', params.blocks.thisblock);
        tmp = load(fullfile(params.dir.comp, sprintf('%s_data_compressed.mat',   params.blocks.thisblock)));
        data = tmp.data;
        clear('tmp');
        fprintf('done\n');
    end
    
    if ~exist('art', 'var')
        tmp = load(fullfile(params.dir.comp, sprintf('%s_art_compressed.mat',   params.blocks.thisblock)));
        art = tmp.art;
        clear('tmp');
    end
    
    tmp = load(fullfile(params.dir.comp, sprintf('%s_params_compressed.mat',   params.blocks.thisblock)));
    params = tmp.params;
    clear('tmp');

    
    data_comp   = data;
    params_comp = params;
    art_comp    = art;

    
end
%% detrend
if ismember('t', flags)
    
    fprintf('Detrending %s ... ', params.blocks.thisblock);
    
    [data, params] = ecog_detrend(data, params);
    
    fprintf('done\n');
    
end

%% bandpass
if ismember('b', flags)
    
    fprintf('Bandpassing %s ... ', params.blocks.thisblock);
    
    [data, params] = ecog_bandpass(data, params);
    
    fprintf('done\n');
    
end

%% notch
if ismember('n', flags)
    
    fprintf('Notching %s ... ', params.blocks.thisblock);
    
    [data, params] = ecog_notch(data, params);
    
    fprintf('done\n');
    
end

%% qa for filtered data & save filtered data
if any(ismember('tbn', flags))
    
    fprintf('QA %s ... ', params.blocks.thisblock);
    
    % artifact detection
    art = ecog_art_detect(data, params);
    
    % quality assurance
    ecog_qa_compare(data_comp, data, art_comp, art, params_comp, params, 'comp_filt');
    
    fprintf('done\n')
    
    fprintf('Saving filtered %s ...', params.blocks.thisblock);

    % save
    if ~exist(fileparts(params.dir.filt),'dir') % main comp dir
        system(sprintf('mkdir %s', fileparts(params.dir.filt)));
    end
    if ~exist(params.dir.filt, 'dir')
        system(sprintf('mkdir %s', params.dir.filt));
    end
    save(fullfile(params.dir.filt, sprintf('%s_data_filt.mat',   params.blocks.thisblock)), 'data');
    save(fullfile(params.dir.filt, sprintf('%s_params_filt.mat', params.blocks.thisblock)), 'params');
    save(fullfile(params.dir.filt, sprintf('%s_art_filt.mat',    params.blocks.thisblock)), 'art');
    
    clear('data_comp', 'params_comp', 'art_comp')
    
    fprintf('done\n');
end

%% decompose candidate electrodes for reref

if ismember('w', flags)
    
    % load filtered data
    
    if ~exist('data', 'var')
        fprintf('Loading saved filtered data for %s ... ', params.blocks.thisblock);
        tmp = load(fullfile(params.dir.filt, sprintf('%s_data_filt.mat',   params.blocks.thisblock)));
        data = tmp.data;
        clear('tmp');
        fprintf('done\n');
    end
    
    tmp = load(fullfile(params.dir.filt, sprintf('%s_params_filt.mat',   params.blocks.thisblock)));
    params = tmp.params;
    clear('tmp');
    
    % decomposition
    
    chans = params.chans.carchans; % restrict to car chans
    
    % get directory ready
    params.dir.screen = fullfile(params.dir.base, params.subj, 'data', 'RerefScreening', params.blocks.thisblock);
    if ~exist(fileparts(params.dir.screen),'dir') % main comp dir
        system(sprintf('mkdir %s', fileparts(params.dir.screen)));
    end
    if ~exist(params.dir.screen, 'dir')
        system(sprintf('mkdir %s', params.dir.screen));
    end
    
    
    % for each specified freq ...
    fprintf('Decomposition of potential CAR electrodes for %s ... \n ', params.blocks.thisblock);
    
    for iFreq = 1:size(params.analysis.decompfreq, 1)
        
        fprintf('  %.2f - %.2f\n', params.analysis.decompfreq(iFreq, :));
        
        [data_freq, params_freq] = ecog_decomp(data, params, params.analysis.decompfreq(iFreq, :), chans);
        
        art_freq = ecog_art_detect(abs(data_freq), params_freq); % detect on amplitude
        
        ecog_qa_decomp(data_freq, art_freq, params_freq, sprintf('decomp_%.2f_%.2f', params.analysis.decompfreq(iFreq, :)));
        
        save(fullfile(params.dir.screen, sprintf('%s_data_decomp_carscreen_%.2f_%.2f.mat',   params.blocks.thisblock, params.analysis.decompfreq(iFreq, :))), 'data_freq')
        save(fullfile(params.dir.screen, sprintf('%s_params_decomp_carscreen_%.2f_%.2f.mat', params.blocks.thisblock, params.analysis.decompfreq(iFreq, :))), 'params_freq')
        save(fullfile(params.dir.screen, sprintf('%s_art_decomp_carscreen_%.2f_%.2f.mat',    params.blocks.thisblock, params.analysis.decompfreq(iFreq, :))), 'art_freq')
        
        clear('data_freq', 'params_freq', 'art_freq');
        
    end
    
    fprintf('done\n');
    
    clear('data'); % clean up data to be safe
    
end
    

%% common average reference
if ismember('c', flags)
    
    % load filtered data
    
    if ~exist('data', 'var')
        fprintf('Loading saved filtered data for %s ... ', params.blocks.thisblock);
        tmp = load(fullfile(params.dir.filt, sprintf('%s_data_filt.mat',   params.blocks.thisblock)));
        data = tmp.data;
        clear('tmp');
        fprintf('done\n');
    end
    
    if ~exist('art', 'var')
        tmp = load(fullfile(params.dir.filt, sprintf('%s_art_filt.mat',   params.blocks.thisblock)));
        art = tmp.art;
        clear('tmp');
    end
    
    tmp = load(fullfile(params.dir.filt, sprintf('%s_params_filt.mat',   params.blocks.thisblock)));
    params = tmp.params;
    clear('tmp');

    
    data_filt   = data;
    params_filt = params;
    art_filt    = art;
    
    % reref
    fprintf('Rereferencing %s ... ', params.blocks.thisblock);
    [data, params, ref] = ecog_reref(data, params);
    fprintf('done\n');
    
    fprintf('QA %s ...', params.blocks.thisblock);
    
    % art
    art = ecog_art_detect(data, params);
    art_ref = ecog_art_detect(ref, params);
    
    % quality assurance
    ecog_qa_compare(data_filt, data, art_filt, art, params_filt, params, 'filt_reref');
    ecog_qa_single(ref, art_ref, params, 'refsignal');
    
    fprintf('done\n');
    
    fprintf('Saving rereferenced %s ...', params.blocks.thisblock);

    % save
    if ~exist(fileparts(params.dir.reref),'dir') % main comp dir
        system(sprintf('mkdir %s', fileparts(params.dir.reref)));
    end
    if ~exist(params.dir.reref, 'dir')
        system(sprintf('mkdir %s', params.dir.reref));
    end
    save(fullfile(params.dir.reref, sprintf('%s_data_reref.mat',   params.blocks.thisblock)), 'data');
    save(fullfile(params.dir.reref, sprintf('%s_params_reref.mat', params.blocks.thisblock)), 'params');
    save(fullfile(params.dir.reref, sprintf('%s_art_reref.mat',    params.blocks.thisblock)), 'art');
    save(fullfile(params.dir.reref, sprintf('%s_ref_data.mat',     params.blocks.thisblock)), 'ref');
    save(fullfile(params.dir.reref, sprintf('%s_ref_art.mat',      params.blocks.thisblock)), 'art_ref');
    
    clear('data_reref', 'params_reref', 'art_reref', 'ref', 'ref_art');
    
    fprintf('done\n');

end

%% decompose CAR

if ismember('x', flags)
    
    % load car data
    
    if ~exist('data', 'var')
        fprintf('Loading saved CAR for %s ... ', params.blocks.thisblock);
        tmp = load(fullfile(params.dir.reref, sprintf('%s_ref_data.mat',   params.blocks.thisblock)));
        data = tmp.ref;
        clear('tmp');
        fprintf('done\n');
    end
    
    tmp = load(fullfile(params.dir.reref, sprintf('%s_params_reref.mat',   params.blocks.thisblock)));
    params = tmp.params;
    clear('tmp');
    
    % decomposition
    
    chans = 1; % only one car trace
    
    % get directory ready
    params.dir.screen = fullfile(params.dir.base, params.subj, 'data', 'RerefScreening', params.blocks.thisblock);
    if ~exist(fileparts(params.dir.screen),'dir') % main comp dir
        system(sprintf('mkdir %s', fileparts(params.dir.screen)));
    end
    if ~exist(params.dir.screen, 'dir')
        system(sprintf('mkdir %s', params.dir.screen));
    end
    
    
    % for each specified freq ...
    fprintf('Decomposition CAR for %s ... \n ', params.blocks.thisblock);
    
    for iFreq = 1:size(params.analysis.decompfreq, 1)
        
        fprintf('  %.2f - %.2f\n', params.analysis.decompfreq(iFreq, :));
        
        [data_freq, params_freq] = ecog_decomp(data, params, params.analysis.decompfreq(iFreq, :), chans);
        
        art_freq = ecog_art_detect(abs(data_freq), params_freq); % detect on amplitude
        
        ecog_qa_decomp(data_freq, art_freq, params_freq, sprintf('decomp_%.2f_%.2f', params.analysis.decompfreq(iFreq, :)));
        
        save(fullfile(params.dir.screen, sprintf('%s_data_decomp_car_%.2f_%.2f.mat',   params.blocks.thisblock, params.analysis.decompfreq(iFreq, :))), 'data_freq')
        save(fullfile(params.dir.screen, sprintf('%s_params_decomp_car_%.2f_%.2f.mat', params.blocks.thisblock, params.analysis.decompfreq(iFreq, :))), 'params_freq')
        save(fullfile(params.dir.screen, sprintf('%s_art_decomp_car_%.2f_%.2f.mat',    params.blocks.thisblock, params.analysis.decompfreq(iFreq, :))), 'art_freq')
        
        clear('data_freq', 'params_freq', 'art_freq');
        
    end
    
    fprintf('done\n');
    
    clear('data'); % clean up data to be safe
    
end

%% decompose

if ismember('d', flags)
    
    % load reref data

    if ~exist('data', 'var')
        fprintf('Loading saved reref data for %s ... ', params.blocks.thisblock);
        tmp = load(fullfile(params.dir.reref, sprintf('%s_data_reref.mat',   params.blocks.thisblock)));
        data = tmp.data;
        clear('tmp');
        fprintf('done\n');
    end

    tmp = load(fullfile(params.dir.reref, sprintf('%s_params_reref.mat',   params.blocks.thisblock)));
    params = tmp.params;
    clear('tmp');
    
    
    % decomposition
    
    chans = params.chans.mtlelecs; % restrict to MTL chans
    
    % get directory ready
    if ~exist(fileparts(params.dir.decomp),'dir') % main comp dir
        system(sprintf('mkdir %s', fileparts(params.dir.decomp)));
    end
    if ~exist(params.dir.decomp, 'dir')
        system(sprintf('mkdir %s', params.dir.decomp));
    end
    
    
    % for each specified freq ...
    fprintf('Decomposition for %s ... \n ', params.blocks.thisblock);
    
    for iFreq = 1:size(params.analysis.decompfreq, 1)
        
        fprintf('  %.2f - %.2f\n', params.analysis.decompfreq(iFreq, :));
        
        [data_freq, params_freq] = ecog_decomp(data, params, params.analysis.decompfreq(iFreq, :), chans);
        
        art_freq = ecog_art_detect(abs(data_freq), params_freq); % detect on amplitude
        
        ecog_qa_decomp(data_freq, art_freq, params_freq, sprintf('decomp_%.2f_%.2f', params.analysis.decompfreq(iFreq, :)));
        
        save(fullfile(params.dir.decomp, sprintf('%s_data_decomp_%.2f_%.2f.mat',   params.blocks.thisblock, params.analysis.decompfreq(iFreq, :))), 'data_freq')
        save(fullfile(params.dir.decomp, sprintf('%s_params_decomp_%.2f_%.2f.mat', params.blocks.thisblock, params.analysis.decompfreq(iFreq, :))), 'params_freq')
        save(fullfile(params.dir.decomp, sprintf('%s_art_decomp_%.2f_%.2f.mat',    params.blocks.thisblock, params.analysis.decompfreq(iFreq, :))), 'art_freq')
        
        clear('data_freq', 'params_freq', 'art_freq');
        
    end
    
    fprintf('done\n');
    
    clear('data', 'params');
    
end


end