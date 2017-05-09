slices = inputdlg('Number of slices?');
slices = str2num(slices{1});
[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');

path = strcat(LoadPathName, LoadFileName);

data = load_image_stack(path);
trace = squeeze(mean(mean(data, 2), 1));

if round(sqrt(numel(trace)/slices)) ~= sqrt(numel(trace)/slices)
    trace = trace(2:end);
end

imside = sqrt(numel(trace)/slices);

trace_mat = reshape(trace, [imside^2, slices]);

stack = zeros(imside, imside, slices);

for s = 1:slices
    stack(:,:,s) = reshape(trace_mat(:, s), [imside imside]);
    stack(:,2:2:end,s) = flipud(stack(:,2:2:end,s));
end
name = strcat(LoadPathName, '3Dbeadscan.h5');

h5create(name,'/data', [imside imside slices])
h5write(name,'/data', stack);