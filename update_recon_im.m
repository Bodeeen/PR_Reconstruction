function update_recon_im(hObject, handles)
if isfield(handles, 'central_signal')
    axes(handles.recon_axis);
    slider_val = handles.slider.Value;
    if handles.show_denoised_check.Value && isfield(handles, 'central_signal_ncorr')
        handles.recon_im = (1-slider_val)*handles.central_signal_ncorr + slider_val*handles.bg_signal_ncorr;
    else
        handles.recon_im = (1-slider_val)*handles.central_signal + slider_val*handles.bg_signal;
    end
    guidata(hObject, handles);
end

