function UpdatePinholeGraph( handles, Cent_G_fwhm, BG_G_fwhm)
%Calculate and plot the graph representing the pinhole shape, make sure
%this is kept up to date with how this is done in the signal extraction
%module

size_nm = str2double(handles.ulens_period_edit.String);

x = (1:size_nm) - size_nm/2;
g_cent = oneDGausskern(size_nm,Cent_G_fwhm);
g_bg = oneDGausskern(size_nm, BG_G_fwhm);

axes(handles.pinhole_axis);
hold off
plot(x, g_cent)
hold on
plot(x, g_bg)
plot(x, ones(1, size_nm)/2);
xlabel('nm')
hold off
end

