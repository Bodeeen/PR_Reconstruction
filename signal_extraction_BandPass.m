function [cmats] = signal_extraction(data, presets)
% Given the pattern period and offset as well as the output pixel length
% and the scanning pixel length it constructs the central and peripheral
% signal frames as used in the publication: 'Nanoscopy with more than a
% hundred thousand "doughnuts"' by Andriy Chmyrov et al., to appear in
% Nature Methods, 2013
%
% pattern is the periods and offsets of the on-switched regions

%% error checks
assert(nargin == 2)

%Presets


%% data parameters
size_y = size(data, 1);
size_x = size(data, 2);
nframes = size(data, 3);

B = presets.B;
Ginv = presets.Ginv;
nnulls = presets.nulls_x * presets.nulls_y;
N_bases = size(B, 2)/nnulls;
pixels = size(B,1);
cmat = zeros(nnulls,nframes, N_bases);
%Calculate weights to correct for different pinholes having
%different "sum under gaussians"
% W_cent = 1./sum(B_cent, 1)';
% W_bg_1 = 1./sum(B_bg, 1)';

h = waitbar(0,'Pinholing...');
% for i = 1:nframes
%     waitbar(i/nframes);
%     frame = data(:,:,i);
%     f = double(reshape(frame,[numel(frame), 1]));
%     cmat_cent(:,i) = W_cent.*(B_cent'*f);
%     cmat_bg(:,i) = W_bg.*(B_bg'*f);
%     
% end

for i = 1:nframes
    waitbar(i/nframes);
    frame = data(:,:,i);
    f = double(reshape(frame,[numel(frame), 1]));
    cdual = B' * f;
    c = cdual' * Ginv;
    cmats(:,i,:) = reshape(c, [nnulls, 1, N_bases]);
end



close(h)

end


function shifted_im = shift_columns(im, pixels, columns_per_square)

    x_coords = 1:size(im, 2);

    x_coords = mod(x_coords, columns_per_square);
    selection_bool = mod(x_coords, 2) == 0;

    selection = im(:, selection_bool);

    size_selection_y = size(selection, 1);
    size_selection_x = size(selection, 2);
    [yi xi] = ndgrid(1:size_selection_y, 1:size_selection_x);

    yi_shifted = yi + pixels;

    shifted_selection = interp2(selection, xi, yi_shifted);
    shifted_selection(isnan(shifted_selection)) = min(im(:));
    im(:,selection_bool) = shifted_selection;
    shifted_im = im;

end









