%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright:
% Jun Tan
% University of Texas Southwestern Medical Center
% Department of Radiation Oncology
% Last edited: 08/18/2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function vv = interp3_gpu(x, y, z, v, xi, yi, zi)

persistent k_interp3 gpu;

if isempty(k_interp3)
    gpu = gpuDevice;
    k_interp3 = parallel.gpu.CUDAKernel('interp3_cuda.ptx', 'interp3_cuda.cu');
    k_interp3.ThreadBlockSize = 512; % For optimal performance, manually test and select a number.
end

nPoints = numel(xi);
nBlocks = ceil(nPoints / k_interp3.ThreadBlockSize(1));
if nBlocks <= gpu.MaxThreadBlockSize(1)
    k_interp3.GridSize = nBlocks;
else
    k_interp3.GridSize = [gpu.MaxThreadBlockSize(1) ceil(nBlocks/gpu.MaxThreadBlockSize(1))];
end

g_vv = parallel.gpu.GPUArray.zeros(size(xi), 'single');

g_nPoints = gpuArray(int32(nPoints));
g_xSize = gpuArray(int32(length(x)));
g_ySize = gpuArray(int32(length(y)));
g_zSize = gpuArray(int32(length(z)));

g_x = gpuArray(single(x));
g_y = gpuArray(single(y));
g_z = gpuArray(single(z));
g_v = gpuArray(single(v));

g_xi = gpuArray(single(xi));
g_yi = gpuArray(single(yi));
g_zi = gpuArray(single(zi));

g_vv = feval(k_interp3, ...
    g_vv, g_nPoints, g_xSize, g_ySize, g_zSize, ...
    g_x, g_y, g_z, g_v, g_xi, g_yi, g_zi);

vv = gather(g_vv);

