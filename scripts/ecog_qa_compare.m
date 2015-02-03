function ecog_qa_compare(data1, data2, art1, art2, params1, params2, label)

    % to do: add legend that does not squish plot or block signal
    % to do: change art plots & spectrum plots to functions
    
    % make sure plots aligned if sampling rate is different
    comp_ratio = params1.recording.samp_rate / params2.recording.samp_rate;
    
    % data types

    header1 = params1.log{end};
    header2 = params2.log{end};
    
    % make label dir
    if ~exist(fullfile(params2.dir.fig, label), 'dir')
       system(sprintf('mkdir %s', fullfile(params2.dir.fig, label))); 
    end

    % by channel
    for iChan = 1:size(data1, 1)
        
        h = figure('Visible', 'off', 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 12, 8]);

        % power spectrum
        subplot(2, 3, 1);
        spct = spectrum.welch('hann', 2048 * comp_ratio, 80);
        plot(psd(spct, data1(iChan, :), 'Fs', params1.recording.samp_rate,'nfft', 2048 * comp_ratio));
        xlim = get(gca, 'xlim');
        if xlim(2) < 10 % assume in KHz (better way to do this?)
            set(gca, 'XLim', [0 params1.analysis.lowpass / 1000]);
        else
            set(gca, 'XLim', [0 params1.analysis.lowpass]);
        end

        subplot(2, 3, 4);
        spct=spectrum.welch('hann', 2048, 80);
        plot(psd(spct, data2(iChan, :), 'Fs', params2.recording.samp_rate,'nfft', 2048));
        xlim = get(gca, 'xlim');
        if xlim(2) < 10 % assume in KHz (better way to do this?)
            set(gca, 'XLim', [0 params2.analysis.lowpass / 1000]);
        else
            set(gca, 'XLim', [0 params2.analysis.lowpass]);
        end
        
        % histogram
        subplot(2, 3, 2); 
        hist(data1(iChan, :), 100);
        title(header1)

        subplot(2, 3, 5)
        hist(data2(iChan, :), 100);
        title(header2)
        
        % signal + art
        subplot(2, 3, 3)
        plot(data1(iChan, :), 'k');

        if ~isempty(art1)
            hold on;
            plot(find(art1.signal(iChan, :)),   data1(iChan, art1.signal(iChan, :) > 0),   'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r')
            plot(find(art1.gradient(iChan, :)), data1(iChan, art1.gradient(iChan, :) > 0), 'go', 'MarkerSize', 4, 'MarkerFaceColor', 'g')
            hold off
        end

        set(gca, 'XLim', [0 size(data1, 2)]);
        title(header1)
        
        subplot(2, 3, 6)
        plot(data2(iChan, :), 'k');

        if ~isempty(art2)
            hold on;
            plot(find(art2.signal(iChan, :)),   data2(iChan, art2.signal(iChan, :) > 0),   'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r')
            plot(find(art2.gradient(iChan, :)), data2(iChan, art2.gradient(iChan, :) > 0), 'go', 'MarkerSize', 4, 'MarkerFaceColor', 'g')
            hold off
        end

        set(gca, 'XLim', [0 size(data2, 2)]);
        title(header2)

        saveas(h, fullfile(params2.dir.fig, label, sprintf('%s_%s_chan%02d_%s', params2.subj, params2.blocks.thisblock, iChan, label)), 'png');
        close(h)        

    end

    % summary
    h = figure('Visible', 'off', 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 12, 8]);
    
    subplot(2, 2, 1);
    imagesc(data1);
    title(sprintf('signal, %s', header1));
    caxis([mean(data1(:)) - 7*std(data1(:)) mean(data1(:)) + 7*std(data1(:))]);
    
    colormap('hot');
    freezeColors();
    
    subplot(2, 2, 3);
    imagesc(data2);
    title(sprintf('signal, %s', header2));
    caxis([mean(data1(:)) - 7*std(data1(:)) mean(data1(:)) + 7*std(data1(:))]);
    
    colormap('hot');
    freezeColors();
    
    subplot(2, 2, 2);
    imagesc(art1.signal + 2*art1.gradient);
    title(sprintf('art, %s', header1));
    
    subplot(2, 2, 4);
    imagesc(art2.signal + 2*art2.gradient);
    title(sprintf('art, %s', header2));
    
    colormap('gray')
    
    saveas(h, fullfile(params2.dir.fig, label, sprintf('%s_%s_%s', params2.subj, params2.blocks.thisblock, label)), 'png');
    close(h);
