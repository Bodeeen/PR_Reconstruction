function [cmats, Ecmats] = signal_extraction_LS(data, presets)
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
cmats = zeros(nnulls,nframes, N_bases);
%Calculate weights to correct for different pinholes having
%different "sum under gaussians"
% W_cent = 1./sum(B_cent, 1)';
% W_bg_1 = 1./sum(B_bg, 1)';

% h = waitbar(0,'Pinholing...');
% for i = 1:nframes
%     waitbar(i/nframes);
%     frame = data(:,:,i);
%     f = double(reshape(frame,[numel(frame), 1]));
%     cmat_cent(:,i) = W_cent.*(B_cent'*f);
%     cmat_bg(:,i) = W_bg.*(B_bg'*f);
%     
% end

f = reshape(data, [size_y*size_x nframes]);

cdual = B' * double(f);
if presets.simp_pin
    cmats = cdual;
    Ecmats = [];
    return
end
c = cdual' * Ginv;
proj = B*c';
%e is the error in each pixel, esq the squared error.
e = double(f)-proj;
e = e.^2;
Ecmats = presets.SS_const_base' * e;

c_re = reshape(c, [nframes nnulls N_bases]);
cmats = zeros(nnulls, nframes, N_bases);
for i = 1:N_bases
    cmats(:,:,i) = c_re(:,:,i)';
end


end








