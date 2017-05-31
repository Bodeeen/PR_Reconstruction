function [ averaged ] = Average_recordings(  )
%Function that lets the user choose a file containing sevral file of
%recordings and the script opens all the files in order and returns the
%average of the averages of the recordings. (Note that this average only
%represents the global average if all the recordings contains the same
%number of frames.
addpath ../
LoadDataPathName = uigetdir('C:\Users\andreas.boden\Documents\GitHub\PR_Reconstruction\Data', 'Choose folder containg ONLY the data');
D = dir(strcat(LoadDataPathName, '\*.hdf5'));
fileNames = {D([D.isdir] == 0)};  
fileNames = fileNames{1};
[~, file_indexes] = sort([fileNames.datenum]);
frame = 0
h = waitbar(0, 'Averaging...');
for i = file_indexes
    frame = frame + 1;
    waitbar(frame/length(file_indexes));
    
    filepath = strcat(LoadDataPathName, '\', fileNames(i).name);
    raw_data = load_image_stack(filepath);
    
    av = mean(raw_data, 3);
    
    if frame == 1
        stack = av;
    else
        stack = cat(3, stack, av);
    end
    
end

averaged = uint16(mean(stack, 3));

end

