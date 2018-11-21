function run_reconstruction(hObject, eventdata, handles, active_set)
% hObject    handle to run_reconstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.working_text.String = 'Reconstructing image...'
data = handles.raw_data{active_set};
if handles.HPCcorrbox.Value && isfield(handles, 'HPC_im')
    data = HP_correct(data, handles.HPC_im);
end
handles.nframes = size(data, 3);

base_preset = [0 0 0];
base_preset(1) = str2double(handles.pinhole_edit.String) / str2double(handles.pixel_size_edit.String);
if handles.BG_FWHM_check.Value
    base_preset(2) = str2double(handles.BGFWHM_edit.String) / str2double(handles.pixel_size_edit.String);
end
if handles.Const_bg_check.Value
    base_preset(3) = 1;
end

imsize = size(data);
pattern = handles.pattern;
if handles.radio_ulens.Value() || handles.WF_recon_mode.Value == 2
    dbl_lines = str2double(handles.dbl_lines_edit.String);
    dbl_cols = str2double(handles.dbl_cols_edit.String);
    ssrot = str2double(handles.ssrot_edit.String);
    flip_ss = handles.flip_subsq_cb.Value;
    simp_pin = handles.simp_pin_cb.Value;
    microlens_recon_alg(hObject, handles, data, imsize, pattern, base_preset, ssrot, flip_ss, simp_pin, dbl_lines, dbl_cols)
    handles = guidata(hObject); %Get updated version of handles (updated in microlens_recon_alg())
else
    if handles.bleach_corr_check.Value
        data = bleaching_correction(data, 'Additive');
    end
    camera_pixel = str2double(handles.pixel_size_edit.String);
    objp = 20 / camera_pixel; %I think 20 is output pixel size
    number_scanning_steps = sqrt(size(data,3)) - 1;
    shift_per_step = handles.expected_period / number_scanning_steps / camera_pixel;
    pinhole_size = str2double(handles.pinhole_edit.String);
    recon_gauss = str2double(handles.ReconGaussSize.String);
    if pinhole_size == recon_gauss
        [central_signal bg_signal] = signal_extraction_fast(data, pattern, objp, shift_per_step, pinhole_size/camera_pixel);
    else
        [central_signal bg_signal] = signal_extraction_STHLM2(data, pattern, objp, shift_per_step, pinhole_size/camera_pixel, recon_gauss/camera_pixel); 
    end
    handles.central_signal = central_signal;
    handles.bg_signal = bg_signal;
end
update_recon_im(hObject, handles)
handles = guidata(hObject);
update_recon_axis(hObject, handles)
handles = guidata(hObject);
handles.working_text.String = 'Finished!'
guidata(hObject, handles)
end

