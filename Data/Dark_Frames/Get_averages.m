averages = []
for i = 1:5
    disp(sprintf('Analysing file %d', i));
    file = h5read(sprintf('%d.hdf5',i), '/data');
    av = mean(file,3);
    averages(:,:,i) = av;
end
global_av = mean(averages,3);