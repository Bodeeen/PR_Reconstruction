function UpdatePinholeGraph( handles, diff_lim_px, bg_sub )
%Calculate and plot the graph representing the pinhole shape, make sure
%this is kept up to date with how this is done in the signal extraction
%module
resolution = 10;
x = (1/resolution:(1/resolution):10) - 5;
fwhm_cent = resolution*diff_lim_px;
fwhm_bg = sqrt(2)*fwhm_cent;
g_cent = oneDGausskern(10*resolution,fwhm_cent);
g_bg = oneDGausskern(10*resolution, fwhm_bg);

pinhole = g_cent - bg_sub*g_bg;
axes(handles.pinhole_axis);
plot(x, pinhole)
xlabel('Pixels')
end

