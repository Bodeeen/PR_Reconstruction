function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 09-Mar-2017 19:04:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;


% Update handles structure
set(handles.pattern_panel, 'SelectionChangeFcn',  @pattern_panel_SelectionChangeFcn);
set(handles.bleach_corr_check, 'Value', 1);
switch handles.pattern_panel.SelectedObject.String
    case 'Microlenses'
        handles.expected_period = str2double(handles.ulens_period_edit.String);
    case 'Widefield'
        handles.expected_period = str2double(handles.wf_period_edit.String);
end
guidata(hObject, handles);


% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function pattern_panel_SelectionChangeFcn(hObject, eventdata)
    handles = guidata(hObject);
    switch get(eventdata.NewValue,  'Tag' )
        case 'radio_ulens'
            handles.expected_period = str2double(handles.ulens_period_edit.String);
        case 'radio_wf'
            handles.expected_period = str2double(handles.wf_period_edit.String);
    end
    update_pattern_id_im(hObject, handles)
    handles = guidata(hObject); %Get updated version of handles
    guidata(hObject, handles)
            
function data_edit_Callback(hObject, eventdata, handles)
% hObject    handle to data_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of data_edit as text
%        str2double(get(hObject,'String')) returns contents of data_edit as a double


% --- Executes during object creation, after setting all properties.
function data_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end

function widefield_edit_Callback(hObject, eventdata, handles)
% hObject    handle to widefield_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of widefield_edit as text
%        str2double(get(hObject,'String')) returns contents of widefield_edit as a double


% --- Executes during object creation, after setting all properties.
function widefield_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to widefield_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pattern_edit_Callback(hObject, eventdata, handles)
% hObject    handle to pattern_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pattern_edit as text
%        str2double(get(hObject,'String')) returns contents of pattern_edit as a double


% --- Executes during object creation, after setting all properties.
function pattern_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pattern_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in widefield_edit.
function Load_widefield_Callback(hObject, eventdata, handles)
% hObject    handle to widefield_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');
filepath = strcat(LoadPathName, LoadFileName);
handles.widefield_edit.String = filepath;
wf_data = load_image_stack(filepath);
wf_im = mean(wf_data, 3);
handles.wf_im = wf_im;
guidata(hObject, handles)
axes(handles.wf_axis);
imshow(wf_im, []);

% --- Executes on button press in Load_data.
function Load_data_Callback(hObject, eventdata, handles)
% hObject    handle to Load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');
filepath = strcat(LoadPathName, LoadFileName);
handles.data_edit.String = filepath;
cropping_data = get_cropping_data(filepath);
h = msgbox('This could be a second. Patience...','Importing data','help');
child = get(h,'Children');
delete(child(3))
raw_data = load_image_stack(filepath);
corrected_raw_data = frame_correction(raw_data);
handles.cropping_data = cropping_data;
handles.raw_data = corrected_raw_data;
update_pattern_id_im(hObject, handles)
close(h)
handles = guidata(hObject);%Get updated version of handles
guidata(hObject, handles)


% --- Executes on button press in Load_pattern.
function Load_pattern_Callback(hObject, eventdata, handles)
% hObject    handle to Load_pattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');
filepath = strcat(LoadPathName, LoadFileName);
handles.pattern_edit.String = filepath;
pattern_data = load_image_stack(filepath);
pattern_im = mean(pattern_data, 3);
handles.pattern_im = pattern_im;
update_pattern_id_im(hObject, handles)
handles = guidata(hObject); %Get updated version of handles
guidata(hObject, handles)

% --- Executes on button press in Load_HPCmap.
function Load_HPCmap_Callback(hObject, eventdata, handles)
% hObject    handle to Load_HPCmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[LoadFileName,LoadPathName] = uigetfile({'*.*'}, 'Load data file');
filepath = strcat(LoadPathName, LoadFileName);
handles.HPCedit.String = filepath;
HPC_im = load_image(filepath);
handles.HPC_im = HPC_im;
% handles = guidata(hObject); %Get updated version of handles
guidata(hObject, handles)

