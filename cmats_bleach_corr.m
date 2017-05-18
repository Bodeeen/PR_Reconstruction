function [ cmats_corr ] = cmats_bleach_corr( cmats, presets )
%cmats_bleach_corr

tot_sig_cent = mean(cmats(:,:,1), 1);

v = sgolayfilt(tot_sig_cent, 1, 101);
v = v / mean(v);
vmat_cent = sparse(diag(1./v));

cent_corr = cmats(:,:,1) * vmat_cent;
cmats(:,:,1) = cent_corr;

if size(cmats, 3) > 1
%     tot_sig = mean(cmats(:,:,3), 1);
    bg = cmats(:,:,end);
    bg_im = reshape(bg, [presets.nulls_y presets.nulls_x size(bg, 2)]);
    bg_im_corr = bg_im;
    kern = Gausskern(20, 7);
    kern = kern./sum(kern(:));
    for i = 1:size(bg_im_corr, 3)
        bg_im_corr(:,:,i) = conv2(bg_im_corr(:,:,i), kern, 'same');
    end
    m = mean(bg_im_corr, 3);
    for i = 1:size(bg_im_corr, 3)
        bg_im_corr(:,:,i) = bg_im_corr(:,:,i) ./ m;
    end
    
    corrected = bg_im ./ bg_im_corr;
    corr_mat = reshape(corrected, [presets.nulls_y*presets.nulls_x size(bg, 2)]);
%     v = tot_sig;%sgolayfilt(tot_sig, 1, 101);
%     v = v / mean(v);
%     vmat_cent = sparse(diag(1./v));
%     
%     sig_corr = cmats(:,:,2) * vmat_cent;
    cmats(:,:,end) = corr_mat;
end

if size(cmats, 3) > 2
    tot_sig = mean(cmats(:,:,2), 1);
%     bg = cmats(:,:,2);
%     bg_im = reshape(cmats(:,:,2), [presets.nulls_y presets.nulls_x size(bg, 2)]);
%     bg_im_corr = bg_im;
%     kern = Gausskern(20, 7);
%     kern = kern./sum(kern(:));
%     for i = 1:size(bg_im_corr, 3)
%         bg_im_corr(:,:,i) = conv2(bg_im_corr(:,:,i), kern, 'same');
%     end
%     m = mean(bg_im_corr, 3);
%     for i = 1:size(bg_im_corr, 3)
%         bg_im_corr(:,:,i) = bg_im_corr(:,:,i) ./ m;
%     end
%     
%     corrected = bg_im ./ bg_im_corr;
%     corr_mat = reshape(corrected, [presets.nulls_y*presets.nulls_x size(bg, 2)]);
    v = sgolayfilt(tot_sig, 1, 101);
    v = v / mean(v);
    vmat_cent = sparse(diag(1./v));
    
    sig_corr = cmats(:,:,2) * vmat_cent;
    cmats(:,:,2) = sig_corr;
end



cmats_corr = cmats;

