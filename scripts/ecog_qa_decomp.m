function ecog_qa_decomp(data, art, params, label)

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
        
        if all(isnan(data(iChan, :)))
            continue
        end
        
        h = figure('Visible', 'off', 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 12, 8]);

        % power spectrum of filtered data
        subplot(2, 3, 1);
        spct = spectrum.welch('hann', 2048, 80);
        plot(psd(spct, real(data(iChan, :)), 'Fs', params.recording.samp_rate,'nfft', 2048));
        xlim = get(gca, 'xlim');
        if xlim(2) < 10 % assume in KHz (better way to do this?)
            set(gca, 'XLim', [0 params.analysis.lowpass / 1000]);
        else
            set(gca, 'XLim', [0 params.analysis.lowpass]);
        end
        
        % histogram
        subplot(2, 3, 2); 
        hist(real(data(iChan, :)), 100);
        title(strrep(header, '_', ' '))

        % signal + art
        subplot(2, 3, 3)
        plot(abs(data(iChan, :)), 'k');

        if ~isempty(art)
            hold on;
            plot(find(art.signal(iChan, :)),   abs(data(iChan, art.signal(iChan, :) > 0)),   'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r')
            plot(find(art.gradient(iChan, :)), abs(data(iChan, art.gradient(iChan, :) > 0)), 'go', 'MarkerSize', 4, 'MarkerFaceColor', 'g')
            hold off
        end

        set(gca, 'XLim', [0 size(data, 2)]);
        title(strrep(header, '_', ' '))
        
        
        % subset of the data
        sbst = data(iChan, floor((size(data, 2)) / 2) - 500 : floor((size(data, 2) / 2)) + 500);
        
        subplot(2, 3, 4)
        plot(real(sbst));
        set(gca, 'XLim', [0 size(sbst, 2)]);
        title('filtered (real)');
        
        subplot(2, 3, 5)
        plot(abs(sbst));
        set(gca, 'XLim', [0 size(sbst, 2)]);
        title('amplitude (abs)');
        
        
        subplot(2, 3, 6)
        plot(angle(sbst));
        set(gca, 'XLim', [0 size(sbst, 2)]);
        title('phase (angle)');
        
        saveas(h, fullfile(params.dir.fig, label, sprintf('%s_chan%02d_%s.png', params.blocks.thisblock, iChan, label)), 'png');
        close(h)        

    end

    % summary
    h = figure('Visible', 'off', 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 12, 4]);
    
    subplot(1, 2, 1);
    imagesc(abs(data));
    title(sprintf('amplitude, %s', header));
    caxis([nanmean(abs(data(:))) - 7*nanstd(abs(data(:))) nanmean(abs(data(:))) + 7*nanstd(abs(data(:)))]);
    
    colormap('hot');
    freezeColors();
    
    
    subplot(1, 2, 2);
    imagesc(art.signal + 2*art.gradient);
    title(sprintf('art, %s', header));
    
    colormap('gray')
    
    saveas(h, fullfile(params.dir.fig, label, sprintf('%s_%s_%s', params.subj, params.blocks.thisblock, label)), 'png');
    close(h);
