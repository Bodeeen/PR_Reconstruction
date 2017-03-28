function [ cmats_corr ] = cmats_bleach_corr( cmats )
%cmats_bleach_corr

tot_sig_cent = mean(cmats(:,:,1), 1);

v = sgolayfilt(tot_sig_cent, 1, 101);
v = v / mean(v);
vmat_cent = sparse(diag(1./v));

cent_corr = cmats(:,:,1) * vmat_cent;
cmats(:,:,1) = cent_corr;
if size(cmats, 3) > 1
    tot_sig = mean(cmats(:,:,2), 1);

    v = sgolayfilt(tot_sig, 1, 101);
    v = v / mean(v);
    vmat_cent = sparse(diag(1./v));
    
    sig_corr = cmats(:,:,2) * vmat_cent;
    cmats(:,:,2) = sig_corr;
end

if size(cmats, 3) > 2
    tot_sig = mean(cmats(:,:,3), 1);

    v = sgolayfilt(tot_sig, 1, 101);
    v = v / mean(v);
    vmat_cent = sparse(diag(1./v));
    
    sig_corr = cmats(:,:,3) * vmat_cent;
    cmats(:,:,3) = sig_corr;
end

cmats_corr = cmats;

