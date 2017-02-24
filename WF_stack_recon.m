LoadDataPathName = uigetdir('C:\Users\andreas.boden\Documents\GitHub\PR_Reconstruction\Data', 'Choose folder containg ONLY the data');
D = dir(LoadDataPathName);
fileNames = {D([D.isdir] == 0)};  
fileNames = fileNames{1};
[~, file_indexes] = sort([fileNames.datenum]);

frame_nr = 0;

for i = file_indexes(2:end)
    frame_nr = frame_nr + 1;
    filepath = strcat(LoadDataPathName, '\', fileNames(i).name);
    raw_data = load_image_stack(filepath);
    frame = mean(double(raw_data), 3);
    if frame_nr == 1
        stack = frame;
    else
        stack = cat(3, stack, frame);
    end
end
imsidey = size(stack, 1);
imsidex = size(stack, 2);
imsidez = size(stack, 3);
h5create(strcat(LoadDataPathName, '\', 'WF_Stack'),'/data', [imsidey imsidex imsidez])
h5write(strcat(LoadDataPathName, '\', 'WF_Stack'),'/data', stack);