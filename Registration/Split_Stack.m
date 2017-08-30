%Script for splitting the stack resulted from the acquisition of more than one z plane
%and if needed transforming a whole stack given the transform matric tform.
%Note that the stack is flipped (fliplr) when imported, see description in
%"Find_transform" for explanaition.

[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');

path = strcat(LoadPathName, LoadFileName);

% transed_stack = load_image_stack(path);

Stack = fliplr(load_image_stack(path));
outputView = imref2d(size(fixed));
transed_stack = imwarp(Stack,tform, 'OutputView', outputView);
transed_stack(transed_stack == 0) = min(Stack(:));

slices = 4;

for i = 1:slices
    start1 = (i-1)*(size(transed_stack, 3)/slices) + 1; 
    start2 = (i)*(size(transed_stack, 3)/slices) + 1;
    SS = transed_stack(:,:,start1:start2-1);
    h5create(['r/Adj_stack_S' num2str(i) '.h5'],'/data', size(SS), 'Datatype', 'uint16')
    h5write(['r/Adj_stack_S' num2str(i) '.h5'],'/data', SS);
end


