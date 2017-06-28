[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load moving file');
path = strcat(LoadPathName, LoadFileName);
moving = imread(path);
moving = moving./max(moving(:));
[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load fixed file');
path = strcat(LoadPathName, LoadFileName);
fixed = imread(path);
fixed = flipud(fixed./max(fixed(:)));
imshowpair(moving, fixed,'Scaling','joint')

[optimizer, metric] = imregconfig('multimodal')

optimizer.InitialRadius = 0.009;
optimizer.Epsilon = 1.5e-4;
optimizer.GrowthFactor = 1.01;
optimizer.MaximumIterations = 300;

movingRegistered = imwarp(moving,tform,'OutputView',imref2d(size(fixed)));

figure
imshowpair(fixed, movingRegistered,'Scaling','joint')