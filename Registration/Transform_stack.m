

[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');

path = strcat(LoadPathName, LoadFileName);
Stack = fliplr(load_image_stack(path));
outputView = imref2d(size(fixed));
transed_stack = imwarp(Stack,tform, 'OutputView', outputView);
transed_stack(transed_stack == 0) = min(Stack(:));

slices = 3;
% assert(round(size(transed_stack, 3)/slices) == size(transed_stack, 3)/slices);
start1 = 1; start2 = size(transed_stack, 3)/slices + 1; start3 = 2*size(transed_stack, 3)/slices + 1;
S1 = transed_stack(:,:,start1:start2-1);
S2 = transed_stack(:,:,start2:start3-1);
S3 = transed_stack(:,:,start3:end);

h5create('Adj_stack_S1.h5','/data', size(S1), 'Datatype', 'uint16')
h5create('Adj_stack_S2.h5','/data', size(S2), 'Datatype', 'uint16')
h5create('Adj_stack_S3.h5','/data', size(S3), 'Datatype', 'uint16')
h5write('Adj_stack_S1.h5','/data', S1);
h5write('Adj_stack_S2.h5','/data', S2);
h5write('Adj_stack_S3.h5','/data', S3);