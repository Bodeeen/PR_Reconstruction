function [ cmats_corr ] = cmats_bleach_corr( cmats, presets )
%cmats_bleach_corr

tot_sig_p_spot_cent = mean(cmats.cmat_cent, 2);
tot_sig_p_spot_bg = mean(cmats.cmat_bg, 2);

tot_cent_im = reshape(tot_sig_p_spot_cent, [presets.nulls_y presets.nulls_x]);
tot_bg_im = reshape(tot_sig_p_spot_cent, [presets.nulls_y presets.nulls_x]);


tot_sig_cent = mean(cmats.cmat_cent, 1);
tot_sig_bg = mean(cmats.cmat_bg, 1);

vcent = sgolayfilt(tot_sig_cent, 1, 101);
vcent = vcent - mean(vcent);
vbg = sgolayfilt(tot_sig_bg, 1, 101);
vbg = vbg - mean(vbg);

nulls = presets.nulls_x*presets.nulls_y;
corr_mat_cent = zeros(size(cmats.cmat_cent));
a = 0.0035
for i = 1:nulls
    corr_row = 1 + (a * vcent * tot_sig_p_spot_cent(i));
    corr_mat_cent(i,:) = corr_row;
end
corr_mat_bg = zeros(size(cmats.cmat_cent));
for i = 1:nulls
    corr_row = 1 + (a * vbg * tot_sig_p_spot_cent(i));
    corr_mat_bg(i,:) = corr_row;
end

cmat_cent_corr = cmats.cmat_cent ./ corr_mat_cent;
cmat_bg_corr = cmats.cmat_bg ./ corr_mat_bg;

cmats_corr = struct('cmat_cent', cmat_cent_corr, 'cmat_bg', cmat_bg_corr);
end

