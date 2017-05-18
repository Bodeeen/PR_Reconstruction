function [ pattern ] = AutoPatID( im, expected_value )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

w = fft2(im);
power_spectra = abs(w).^2;

% range -> frequency range
dims = size(im);
range = [expected_value - 1, expected_value + 1];
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
[~, locs] = findpeaks(quadrants(1, :), 'minpeakdistance', 2, 'sortstr', 'descend');
% only those who are in the range
locs(locs > frange(1,1)) = [];
locs(locs < frange(1,2)) = [];
locx = locs(1); % the first one in case there are more
p = findpeakwidth(quadrants(:, 1), 'gaussian', locx, 1.5);
efx = dims(1) / (p(3) - 1);

%% then find peak in y-direction (period is efy)
[~, locs] = findpeaks(quadrants(:, 1), 'minpeakdistance', 2, 'sortstr', 'descend');
locs(locs > frange(2,1)) = [];
locs(locs < frange(2,2)) = [];
locy = locs(1);
p = findpeakwidth(quadrants(1, :), 'gaussian', locy, 1.5);
efy = dims(2) / (p(3) - 1);

%% now estimate the offset by comparing with a pattern of same frequency but zero offset
% this is less artifact prone than directly reading the phase from the
% fourier spectra

% phase in q1 only for now
phx  = angle(w(1, locx));
phy  = angle(w(locy, 1));

% compute reference, now uses sin.*sin instead of Göttingens sin+sin
[yi, xi] = ndgrid(1:dims(1), 1: dims(2));
ref = cos(pi * xi / efx).^2 .* cos(pi * yi / efy).^2;
w2 = fft2(ref);

ref_phx = angle(w2(locx, 1));
ref_phy = angle(w2(1, locy));

%% offsets are ex0 and ey0
ex0 = mod((ref_phx - phx) / (2 * pi), 1) * efx;
ey0 = mod((ref_phy - phy) / (2 * pi), 1) * efy;

%% High pass filter data image
im = double(im - min(im(:)));
ft = fftshift(fft2(im));
[yf, xf] = ndgrid(1:dims(1), 1: dims(2));
yf = yf - dims(1)/2;
xf = xf - dims(2)/2;
d = sqrt(xf.^2 + yf.^2);
cf = locx
sigma = 20
bpmask = exp(-(d-cf).^2/(2*sigma^2));
ftfilt = ft .* bpmask;

imfilt = real(ifft2(fftshift(ftfilt)));
imref = (imfilt - min(imfilt(:))).^2;

%% now we have good initial estimates for periods and offsets, so we now fit
% the pattern on the added data, which shows mostly the pattern,
% because the pattern was stationary and the sample was scanned

% initial parameters, lower and upper bounds
x0 = [efx, ex0, efy, ey0];
lb = [efx - 0.2, -Inf, efy - 0.2, -Inf];
ub = [efx + 0.2, Inf, efy + 0.2, Inf];

% we use fmincon for maximizing correlation of calculated pattern and addup
options = optimset('Display', 'off', 'UseParallel', 'never', 'Algorithm', 'active-set');

x = fmincon(@minimizer, double(x0), [], [], [], [], lb, ub, [], options);

function corr = minimizer(x)
    % pattern
    ref = cos(pi * (xi - x(2)) / x(1)).^2 .* cos(pi * (yi - x(4)) / x(3)).^2;
    % correlation
    corr = ref .* im;
    corr = sum(corr(:));
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