function [pattern] = switching_pattern_identification(data, expected_value)
% Extracts the frequencies and offsets of the off switching pattern from
% the camera frame data as used in the publication: 'Nanoscopy with more
% than a hundred thousand "doughnuts"' by Andriy Chmyrov et al.,
% to appear in Nature Methods, 2013
%
% data are the camera frames, expected_value is the initial guess on the
% period of the pattern in pixels
%
% output is a vector with the following order:
%   - period in x-direction [pixels] (px)
%   - offset in x-direction [pixels] (x0)
%   - period in y-direction [pixels] (py)
%   - offset in y-direction [pixels] (y0)
% and the function for recreating the off switching pattern would be:
%   sin(pi * (x - x0) / px).^2 + sin(pi * (y - y0) / py).^2
%
% however here we use cosine instead of sine because we actually fit what
% we see, which is the pattern of on-switched molecules

%% error check
assert(nargin == 2, 'Not enough arguments!');
range = [expected_value - 0.5, expected_value + 0.5];

%% get dimensions
dims = size(data);
nframes = dims(3); % number of camera frames
dims = dims(1:2); % now xy dimension

%% compute the power spectrum of all camera frames and add up
power_spectra = zeros(dims);
for kf = 1 : nframes
    frame = data(:, :, kf);
    w = fft2(frame);
    power_spectra = power_spectra + abs(w).^2;
end

% range -> frequency range
frange(1,:) = [dims(1), dims(1)] ./ range;
frange(2,:) = [dims(2), dims(2)] ./ range;

%% we still have four identical quadrants, add them up
center = floor((dims - 1) / 2);
q1 = power_spectra(1 : center(1) + 1, 1 : center(2) + 1);
q2 = flipdim(power_spectra(1 : center(1) + 1, dims(2) - center(2) : dims(2)), 2);
q2 = circshift(q2, [0, 1]);
q3 = flipdim(power_spectra(dims(1) - center(1) : dims(1), 1 : center(2) + 1), 1);
q3 = circshift(q3, [1, 0]);
q4 = flipdim(flipdim(power_spectra(dims(1) - center(1) : dims(1), dims(2) - center(2) : dims(2)), 1), 2);
q4 = circshift(q4, [1, 1]);

% sum up
quadrants = double(q1 + q2 + q3 + q4);

%% find first and highest peak along x-direction (period is efx)
[~, locs] = findpeaks(quadrants(:, 1), 'minpeakdistance', 2, 'sortstr', 'descend');
% only those who are in the range
locs(locs > frange(1,1)) = [];
locs(locs < frange(1,2)) = [];
locx = locs(1); % the first one in case there are more
p = findpeakwidth(quadrants(:, 1), 'gaussian', locx, 1.5);
efx = dims(1) / (p(3) - 1);

%% then find peak in y-direction (period is efy)
[~, locs] = findpeaks(quadrants(1, :), 'minpeakdistance', 2, 'sortstr', 'descend');
locs(locs > frange(2,1)) = [];
locs(locs < frange(2,2)) = [];
locy = locs(1);
p = findpeakwidth(quadrants(1, :), 'gaussian', locy, 1.5);
efy = dims(2) / (p(3) - 1);

%% now estimate the offset by comparing with a pattern of same frequency but zero offset
% this is less artifact prone than directly reading the phase from the
% fourier spectra

% phase in q1 only for now
phx  = angle(w(locx, 1));
phy  = angle(w(1, locy));

% compute reference
[xi, yi] = ndgrid(1:dims(1), 1: dims(2));
ref = cos(pi * xi / efx).^2 + cos(pi * yi / efy).^2;
w2 = fft2(ref);

ref_phx = angle(w2(locx, 1));
ref_phy = angle(w2(1, locy));

%% offsets are ex0 and ey0
ex0 = mod((ref_phx - phx) / (2 * pi), 1) * efx;
ey0 = mod((ref_phy - phy) / (2 * pi), 1) * efy;


%% now we have good initial estimates for periods and offsets, so we now fit
% the pattern on the added data, which shows mostly the pattern,
% because the pattern was stationary and the sample was scanned
addup = sum(data, 3, 'double');

% initial parameters, lower and upper bounds
x0 = [efx, ex0, efy, ey0];
lb = [efx - 0.2, -Inf, efy - 0.2, -Inf];
ub = [efx + 0.2, Inf, efy + 0.2, Inf];

% we use fmincon for maximizing correlation of calculated pattern and addup
options = optimset('Display', 'off', 'UseParallel', 'never', 'Algorithm', 'active-set');
x = fmincon(@minimizer, double(x0), [], [], [], [], lb, ub, [], options);

% calculates the negative correlation between calculated pattern and addup
    function corr = minimizer(x)
        % pattern
        ref = cos(pi * (xi - x(2)) / x(1)).^2 + cos(pi * (yi - x(4)) / x(3)).^2;
        % correlation
        corr = ref .* addup;
        corr = mean(corr(:));
        corr = -corr;
    end

% normalize offsets to [0, period]
x(2) = mod(x(2), x(1));
x(4) = mod(x(4), x(3));

% output
pattern = x;

end

%% Extracts the width of a peak given ydata, the peak position and a peak
% function model; Output params=[background, amplitude, position, width]
function [params, model, chunk] = findpeakwidth(ydata, fun, pos, width0)

% error checks
if nargin < 4
    error('Not enough arguments given!');
end

if numel(ydata) ~= length(ydata)
    error('1D ydata required!');
end

% inbuilt peak functions: converting keywords to handles
if ~isa(fun, 'function_handle')
    switch fun
        case 'gaussian'
            fun = @peak_gaussian;
        otherwise
            error('Unknown peak function type!');
    end
end

% change to column vector and make xdata
ydata = reshape(ydata, numel(ydata), 1);
n = size(ydata, 1);

% reduce ydata and construct x
l = ceil(4 * width0);
start = max(1, pos - l);
stop = min(n, pos + l);
ydata = ydata(start:stop);
xdata = (start:stop)';

% assemble x0 and limits lb, ub
bg = min(ydata(:));
br = max(ydata(:)) - bg;
p0 = [bg, br, pos, width0];
lb = [0, 0, start, 0.5 * width0];
ub = [br + bg, 1.5 * br + bg, stop, 1.5 * width0];

% fit
opt = optimset('Display', 'off', 'MaxFunEvals', 50, 'MaxIter', 20);
params = lsqcurvefit(fun, p0, xdata, ydata, lb, ub, opt);

% results
model = fun(params, xdata);
chunk = ydata;

end

% internal fitting function
function y = peak_gaussian(p, xdata)
y = p(1) + p(2) * power(2., -(xdata - p(3)).^2 / (p(4) / 2)^2);
end