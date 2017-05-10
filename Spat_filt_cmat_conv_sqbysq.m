function [ filt_cmat ] = Spat_filt_cmat_conv_sqbysq( cmat, presets, filt_size, filt_fwhm)
%Takes a cmat as input and filteres is spatially. Very dependent om the
%cmat2image function

fr_p_line = sqrt(size(cmat, 2));
fr_p_column = fr_p_line;

kern = Gausskern(filt_size, filt_fwhm);
kern = kern./sum(kern(:));
padsize = ceil(filt_size/2);

im = cmat2image(cmat, presets, 0, 0);
ssrot = presets.ssrot;
filt_cmat = zeros(size(cmat));
i = 1;
for tlpx = 1:fr_p_line:size(im, 2)
    for tlpy = 1:fr_p_column:size(im, 1)
       subsquare = im(tlpy:tlpy+fr_p_column-1, tlpx:tlpx+fr_p_line-1);
       padded = padarray(subsquare, [padsize padsize], 'replicate', 'both');
       filtered = conv2(padded, kern, 'same');
       filtered = filtered(padsize+1:padsize+fr_p_line, padsize+1:padsize+fr_p_column);
       subsquare = rot90(filtered, -ssrot);
       subsquare(:,1:2:end) = flipud(subsquare(:,1:2:end));
       ssvec = reshape(subsquare, [1, fr_p_column*fr_p_line]);
       filt_cmat(i,:) = ssvec;
       i = i+1;
    end
end


