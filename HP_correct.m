function [ corrected_data ] = HP_correct( data, HPC_map )
%Corrects the data for hot pixels according to a hot pixel correction map

frames = size(data, 3);
h = waitbar(0,'Correcting hot pixels...');
for i = 1:frames
    waitbar(i/frames);
    corrected_data(:,:,i) = double(data(:,:,i)) - double(HPC_map);
end
close(h)
end

