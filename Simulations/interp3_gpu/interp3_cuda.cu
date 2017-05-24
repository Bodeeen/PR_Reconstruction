__global__ void interp3_cuda(
	float * vOutput,
	int     nPoints,
	int     xSize,
	int     ySize,
	int     zSize,
	float * gridX,
	float * gridY,
	float * gridZ,
	float * vInput,
	float * xInterp,
	float * yInterp,
	float * zInterp)
{
	int idx = blockDim.x * (gridDim.x * blockIdx.y + blockIdx.x) + threadIdx.x;
	if (idx >= nPoints)
	{
		return;
	}
	
	float x = xInterp[idx];
	float y = yInterp[idx];
	float z = zInterp[idx];

	if (x < gridX[0] || x > gridX[xSize-1] || 
		y < gridY[0] || y > gridY[ySize-1] || 
		z < gridZ[0] || z > gridZ[zSize-1])
	{
		vOutput[idx] = 0.0f;
		return;
	}
	
	float x0, y0, z0, x1, y1, z1;
	int ibx, itx, iby, ity, ibz, itz, im;

	ibx = 0;
	itx = xSize - 1;
	while (ibx < (itx-1))
	{
		im = ((ibx + itx) >> 1);
		if (x <= gridX[im])
		{
			itx = im;
		}		
		else
		{
			ibx = im;
		}
	}
	x0 = gridX[ibx];
	x1 = gridX[itx];
		
	iby = 0;
	ity = ySize - 1;
	while (iby < (ity-1))
	{
		im = ((iby + ity) >> 1);
		if (y <= gridY[im])
		{
			ity = im;
		}		
		else
		{
			iby = im;
		}
	}
	y0 = gridY[iby];
	y1 = gridY[ity];

	ibz = 0;
	itz = zSize - 1;
	while (ibz < (itz-1))
	{
		im = ((ibz + itz) >> 1);
		if (z <= gridZ[im])
		{
			itz = im;
		}
		else
		{
			ibz = im;
		}
	}
	z0 = gridZ[ibz];
	z1 = gridZ[itz];

	int sliceDim = xSize * ySize;
	int zOff0 = sliceDim * ibz;
	int zOff1 = zOff0 + sliceDim;
	int yOff0 = ySize * ibx;
	int yOff1 = yOff0 + ySize;

	float ax0 = (x - x0) / (x1 - x0);
	float ay0 = (y - y0) / (y1 - y0);
	float az0 = (z - z0) / (z1 - z0);
	float ax1 = 1.0f - ax0;
	float ay1 = 1.0f - ay0;
	
	float v000 = vInput[zOff0 + yOff0 + iby];
	float v001 = vInput[zOff0 + yOff0 + ity];
	float v010 = vInput[zOff0 + yOff1 + iby];
	float v011 = vInput[zOff0 + yOff1 + ity];
	float v100 = vInput[zOff1 + yOff0 + iby];
	float v101 = vInput[zOff1 + yOff0 + ity];
	float v110 = vInput[zOff1 + yOff1 + iby];
	float v111 = vInput[zOff1 + yOff1 + ity];
	
	float v00 = v000 * ay1 + v001 * ay0;
	float v01 = v010 * ay1 + v011 * ay0;
	float v10 = v100 * ay1 + v101 * ay0;
	float v11 = v110 * ay1 + v111 * ay0;
	
	float v0 = v00 * ax1 + v01 * ax0;
	float v1 = v10 * ax1 + v11 * ax0;

	vOutput[idx] = v0 * (1.0f - az0) + v1 * az0;
}