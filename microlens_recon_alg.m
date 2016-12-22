function [ central_signal bg_signal ] = microlens_recon_alg( hObject, handles, data, imsize, pattern, diff_limit_px )
%Wrapper function for reconstruction alg with sthlm microlens approach

new_preset_inputs = struct('imsize', imsize, 'pattern', pattern, 'diff_lim_px', diff_limit_px)
if ~isfield(handles, 'last_preset_inputs') || ~isequal(new_preset_inputs, handles.last_preset_inputs);
    presets = make_presets(imsize, pattern, diff_limit_px);
else
    presets = handles.presets;
end
cmats = signal_extraction_BandPass(data, presets, diff_limit_px);
handles.central_signal = cmat2image(cmats.cmat_cent, presets); 
handles.bg_signal = cmat2image(cmats.cmat_bg, presets);

handles.last_preset_inputs = new_preset_inputs;
handles.presets = presets;
guidata(hObject, handles);
end

