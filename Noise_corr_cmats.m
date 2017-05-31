function [ cmats_corr ] = Noise_corr_cmats( cmats, presets )
%Function takes the cmats from the first LS-fitting and filteres the
%bg_data using a custom filtering function. The new filtered bg_data is
%then used to recalculate the in-focus data, hopefully with a slighly lower
%noise.
nnulls = presets.nulls_x * presets.nulls_y;
N_bases = size(presets.B, 2)/nnulls;
nframes = size(cmats, 2);

twostep = 1;
%%Filter the 3rd coefficients spatially (lowest frequency signal)
cmat_bg_filtered = Spat_filt_cmat_LS(cmats(:,:,N_bases));


C = [];
for i = 1:N_bases
    C = cat(1, C, cmats(:,:,i));
end




Bbg = presets.B(:, (N_bases-1)*nnulls + 1:end); %Bases for 3rd coeffs
B_new = presets.B(:,1:(N_bases-1)*nnulls); %Bases for 1st and 2nd coeffs
Ginv_new = inv(B_new'*B_new); %G matrix for 1st and 2nd coeffs

cdual = B_new'*(presets.B*C - Bbg*cmat_bg_filtered); %Dual coords of (data - filtered BG)
clear Bbg
c = cdual' * Ginv_new;
c_re = reshape(c, [nframes nnulls N_bases-1]);
cmats_corr = zeros(nnulls, nframes, N_bases);
cmats_corr(:,:,end) = cmat_bg_filtered;
for i = 1:N_bases-1
    cmats_corr(:,:,i) = c_re(:,:,i)';
end

if N_bases > 2 && twostep
    
    cmat_bg_filtered = Spat_filt_cmat_conv_sqbysq(cmats(:,:,N_bases-1), presets, 6, 3);

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

