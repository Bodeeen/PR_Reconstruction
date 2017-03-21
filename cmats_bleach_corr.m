function [ cmats_corr ] = cmats_bleach_corr( cmats )
%cmats_bleach_corr

tot_sig = mean(cmats(:,:,1), 1);

vcent = sgolayfilt(tot_sig, 1, 101);
vcent = vcent / mean(vcent);
vmat_cent = sparse(diag(1./vcent));

cmat_corr = cmats(:,:,1) * vmat_cent;

cmats(:,:,1) = cmat_corr;

cmats_corr = cmats;

