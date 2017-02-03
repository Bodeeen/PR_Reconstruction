function [ cmats_corr ] = cmats_bleach_corr( cmats )
%cmats_bleach_corr

tot_sig_cent = mean(cmats.cmat_cent, 1);
tot_sig_bg = mean(cmats.cmat_bg, 1);

vcent = sgolayfilt(tot_sig_cent, 1, 101);
vcent = vcent / mean(vcent);
vmat_cent = sparse(diag(1./vcent));

vbg = sgolayfilt(tot_sig_bg, 1, 101);
vbg = vbg / mean(vbg);
vmat_bg = sparse(diag(1./vbg));



cmat_cent_corr = cmats.cmat_cent * vmat_cent;
cmat_bg_corr = cmats.cmat_bg * vmat_bg;

cmats_corr = struct('cmat_cent', cmat_cent_corr, 'cmat_bg', cmat_bg_corr);
end

