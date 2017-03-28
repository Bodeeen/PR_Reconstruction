function microlens_recon_alg( hObject, handles, data, imsize, pattern, base_preset, dbl_lines, dbl_cols)
%Wrapper function for reconstruction alg with sthlm microlens approach

new_preset_inputs = struct('imsize', imsize, 'pattern', pattern, 'base_preset', base_preset);
if ~isfield(handles, 'last_preset_inputs') || ~isequal(new_preset_inputs, handles.last_preset_inputs);
    presets = make_presets(imsize, pattern, base_preset);
else
    presets = handles.presets;
end
cmats = signal_extraction_BandPass(data, presets);

if handles.bleach_corr_check.Value
    cmats = cmats_bleach_corr(cmats);
end

[handles.central_signal, handles.fr_p_line, handles.fr_p_column] = cmat2image(cmats(:,:,1), presets, dbl_lines, dbl_cols);
cmat_bg = sum(cmats(:,:,2:end), 3);
handles.bg_signal = cmat2image(cmat_bg, presets, dbl_lines, dbl_cols);
% handles.central_signal = cmat2spotAv(cmats.cmat_cent, presets);
% handles.bg_signal = cmat2spotAv(cmats.cmat_cent, presets);

handles.last_preset_inputs = new_preset_inputs;
handles.presets = presets;
guidata(hObject, handles);
end

