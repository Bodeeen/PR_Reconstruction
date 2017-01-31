
N = 0;
for i = 0:200:2000
    N = N+1;
    path = strcat('C:\Users\andreas.boden\Documents\GitHub\PR_Reconstruction\Data\3DbeadScan405_2\XY_scan_405_Z', num2str(i),'_rec.hdf5');

    data = load_image_stack(path);

    data(:,:,1) = data(:,:,2);
    data(:,:,end+1) = data(:,:,end);
    trace = mean(mean(data, 2), 1);

    imside = sqrt(size(data, 3));

    im = reshape(trace, [imside imside]);
    im(:,1:2:end,:) = flipud(im(:,1:2:end,:));
    imstack(:,:,N) = im;
end
h5create('3Dbeadscan.h5','/data', [imside imside size(imstack, 3)])
h5write('3Dbeadscan.h5','/data', imstack);