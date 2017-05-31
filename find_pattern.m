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
grid_vectors = make_pattern_grid(pattern, size(pattern_id_im));
scale = 10;
axes(handles.pattern_axis);
imshow(imresize(pattern_id_im, scale), []);
hold on
%We add scale/2 because an offset 4 in original image means the
%maximum is located on the center of pixel 4 i.e. between the pix3-pix4
%edge and pix4-pix5 edge. In the upsampled version, the aforementioned
%edges are at pix30-pix31 and pix40-pix41. The maximum is thus at
%pix35-pix36.
plot(scale*grid_vectors.x_vec - scale/2, scale*grid_vectors.y_vec - scale/2, 'x')
hold off
guidata(hObject, handles)

