[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');
filepath = strcat(LoadPathName, LoadFileName);

stack = load_image_stack(filepath);

px_xy = str2double(inputdlg('X-Y pixel size'))
px_z = str2double(inputdlg('Z pixel size'))

interpfac = px_z / px_xy;

zi = 1:1/interpfac:size(stack,3);
sizex = size(stack,2);
sizey = size(stack,1);
upsampled = zeros(sizey, sizex, length(zi));
h = waitbar(0,'Interpolating')
for i = 1:sizex
    waitbar(i/sizex)
    for j = 1:sizey
        upsampled(j,i,:) = interp1(squeeze(stack(j,i,:)), zi, 'spline');
    end
end
close(h)
imsidey = size(upsampled, 1);
imsidex = size(upsampled, 2);
imsidez = size(upsampled, 3);
h5create(strcat(LoadPathName, '\', 'Upsampled_stack.hdf5'),'/data', [imsidey imsidex imsidez])
h5write(strcat(LoadPathName, '\', 'Upsampled_stack.hdf5'),'/data', upsampled);