function [ filt_cmat ] = Spat_filt_cmat( cmat, presets, filt_size, filt_fwhm)
%Takes a cmat as input and filteres is spatially. Very dependent om the
%cmat2image function

nulls_x = presets.nulls_x;
nulls_y = presets.nulls_y;
nulls = nulls_x*nulls_y;
fr_p_line = sqrt(size(cmat, 2));
fr_p_column = fr_p_line;

kern = Gausskern(filt_size, filt_fwhm);
kern = kern./sum(kern(:));

im = cmat2image(cmat, presets, 0, 0);
filtered = conv2(im, kern, 'same');
filt_cmat = zeros(size(cmat));
i = 1;
for tlpx = 1:fr_p_line:size(filtered, 2)
    for tlpy = 1:fr_p_column:size(filtered, 1)
       subsquare = filtered(tlpy:tlpy+fr_p_column-1, tlpx:tlpx+fr_p_line-1);
       subsquare = rot90(subsquare, 2);
       subsquare(:,1:2:end) = flipud(subsquare(:,1:2:end));
       ssvec = reshape(subsquare, [1, fr_p_column*fr_p_line]);
       filt_cmat(i,:) = ssvec;
       i = i+1;
    end
end


