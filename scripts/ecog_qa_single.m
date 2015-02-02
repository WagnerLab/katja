function ecog_qa_single(data, art, params, label)

    % to do: add legend that does not squish plot or block signal
    % to do: change art plots & spectrum plots to functions
    
    % data types

    header = label;
    
    % make label dir
    if ~exist(fullfile(params.dir.fig, label), 'dir')
       system(sprintf('mkdir %s', fullfile(params.dir.fig, label))); 
    end

    % by channel
    for iChan = 1:size(data, 1)
        
        h = figure('Visible', 'off', 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 12, 4]);

        % power spectrum
        subplot(1, 3, 1);
        spct = spectrum.welch('hann', 2048, 80);
        plot(psd(spct, data(iChan, :), 'Fs', params.recording.samp_rate,'nfft', 2048));
        xlim = get(gca, 'xlim');
        if xlim(2) < 10 % assume in KHz (better way to do this?)
            set(gca, 'XLim', [0 params.analysis.lowpass / 1000]);
        else
            set(gca, 'XLim', [0 params.analysis.lowpass]);
        end
        
        % histogram
        subplot(1, 3, 2); 
        hist(data(iChan, :), 100);
        title(header)
        
        % signal + art
        subplot(1, 3, 3)
        plot(data(iChan, :), 'k');

        if ~isempty(art)
            hold on;
            plot(find(art.signal(iChan, :)),   data(iChan, art.signal(iChan, :) > 0),   'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r')
            plot(find(art.gradient(iChan, :)), data(iChan, art.gradient(iChan, :) > 0), 'go', 'MarkerSize', 4, 'MarkerFaceColor', 'g')
            hold off
        end

        set(gca, 'XLim', [0 size(data, 2)]);
        title(header)
        
        saveas(h, fullfile(params.dir.fig, label, sprintf('%s_%s_chan%02d_%s', params.subj, params.blocks.thisblock, iChan, label)), 'png');
        close(h)        

    end

    % summary
    h = figure('Visible', 'off', 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 12, 4]);
    
    subplot(1, 2, 1);
    imagesc(data);
    title(sprintf('signal, %s', header));
    caxis([mean(data(:)) - 7*std(data(:)) mean(data(:)) + 7*std(data(:))]);
    
    colormap('hot');
    freezeColors();
    
    
    subplot(1, 2, 2);
    imagesc(art.signal + 2*art.gradient);
    title(sprintf('art, %s', header));
    
    colormap('gray')
    
    saveas(h, fullfile(params.dir.fig, label, sprintf('%s_%s_%s', params.subj, params.blocks.thisblock, label)), 'png');
    close(h);
