function UpdatePinholeGraph( handles)
%Calculate and plot the graph representing the pinhole shape, make sure
%this is kept up to date with how this is done in the signal extraction
%module

size_nm = str2double(handles.ulens_period_edit.String);
Cent_G_fwhm = str2double(handles.pinhole_edit.String);
BG_G_fwhm = str2double(handles.BGFWHM_edit.String);

x = (1:size_nm) - size_nm/2;
bases = oneDGausskern(size_nm,Cent_G_fwhm);
if handles.BG_FWHM_check.Value
    bases = cat(1, bases, oneDGausskern(size_nm, BG_G_fwhm));
end
if handles.Const_bg_check.Value
    bases = cat(1, bases, ones(1, size_nm)/2);
end

axes(handles.pinhole_axis);
hold off
for i = 1:size(bases, 1)
    plot(x, bases(i,:))
    hold on
end
xlabel('nm')
hold off
end

