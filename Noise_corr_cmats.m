function [ cmats_corr ] = Noise_corr_cmats( cmats, presets )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
nnulls = presets.nulls_x * presets.nulls_y;
N_bases = size(presets.B, 2)/nnulls;
nframes = size(cmats, 2);

twostep = 1;

cmat_bg_filtered = Spat_filt_cmat_LS(cmats(:,:,N_bases));


C = [];
for i = 1:N_bases
    C = cat(1, C, cmats(:,:,i));
end




Bbg = presets.B(:, (N_bases-1)*nnulls + 1:end);
B_new = presets.B(:,1:(N_bases-1)*nnulls);
Ginv_new = inv(B_new'*B_new);

cdual = B_new'*(presets.B*C - Bbg*cmat_bg_filtered);
clear Bbg
c = cdual' * Ginv_new;
c_re = reshape(c, [nframes nnulls N_bases-1]);
cmats_corr = zeros(nnulls, nframes, N_bases);
cmats_corr(:,:,end) = cmat_bg_filtered;
for i = 1:N_bases-1
    cmats_corr(:,:,i) = c_re(:,:,i)';
end

if N_bases > 2 && twostep
    
    cmat_bg_filtered = Spat_filt_cmat_conv(cmats(:,:,N_bases-1), presets, 10, 4);

    C = [];
    for i = 1:N_bases-1
        C = cat(1, C, cmats_corr(:,:,i));
    end
    
    Bbg = B_new(:, (N_bases-2)*nnulls + 1:end);
    
    B2 = B_new(:,1:(N_bases-2)*nnulls);
    Ginv_2 = inv(B2'*B2);

    cdual = B2'*(B_new*C - Bbg*cmat_bg_filtered);
    clear Bbg
    c = cdual' * Ginv_2;
    c_re = reshape(c, [nframes nnulls N_bases-2]);
    cmats_corr(:,:,end-1) = cmat_bg_filtered;
    for i = 1:N_bases-2
        cmats_corr(:,:,i) = c_re(:,:,i)';
    end
    
end
end

