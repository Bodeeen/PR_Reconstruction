function find_pattern(hObject, eventdata, handles, method)
% hObject    handle to find_pat_man (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
expected_period_px = handles.expected_period / str2double(handles.pixel_size_edit.String);
pattern_id_im = handles.pattern_id_im;
if strcmp(method, 'auto')
    pattern = AutoPatID( pattern_id_im, expected_period_px )
elseif strcmp(method, 'man')
    pattern = pattern_identification( pattern_id_im, expected_period_px )
end
handles.pattern = pattern;
guidata(hObject, handles)

