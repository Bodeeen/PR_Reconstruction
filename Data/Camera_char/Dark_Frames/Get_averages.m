path = 'Gain_char\pwr2\';
averages = []
for i = 1:6
    disp(sprintf('Analysing file %d', i));
    file = sprintf('%d_rec.hdf5',i);
    file = h5read(strcat(path, file), '/data');
    av = mean(file,3);
    averages(:,:,i) = av;
end
global_av = mean(averages,3);