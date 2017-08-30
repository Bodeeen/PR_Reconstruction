[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');

D = dir(strcat(LoadPathName, [LoadFileName(1:end-7) '*.hdf5']));%
slices = 4;

for j =1:length(D)
    
path = strcat(LoadPathName, D(j).name);
Stack = load_image_stack(path);
mkdir([LoadPathName D(j).name(1:end-5)])

for i = 1:slices
    start1 = (i-1)*(size(Stack, 3)/slices) + 1; 
    start2 = (i)*(size(Stack, 3)/slices) + 1;
    SS = Stack(:,:,start1:start2-1);
    h5create([LoadPathName D(j).name(1:end-5) '/Adj_stack_S' num2str(i) '.h5'],'/data', size(SS), 'Datatype', 'uint16')
    h5write([LoadPathName D(j).name(1:end-5) '/Adj_stack_S' num2str(i) '.h5'],'/data', SS);
end


end
