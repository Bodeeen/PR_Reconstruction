function update_recon_axis(hObject, handles)
if isfield(handles, 'recon_im')
    if handles.Sh_err_im_cb.Value
        im = handles.Error_im;
    else
        im = handles.showing_im;
    end
    l_lim = handles.low_lim_slider.Value * max(im(:)) + (1 - handles.low_lim_slider.Value) * min(im(:));
    u_lim = handles.up_lim_slider.Value * max(im(:))  + (1 - handles.up_lim_slider.Value) * min(im(:));
    axes(handles.recon_axis);
    imshow(im, [min(l_lim, u_lim) max(l_lim, u_lim)]);
end

