function [data, params, car] = ecog_reref(data, params)


    % make car signal
    
    % this needs to move into param file code
    car_chans = setdiff(params.chans.carchans, union(params.chans.epichan, params.chans.badchan));
    
    car = mean(data(car_chans, :), 1);

    parfor iChan = 1:size(data, 1)

        data(iChan, :) = data(iChan, :) - car;

    end

    
    % update params
    msg = sprintf('car, white, exc epi & bad'); % hard coded!!!!!
    if ~isfield(params, 'log') 
        params.log{1} = msg;
    else
        params.log{end + 1} = msg;
    end