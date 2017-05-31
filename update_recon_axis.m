function update_recon_axis(hObject, handles)
if isfield(handles, 'recon_im')
    if handles.Sh_err_im_cb.Value
        im = handles.Error_im;
    else
        im = handles.recon_im;
    end
    if handles.hide_frame_cb.Value
        im = im(handles.fr_p_column + 1:end - handles.fr_p_column, handles.fr_p_line + 1:end - handles.fr_p_line);
    end
    handles.showing_im = im;
    l_lim = handles.low_lim_slider.Value * max(im(:)) + (1 - handles.low_lim_slider.Value) * min(im(:));
    u_lim = handles.up_lim_slider.Value * max(im(:))  + (1 - handles.up_lim_slider.Value) * min(im(:));
    axes(handles.recon_axis);
    imshow(im, [min(l_lim, u_lim) max(l_lim, u_lim)]);
    guidata(hObject, handles);
end

