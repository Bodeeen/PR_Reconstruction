%Script for fiding the transform between two images. Note that one of the
%images is flipped horizontally when imported since the one of the cameras
%is flipped. This makes finding corresponding points easier. But also
%requiers that the stack is flipped when imported in the "Transform stack"
%script.


[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load moving file');
path = strcat(LoadPathName, LoadFileName);
moving = load_image(path);
moving = fliplr(moving./max(moving(:)));
[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load fixed file');
path = strcat(LoadPathName, LoadFileName);
fixed = load_image(path);
fixed = fixed./max(fixed(:));

% pf = FastPeakFind(fixed, 0.3, (fspecial('gaussian', 7,1)), 3, 2);
% pf = reshape(pf, [2 size(pf,1)/2 ])';
% pm = FastPeakFind(moving, 0.3, (fspecial('gaussian', 7,1)), 3, 2);
% pm = reshape(pm, [2 size(pm,1)/2 ])';
% figure
% hold off
% subplot(1,2,1)
% imshow(fixed,[])
% hold on
% plot(pf(:,1),pf(:,2),'r+')
% hold off
% subplot(1,2,2)
% imshow(moving,[])
% hold on
% plot(pm(:,1),pm(:,2),'r+')
% hold off

cpselect(moving,fixed);
pause
tform = estimateGeometricTransform(movingPoints,fixedPoints,'affine');
outputView = imref2d(size(fixed));
transed = imwarp(moving,tform, 'OutputView', outputView);

imshowpair(transed, fixed, 'Scaling', 'joint');