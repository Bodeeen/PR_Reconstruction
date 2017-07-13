function [ x_motions y_motions ] = Motion_detection_multiscan()


LoadDataPathName = uigetdir('C:\Users\andreas.boden\Documents\GitHub\PR_Reconstruction\Data', 'Choose folder containg ONLY the data');
button = questdlg('Which format to you want to load?' ,'Format','.hdf5', '.h5','.tif','.hdf5');
if strcmp(button, '.hdf5')   
    D = dir(strcat(LoadDataPathName, '\*.hdf5'));
elseif strcmp(button, '.h5')
    D = dir(strcat(LoadDataPathName, '\*.h5'));
elseif strcmp(button, '.tif')
    D = dir(strcat(LoadDataPathName, '\*.tif'));
end
fileNames = {D([D.isdir] == 0)};  
fileNames = fileNames{1};
[~, file_indexes] = sort([fileNames.datenum]);

x_motions = [];
y_motions = [];

for i = file_indexes
    
disp(strcat('Analysing: ', fileNames(i).name));
filepath = strcat(LoadDataPathName, '\', fileNames(i).name);
stack = double(load_image_stack(filepath));

[xm, ym] = Motion_detection_beads(stack);

x_motions = cat(1, x_motions, xm);
y_motions = cat(1, y_motions, ym);
end

end

