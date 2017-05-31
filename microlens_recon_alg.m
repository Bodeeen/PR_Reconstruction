function microlens_recon_alg( hObject, handles, data, imsize, pattern, base_preset, ssrot, flip_ss, simp_pin, dbl_lines, dbl_cols)
%Wrapper function for reconstruction alg with sthlm microlens approach

new_preset_inputs = struct('imsize', imsize, 'pattern', pattern, 'base_preset', base_preset, 'ssrot', ssrot, 'flip_ss', flip_ss, 'norm_g', simp_pin);
if ~isfield(handles, 'last_preset_inputs') || ~isequal(new_preset_inputs, handles.last_preset_inputs);
    presets = make_presets(imsize, pattern, base_preset, ssrot, flip_ss, simp_pin);
else
    presets = handles.presets;
end
[cmats, Ecmats] = signal_extraction_BandPass(data, presets);
if ~presets.simp_pin
    handles.Error_im = cmat2image(Ecmats, presets, 0, 0);
end
%In case of border bases causing super strange values
% cmats(cmats > 100*median(cmats(:))) = 0;%10*median(cmats(:));
% cmats(cmats < -100*median(cmats(:))) = 0;%-10*median(cmats(:));

if handles.bleach_corr_check.Value
    cmats = cmats_bleach_corr(cmats, presets);
end

[handles.central_signal, handles.fr_p_line, handles.fr_p_column] = cmat2image(cmats(:,:,1), presets, dbl_lines, dbl_cols);
cmat_bg = sum(cmats(:,:,2:end), 3);
handles.bg_signal = cmat2image(cmat_bg, presets, dbl_lines, dbl_cols);

if handles.noise_corr_check.Value
    cmats_corr = Noise_corr_cmats(cmats, presets);
    [handles.central_signal_ncorr, handles.fr_p_line, handles.fr_p_column] = cmat2image(cmats_corr(:,:,1), presets, dbl_lines, dbl_cols);
    cmat_bg = sum(cmats_corr(:,:,2:end), 3);
    handles.bg_signal_ncorr = cmat2image(cmat_bg, presets, dbl_lines, dbl_cols);
end


% handles.central_signal = cmat2spotAv(cmats.cmat_cent, presets);
% handles.bg_signal = cmat2spotAv(cmats.cmat_cent, presets);

handles.last_preset_inputs = new_preset_inputs;
handles.presets = presets;
guidata(hObject, handles);
end