% --- Executes on button press in HPCcorrbox.
function HPCcorrbox_Callback(hObject, eventdata, handles)
% hObject    handle to HPCcorrbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of HPCcorrbox
update_pattern_id_im(hObject, handles)
handles = guidata(hObject); %Get updated version of handles
guidata(hObject, handles)

% --- Executes on button press in run_reconstruction.
function run_reconstruction_Callback(hObject, eventdata, handles)
% hObject    handle to run_reconstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = handles.raw_data;
if handles.HPCcorrbox.Value && isfield(handles, 'HPC_im')
    data = HP_correct(data, handles.HPC_im);
end
handles.nframes = size(data, 3);

diff_limit_px = str2double(handles.pinhole_edit.String) / str2double(handles.pixel_size_edit.String);
imsize = size(data)
pattern = handles.pattern;
if handles.radio_ulens.Value() || handles.WF_recon_mode.Value == 2
    microlens_recon_alg(hObject, handles, data, imsize, pattern, diff_limit_px)
    handles = guidata(hObject); %Get updated version of handles (updated in microlens_recon_alg())
else
    if handles.bleach_corr_check.Value
        data = bleaching_correction(data, mode);
    end
    camera_pixel = str2double(handles.pixel_size_edit.String);
    objp = 20 / camera_pixel;
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
update_recon_axis(hObject, handles)
UpdatePinholeGraph(handles, diff_limit_px, handles.bg_sub_slider.Value)
handles = guidata(hObject); %Get updated version of handles (updated in update_recon_im())

guidata(hObject, handles);


% --- Executes on button press in find_pattern.
function find_pattern_Callback(hObject, eventdata, handles)
% hObject    handle to find_pattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
expected_period_px = handles.expected_period / str2double(handles.pixel_size_edit.String);
pattern_id_im = handles.pattern_id_im;
pattern = AutoPatID( pattern_id_im, expected_period_px )
handles.pattern = pattern;
grid_vectors = make_pattern_grid(pattern, size(pattern_id_im));
scale = 10;
axes(handles.pattern_axis);
imshow(imresize(pattern_id_im, scale), []);
hold on
plot(scale*grid_vectors.x_vec, scale*grid_vectors.y_vec, 'x')
hold off
guidata(hObject, handles)



function ulens_period_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ulens_period_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ulens_period_edit as text
%        str2double(get(hObject,'String')) returns contents of ulens_period_edit as a double


% --- Executes during object creation, after setting all properties.
function ulens_period_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ulens_period_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wf_period_edit_Callback(hObject, eventdata, handles)
% hObject    handle to wf_period_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wf_period_edit as text
%        str2double(get(hObject,'String')) returns contents of wf_period_edit as a double


% --- Executes during object creation, after setting all properties.
function wf_period_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wf_period_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pixel_size_edit_Callback(hObject, eventdata, handles)
% hObject    handle to pixel_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pixel_size_edit as text
%        str2double(get(hObject,'String')) returns contents of pixel_size_edit as a double


% --- Executes during object creation, after setting all properties.
function pixel_size_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pixel_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pinhole_edit_Callback(hObject, eventdata, handles)
% hObject    handle to pinhole_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pinhole_edit as text
%        str2double(get(hObject,'String')) returns contents of pinhole_edit as a double


