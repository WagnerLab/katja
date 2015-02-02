function [art_ds] = ecog_downsample_artifacts(art, params)

    art_fields = fieldnames(art);

    length_out = ceil(size(art.(art_fields{1}), 2) / params.analysis.compression);
    start_idx = params.analysis.compression - (params.analysis.compression * length_out - size(art.(art_fields{1}), 2)); % mimic decimate start index (doesn't always start at 1!)

    for iField = 1:length(art_fields)
        
        a_mat = art.(art_fields{iField});
        a_new = nan(size(art, 1), length_out);

        parfor iChan = 1:size(a_mat, 1)

            a_conv = conv(double(a_mat(iChan, :)), ones(2 * params.analysis.compression - 1, 1), 'same');
            a_conv = a_conv > 0;

            % mimic downsampling
            a_conv = a_conv(start_idx : params.analysis.compression : size(a_mat, 2));
            a_new(iChan, :) = a_conv;
            
        end

        art_ds.(art_fields{iField}) = a_new;
        
    end