function ecog_set_params_subj06()

% set subject-specific parameters for ecog subj06
% dependencies: ecog_set_params_default()
% karen larocque, october 13, 2014

%% set vars

subj = 'S06';

%% get defaults and set subj name

params = ecog_set_params_default();

params.subj = subj;

%% set recording info (to accept defaults do nothing)


%% set channel info

params.chans.nchan     = 56;
params.chans.pdiopre   = 'Pdio';
params.chans.pdiopost  = '_02';
params.chans.rawprefix = 'iEEG';

params.chans.mtlelecs  = [25 41 42 49 50];
params.chans.mtlcode   = [24 16 13 16 16];
%chans.rejelecs  = chans.mtlelecs;
params.chans.epichan   = 9:32;
params.chans.badchan   = [17 9:12 18 25 41]; %17 from parvizi lab, the rest based on visual inspection (too many gradient artifacts) by kfl
params.chans.refchan   = 30;

params.chans.gray      = [3:5 8 10:13 19:21 23:24 25 29:31 39 41:43 45:46 49:50 55:56];
params.chans.white     = [1:2 6:7 9 17:18 22 26:28 33:38 44 51:54];
params.chans.nobrain   = [14:16 32 40 47:48];
params.chans.carchans  = params.chans.white; % use set diff to exclude potential mtl elecs

params.chans.stripfield     = []; % warning: if ANY of this string is contained in the variable name used in the raw data files the entire variable name will be repalced with 'replacefield'
params.chans.replacefield   = 'wave';

%% set block info

params.blocks.blocklist = {'ENN03','ENN04','ENN05','ENN06','ENN08','ENN09','ENN10','ENN20'};
params.blocks.eventlist = {'ain.s06.2.out.txt','ain.s06.3.out.txt','ain.s06.4.out.txt','ain.s06.5.out.txt','ain.s06.6.out.txt',...
                            'ain.s06.7.out.txt','ain.s06.8.out.txt','ain.s06.9.out.txt'};
                        
params.blocks.stripstring    = 'ENN';
params.blocks.replacestring  = 'S06';

%% set analysis info (to accept defaults do nothing)


%% for each block, set block specific params and output the block

if ~exist(fullfile(params.dir.base, subj, 'data', 'ParData'), 'dir')
    system(sprintf('mkdir %s', fullfile(params.dir.base, subj, 'data', 'ParData')))
end

for iBlock = 1:length(params.blocks.blocklist)
    
    params.dir.raw      = fullfile(params.dir.base, subj, 'data', 'RawData',    params.blocks.blocklist{iBlock});
    params.dir.comp     = fullfile(params.dir.base, subj, 'data', 'CompData',   params.blocks.blocklist{iBlock});
    params.dir.filt     = fullfile(params.dir.base, subj, 'data', 'FiltData',   params.blocks.blocklist{iBlock});
    params.dir.reref    = fullfile(params.dir.base, subj, 'data', 'RerefData',  params.blocks.blocklist{iBlock});
    params.dir.decomp   = fullfile(params.dir.base, subj, 'data', 'DecompData', params.blocks.blocklist{iBlock});
    params.dir.fig      = fullfile(params.dir.base, subj, 'data', 'Figures',    params.blocks.blocklist{iBlock});
    
    params.blocks.thisblock = params.blocks.blocklist{iBlock};
    params.blocks.thisevent = params.blocks.eventlist{iBlock};
    
    params.blocks.me        = fullfile(params.dir.base, subj, 'data', 'ParData', sprintf('ecog_params_%s.mat', params.blocks.blocklist{iBlock}));
    
    save(params.blocks.me, 'params')

end
