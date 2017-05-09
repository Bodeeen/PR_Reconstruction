function corrected_final = chessboard_correction_LS(im, square_side)

% %temp
% im = im(1+32*12:40*32, 1+32*12:40*32);
% square_side = 32;
% assert(~rem(size(im, 2), square_side), 'Cannot find imside')
[up_lines, down_lines, right_lines, left_lines] = make_border_matrices(im, square_side);


% Find number of coefficients in each dimension
cx = size(up_lines, 2);
cy = size(right_lines, 1);
c = cx*cy;

%% Make left part of "equation matrix"

r_vec = reshape(right_lines', [numel(right_lines), 1]);
r_mat = diag(r_vec);

l_vec = reshape(left_lines', [numel(left_lines), 1]);
l_mat = diag(l_vec);
l_mat = circshift(l_mat, -1, 2);

UL = r_mat-l_mat;
LL = eye(size(UL));
LL = LL - circshift(LL, -1, 2);
mask_mat = true(size(UL));
mask_mat(:,cx:cx:end) = false;
mask_mat = reshape(mask_mat, [1,numel(mask_mat)]);

UL = UL(mask_mat);
UL = reshape(UL, [size(r_vec, 1) numel(UL)/size(r_vec, 1)]);
LL = LL(mask_mat);
LL = reshape(LL, [size(r_vec, 1) numel(LL)/size(r_vec, 1)]);

%% Make right part of "equation matrix"

d_vec = reshape(down_lines', [numel(down_lines), 1]);
d_mat = diag(d_vec);

u_vec = reshape(up_lines', [numel(up_lines), 1]);
u_mat = diag(u_vec);
u_mat = circshift(u_mat, -cx, 2);

UR = d_mat-u_mat;
LR = eye(size(UR));
LR = LR - circshift(LR, -cx, 2);
UR = UR(:,1:size(UL, 2));
LR = LR(:,1:size(UL, 2));

A = [UL UR];

x0 = cat(2, ones(1, c), zeros(1,c));

[U S V] = svd(A'); %http://cmp.felk.cvut.cz/cmp/courses/Y33ROV/Y33ROV_ZS20092010/Lectures/General/constrained_lsq.pdf
sol = V(:, end);

C = sol(1:cx*cy);
O = sol(cx*cy+1:end);

C_mat = reshape(C, [cx cy]);
C_mat = C_mat';


resize_fac = size(im)./size(C_mat);
assert(resize_fac(1) == resize_fac(2), 'Something strange here')
resize_fac = resize_fac(1);
C_im = imresize(C_mat, resize_fac, 'nearest');

corrected_right = C_mat .* right_lines;
corrected_left = C_mat .* left_lines;
corrected_im = C_im .* double(im);

corrected_im_norm = corrected_im - mean(corrected_im(:));
corrected_im_inv = -corrected_im_norm;

corrected_final = corrected_im_inv;

% [n_up_lines, n_down_lines, n_right_lines, n_left_lines] = make_border_matrices(corrected_im, square_side);
% figure
% subplot(1,2,1)
% imshow(im,[])
% subplot(1,2,2)
% imshow(corrected_im_inv,[])
end



