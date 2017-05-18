function av_im = cmat2spotAv(cmat, presets)
% Returns an image of pixels corresponding to the average value for each
% microlens spot over the scan.
    nulls_x = presets.nulls_x;
    nulls_y = presets.nulls_y;

    av_vec = mean(cmat, 2);
    av_im = reshape(av_vec, [nulls_y nulls_x]);
end