% --- Executes during object creation, after setting all properties.
function pinhole_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pinhole_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function bg_sub_slider_Callback(hObject, eventdata, handles)
% hObject    handle to bg_sub_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue = get(handles.bg_sub_slider,'Value')
set(handles.bg_sub_edit,'String', num2str(sliderValue))
diff_limit_px = str2double(handles.pinhole_edit.String) / str2double(handles.pixel_size_edit.String);
UpdatePinholeGraph(handles, diff_limit_px, handles.bg_sub_slider.Value)
handles = guidata(hObject);
update_recon_im(hObject, handles);
handles = guidata(hObject);
update_recon_axis(hObject, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function bg_sub_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bg_sub_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function bg_sub_edit_Callback(hObject, eventdata, handles)
% hObject    handle to bg_sub_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bg_sub_edit as text
%        str2double(get(hObject,'String')) returns contents of bg_sub_edit as a double
editValue = get(handles.bg_sub_edit,'String')
set(handles.bg_sub_slider,'Value', str2double(editValue))
diff_limit_px = str2double(handles.pinhole_edit.String) / str2double(handles.pixel_size_edit.String);
UpdatePinholeGraph(handles, diff_limit_px, handles.bg_sub_slider.Value)
update_recon_im(hObject, handles);
handles = guidata(hObject);
update_recon_axis(hObject, handles);
handles = guidata(hObject);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function bg_sub_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bg_sub_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function update_recon_im(hObject, handles)
if isfield(handles, 'central_signal')
    axes(handles.recon_axis);
    handles.recon_im = handles.central_signal - handles.bg_sub_slider.Value*handles.bg_signal;
    handles.recon_uncorr = handles.recon_im;
    guidata(hObject, handles);
end

function update_recon_axis(hObject, handles)
if isfield(handles, 'recon_im')
    im = handles.recon_im;
    l_lim = handles.low_lim_slider.Value * max(handles.recon_im(:)) + (1 - handles.low_lim_slider.Value) * min(handles.recon_im(:));
    u_lim = handles.up_lim_slider.Value * max(handles.recon_im(:))  + (1 - handles.up_lim_slider.Value) * min(handles.recon_im(:));
    axes(handles.recon_axis);
    imshow(im, [min(l_lim, u_lim) max(l_lim, u_lim)]);
end
    
% --- Executes on button press in bleach_corr_check.
function bleach_corr_check_Callback(hObject, eventdata, handles)
% hObject    handle to bleach_corr_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bleach_corr_check


% --- Executes on selection change in bleach_corr_dropdown.
function bleach_corr_dropdown_Callback(hObject, eventdata, handles)
% hObject    handle to bleach_corr_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns bleach_corr_dropdown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bleach_corr_dropdown


% --- Executes during object creation, after setting all properties.
function bleach_corr_dropdown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bleach_corr_dropdown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filepath = handles.data_edit.String;

bg_sub_fac = handles.bg_sub_slider.Value;
diff_lim = str2double(handles.pinhole_edit.String);
if isfield(handles, 'wf_im')
    save_image(handles.recon_im, bg_sub_fac, diff_lim, filepath, 'tif', 'widefield', handles.wf_im);
else
    save_image(handles.recon_im, bg_sub_fac, diff_lim, filepath, 'tif');
end

% --- Executes on selection change in WF_recon_mode.
function WF_recon_mode_Callback(hObject, eventdata, handles)
% hObject    handle to WF_recon_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns WF_recon_mode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from WF_recon_mode


% --- Executes during object creation, after setting all properties.
function WF_recon_mode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WF_recon_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function update_pattern_id_im(hObject, handles)
% hObject    handle to WF_recon_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if handles.radio_ulens.Value == 1 && isfield(handles, 'raw_data')
    handles.pattern_id_im = mean(handles.raw_data, 3);
    if handles.HPCcorrbox.Value && isfield(handles, 'HPC_im')
        handles.pattern_id_im = handles.pattern_id_im - double(handles.HPC_im);
    end
    axes(handles.pattern_axis);
    imshow(handles.pattern_id_im, []);
   
elseif handles.radio_wf.Value == 1 && isfield(handles, 'pattern_im') && isfield(handles, 'raw_data')
    handles.pattern_id_im = crop_image(handles.pattern_im, handles.cropping_data);
    axes(handles.pattern_axis);
    imshow(handles.pattern_id_im, []);
end
guidata(hObject, handles);



% --- Executes on slider movement.
function low_lim_slider_Callback(hObject, eventdata, handles)
% hObject    handle to low_lim_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
update_recon_axis(hObject, handles);

% --- Executes during object creation, after setting all properties.
function low_lim_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to low_lim_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function up_lim_slider_Callback(hObject, eventdata, handles)
% hObject    handle to up_lim_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
update_recon_axis(hObject, handles);

% --- Executes during object creation, after setting all properties.
function up_lim_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to up_lim_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in chessb_corr_but.
function chessb_corr_but_Callback(hObject, eventdata, handles)
% hObject    handle to chessb_corr_but (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = handles.recon_im;
square_side = sqrt(handles.nframes);
corrected = chessboard_correction_add(im, square_side);
handles.recon_im = corrected;
update_recon_axis(hObject, handles)
guidata(hObject, handles);




function ReconGaussSize_Callback(hObject, eventdata, handles)
% hObject    handle to ReconGaussSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ReconGaussSize as text
%        str2double(get(hObject,'String')) returns contents of ReconGaussSize as a double


% --- Executes during object creation, after setting all properties.
function ReconGaussSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ReconGaussSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in Multi_frame_recon.
function Multi_frame_recon_Callback(hObject, eventdata, handles)
% hObject    handle to Multi_frame_recon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LoadDataPathName = uigetdir('C:\Users\andreas.boden\Documents\GitHub\PR_Reconstruction\Data', 'Choose folder containg ONLY the data');
D = dir(LoadDataPathName);
fileNames = {D([D.isdir] == 0)};  
fileNames = fileNames{1};
[~, file_indexes] = sort([fileNames.datenum]);

diff_limit_px = str2double(handles.pinhole_edit.String) / str2double(handles.pixel_size_edit.String);
pattern = handles.pattern;
frames = length(file_indexes)-1
frame = 0
bg_sub = handles.bg_sub_slider.Value;
for i = file_indexes(2:end)
    frame = frame + 1;
    filepath = strcat(LoadDataPathName, '\', fileNames(i).name);
    raw_data = load_image_stack(filepath);
    corrected_raw_data = frame_correction(raw_data);
    imsize = size(corrected_raw_data);
    if handles.radio_ulens.Value() || handles.WF_recon_mode.Value == 2
        microlens_recon_alg(hObject, handles, corrected_raw_data, imsize, pattern, diff_limit_px)
        handles = guidata(hObject); %Get updated version of handles (updated in microlens_recon_alg())
    else
        if handles.bleach_corr_check.Value
            data = bleaching_correction(data, mode);
        end
        camera_pixel = str2double(handles.pixel_size_edit.String);
        objp = 20 / camera_pixel;
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
    recon = handles.central_signal - bg_sub*handles.bg_signal;
    if frame == 1
        stack = recon;
    else
        stack = cat(3, stack, recon);
    end
end
diff_lim = str2double(handles.pinhole_edit.String);
save_image(stack, bg_sub, diff_lim, filepath, 'hdf5')
handles = guidata(hObject); %Get updated version of handles (updated in update_recon_im())

guidata(hObject, handles);



function HPCedit_Callback(hObject, eventdata, handles)
% hObject    handle to HPCedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HPCedit as text
%        str2double(get(hObject,'String')) returns contents of HPCedit as a double


% --- Executes during object creation, after setting all properties.
function HPCedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HPCedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function skew_nm_edit_Callback(hObject, eventdata, handles)
% hObject    handle to skew_nm_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of skew_nm_edit as text
%        str2double(get(hObject,'String')) returns contents of skew_nm_edit as a double


% --- Executes during object creation, after setting all properties.
function skew_nm_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to skew_nm_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function line_nm_edit_Callback(hObject, eventdata, handles)
% hObject    handle to line_nm_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of line_nm_edit as text
%        str2double(get(hObject,'String')) returns contents of line_nm_edit as a double


% --- Executes during object creation, after setting all properties.
function line_nm_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to line_nm_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in skew_stripe_corr.
function skew_stripe_corr_Callback(hObject, eventdata, handles)
% hObject    handle to skew_stripe_corr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
skew_nm = str2double(handles.skew_nm_edit.String)/str2double(handles.pixel_size_edit.String);
line_nm = str2double(handles.line_nm_edit.String)/str2double(handles.pixel_size_edit.String);
cols_p_square = sqrt(handles.nframes);
handles.recon_im = Skew_stripe_corr(skew_nm, line_nm, handles.recon_im, cols_p_square);
update_recon_axis(hObject, handles)
guidata(hObject, handles);


% --- Executes on button press in reset_corr_btn.
function reset_corr_btn_Callback(hObject, eventdata, handles)
% hObject    handle to reset_corr_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.recon_im = handles.recon_uncorr;
update_recon_axis(hObject, handles)
guidata(hObject, handles);
