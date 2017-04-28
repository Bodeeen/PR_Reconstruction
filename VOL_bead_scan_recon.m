slices = 18

[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');

path = strcat(LoadPathName, LoadFileName);

data = load_image_stack(path);
trace = squeeze(mean(mean(data, 2), 1));

if round(sqrt(numel(trace)/slices)) ~= sqrt(numel(trace)/slices)
    trace = trace(2:end);
end

imside = sqrt(numel(trace)/slices);

trace_mat = reshape(trace, [slices, imside^2]);

stack = zeros(imside, imside, slices);

for s = 1:slices
    start = 1 + (s-1)*imside^2;
    stop = start + imside^2;
    stack(:,:,s) = reshape(trace(start:stop), [imside imside]);
end