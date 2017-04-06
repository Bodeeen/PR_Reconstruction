function [ filt_cmat ] = Spat_filt_cmat_LS(cmat)
%Takes a cmat as input and filteres is spatially. Very dependent om the
%cmat2image function

ss_side = sqrt(size(cmat, 2));

[xi,yi] = ndgrid(1:ss_side, 1:ss_side);
dcv = ones([ss_side^2 1]);
dx = xi - 0.5*ss_side;
dxc = dx;
dxc(:, 1:2:end) = flipud(dxc(:, 1:2:end));
dxv = reshape(dxc, [ss_side^2 1]);
d2xv = dxv .^2;
d3xv = dxv .^3;

dy = yi - 0.5*ss_side;
dyc = dy;
dyc(:, 1:2:end) = flipud(dy(:, 1:2:end));
dyv = reshape(dyc, [ss_side^2 1]);
d2yv = dyv .^ 2;
d3yv = dyv .^ 3;

d2xyv = (dxv-dyv).^2;
d2yxv = (dxv+dyv).^2;

di = sqrt(dx.^2 + dy.^2);
di(:, 1:2:end) = flipud(di(:, 1:2:end));
div = reshape(di, [ss_side^2 1]);
d2iv = div.^2;


B = [dcv dxv dyv d2xv d2yv d3xv d3yv d2xyv d2yxv div d2iv];
Ginv = B'*B;

c = B\cmat';
filt_cmat = (B*c)';









% nulls_x = presets.nulls_x;
% nulls_y = presets.nulls_y;
% nulls = nulls_x*nulls_y;
% fr_p_line = sqrt(size(cmat, 2));
% fr_p_column = fr_p_line;
% 
% kern = Gausskern(filt_size, filt_fwhm);
% kern = kern./sum(kern(:));
% 
% im = cmat2image(cmat, presets, 0, 0);
% filtered = conv2(im, kern, 'same');
% filt_cmat = zeros(size(cmat));
% i = 1;
% for tlpx = 1:fr_p_line:size(filtered, 2)
%     for tlpy = 1:fr_p_column:size(filtered, 1)
%        subsquare = filtered(tlpy:tlpy+fr_p_column-1, tlpx:tlpx+fr_p_line-1);
%        subsquare = rot90(subsquare, 2);
%        subsquare(:,1:2:end) = flipud(subsquare(:,1:2:end));
%        ssvec = reshape(subsquare, [1, fr_p_column*fr_p_line]);
%        filt_cmat(i,:) = ssvec;
%        i = i+1;
%     end
% end


