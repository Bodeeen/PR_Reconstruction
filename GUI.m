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

% Last Modified by GUIDE v2.5 06-Sep-2017 11:36:41

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
Cent_G_fwhm = str2double(handles.pinhole_edit.String);
BG_G_fwhm = str2double(handles.BGFWHM_edit.String);

UpdatePinholeGraph(handles)
switch handles.pattern_panel.SelectedObject.String
    case 'Microlenses'
        handles.expected_period = str2double(handles.ulens_period_edit.String);
    case 'Widefield'
        handles.expected_period = str2double(handles.wf_period_edit.String);
end
addpath(genpath('../PR_Reconstruction'))
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
spl = strsplit(filepath, '.');
if strcmp(spl{end}, 'hdf5')
    cropping_data = get_cropping_data(filepath);
    handles.cropping_data = cropping_data;
end
h = msgbox('This could be a second. Patience...','Importing data','help');
child = get(h,'Children');
delete(child(3))
raw_data = load_image_stack(filepath);
corrected_raw_data = frame_correction(raw_data);
handles.raw_data = corrected_raw_data;

handles.rotated_text.String = '';
set(handles.rotate_data_button,'Enable','on');

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
handles = guidata(hObject); %Get updated version of handles (necessary?)
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
run_reconstruction(hObject, eventdata, handles);



% --- Executes on button press in find_pattern.
function find_pattern_Callback(hObject, eventdata, handles)
% hObject    handle to find_pattern (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
find_pattern(hObject, eventdata, handles, 'auto')

% --- Executes on button press in find_pat_man.
function find_pat_man_Callback(hObject, eventdata, handles)
% hObject    handle to find_pat_man (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
find_pattern(hObject, eventdata, handles, 'man')


function ulens_period_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ulens_period_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ulens_period_edit as text
%        str2double(get(hObject,'String')) returns contents of ulens_period_edit as a double


UpdatePinholeGraph(handles)

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


UpdatePinholeGraph(handles)

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
function slider_Callback(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue = get(handles.slider,'Value');
set(handles.bg_sub_edit,'String', num2str(sliderValue))

handles = guidata(hObject);
update_recon_im(hObject, handles);
handles = guidata(hObject);
update_recon_axis(hObject, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
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
set(handles.slider,'Value', str2double(editValue))

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

slider_val = handles.slider.Value;
cent_g = str2double(handles.pinhole_edit.String);
bg_g = handles.BG_FWHM_check.Value * str2double(handles.BGFWHM_edit.String);
cb = handles.Const_bg_check.Value;
if isfield(handles, 'wf_im')
    save_image(handles.showing_im, slider_val, cent_g, bg_g, cb, filepath, 'tif', 'widefield', handles.wf_im);
else
    save_image(handles.showing_im, slider_val, cent_g, bg_g, cb, filepath, 'tif');
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
    if handles.pattern_cropping_opt.Value == 2
        handles.pattern_id_im = crop_image(handles.pattern_im, handles.cropping_data);
    else
        handles.pattern_id_im = handles.pattern_im;
    end
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


% --- Executes on button press in chessb_corr_but_old.
function chessb_corr_but_old_Callback(hObject, eventdata, handles)
% hObject    handle to chessb_corr_but_old (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = handles.showing_im;
square_side = sqrt(handles.nframes);
corrected = chessboard_correction_old(im, square_side);
handles.showing_im = corrected;
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
button = questdlg('Which format to you want to load?' ,'Format','.hdf5', '.h5','.tif','.hdf5');
if strcmp(button, '.hdf5')   
    D = dir(strcat(LoadDataPathName, '\*.hdf5'));
elseif strcmp(button, '.h5')
    D = dir(strcat(LoadDataPathName, '\*.h5'));
elseif strcmp(button, '.tif')
    D = dir(strcat(LoadDataPathName, '\*.tif'));
end
fileNames = {D([D.isdir] == 0)};  
fileNames = fileNames{1};
[~, file_indexes] = sort([fileNames.datenum]);

base_preset = [0 0 0];
base_preset(1) = str2double(handles.pinhole_edit.String) / str2double(handles.pixel_size_edit.String);
if handles.BG_FWHM_check.Value
    base_preset(2) = str2double(handles.BGFWHM_edit.String) / str2double(handles.pixel_size_edit.String);
end
if handles.Const_bg_check.Value
    base_preset(3) = 1;
end

pattern = handles.pattern;
frame = 0
slider_val = handles.slider.Value;
for i = file_indexes
    disp(strcat('Reconstructing: ', fileNames(i).name));
    frame = frame + 1;
    filepath = strcat(LoadDataPathName, '\', fileNames(i).name);
    raw_data = load_image_stack(filepath);
    corrected_raw_data = frame_correction(raw_data);
    imsize = size(corrected_raw_data);
    ssrot = str2double(handles.ssrot_edit.String);
    if handles.radio_ulens.Value() || handles.WF_recon_mode.Value == 2
        dbl_lines = str2double(handles.dbl_lines_edit.String);
        dbl_cols = str2double(handles.dbl_cols_edit.String);
        flip_ss = handles.flip_subsq_cb.Value;
        simp_pin = handles.simp_pin_cb.Value;
        microlens_recon_alg(hObject, handles, corrected_raw_data, imsize, pattern, base_preset, ssrot, flip_ss, simp_pin, dbl_lines, dbl_cols)
        handles = guidata(hObject); %Get updated version of handles (updated in microlens_recon_alg())
    else
        if handles.bleach_corr_check.Value
            data = bleaching_correction(corrected_raw_data, 'Additive');
        end
        camera_pixel = str2double(handles.pixel_size_edit.String);
        objp = 20 / camera_pixel;
        number_scanning_steps = sqrt(size(data,3)) - 1;
        shift_per_step = handles.expected_period / number_scanning_steps / camera_pixel;
        pinhole_size = str2double(handles.pinhole_edit.String);
        recon_gauss = str2double(handles.ReconGaussSize.String);
        if pinhole_size == recon_gauss
            [central_signal, bg_signal] = signal_extraction_fast(data, pattern, objp, shift_per_step, pinhole_size/camera_pixel);
        else
            [central_signal, bg_signal] = signal_extraction_STHLM2(data, pattern, objp, shift_per_step, pinhole_size/camera_pixel, recon_gauss/camera_pixel); 
        end
        handles.central_signal = central_signal;
        handles.bg_signal = bg_signal;
    end
    if handles.noise_corr_check.Value
        recon = (1-slider_val)*handles.central_signal_ncorr + slider_val*handles.bg_signal_ncorr;
    else
        recon = (1-slider_val)*handles.central_signal + slider_val*handles.bg_signal;
    end
    if frame == 1
        stack = recon;
    else
        stack = cat(3, stack, recon);
    end
end
skew_fac = str2double(handles.skew_fac_edit.String);
line_px = str2double(handles.line_px_edit.String);
lines_p_square = handles.fr_p_line;
if handles.hide_frame_cb.Value
    stack = stack(handles.fr_p_column + 1:end - handles.fr_p_column, handles.fr_p_line + 1:end - handles.fr_p_line,:);
end
if handles.multi_f_cb.Value
    stack = chessboard_correction_multi_f(stack, lines_p_square);
end
for i = 1:size(stack, 3)
    stack(:,:,i) = Skew_stripe_corr(skew_fac, line_px, stack(:,:,i), lines_p_square, handles.rotate_skewstripe_cb.Value);
end
cent_g = str2double(handles.pinhole_edit.String);
bg_g = str2double(handles.BGFWHM_edit.String);
cb = handles.Const_bg_check.Value;
save_image(stack, slider_val, cent_g, bg_g, cb, filepath, 'hdf5')
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





function skew_fac_edit_Callback(hObject, eventdata, handles)
% hObject    handle to skew_fac_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of skew_fac_edit as text
%        str2double(get(hObject,'String')) returns contents of skew_fac_edit as a double


% --- Executes during object creation, after setting all properties.
function skew_fac_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to skew_fac_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function line_px_edit_Callback(hObject, eventdata, handles)
% hObject    handle to line_px_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of line_px_edit as text
%        str2double(get(hObject,'String')) returns contents of line_px_edit as a double


% --- Executes during object creation, after setting all properties.
function line_px_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to line_px_edit (see GCBO)
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
skew_fac = str2double(handles.skew_fac_edit.String);
line_px = str2double(handles.line_px_edit.String);
lines_p_square = handles.fr_p_line;
handles.showing_im = Skew_stripe_corr(skew_fac, line_px, handles.showing_im, lines_p_square, handles.rotate_skewstripe_cb.Value);
update_recon_axis(hObject, handles)
guidata(hObject, handles);


% --- Executes on button press in reset_corr_btn.
function reset_corr_btn_Callback(hObject, eventdata, handles)
% hObject    handle to reset_corr_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_recon_im(hObject, handles)
handles = guidata(hObject);
update_recon_axis(hObject, handles)
guidata(hObject, handles);



function dbl_lines_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dbl_lines_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dbl_lines_edit as text
%        str2double(get(hObject,'String')) returns contents of dbl_lines_edit as a double


% --- Executes during object creation, after setting all properties.
function dbl_lines_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dbl_lines_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dbl_cols_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dbl_cols_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dbl_cols_edit as text
%        str2double(get(hObject,'String')) returns contents of dbl_cols_edit as a double


% --- Executes during object creation, after setting all properties.
function dbl_cols_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dbl_cols_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function BGFWHM_edit_Callback(hObject, ~, handles)
% hObject    handle to BGFWHM_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BGFWHM_edit as text
%        str2double(get(hObject,'String')) returns contents of BGFWHM_edit as a double

UpdatePinholeGraph(handles)

% --- Executes during object creation, after setting all properties.
function BGFWHM_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BGFWHM_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BG_FWHM_check.
function BG_FWHM_check_Callback(hObject, eventdata, handles)
% hObject    handle to BG_FWHM_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

UpdatePinholeGraph(handles)
% Hint: get(hObject,'Value') returns toggle state of BG_FWHM_check


% --- Executes on button press in Const_bg_check.
function Const_bg_check_Callback(hObject, eventdata, handles)
% hObject    handle to Const_bg_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UpdatePinholeGraph(handles)
% Hint: get(hObject,'Value') returns toggle state of Const_bg_check


% --- Executes on button press in Noise_corr_but.
function Noise_corr_but_Callback(hObject, eventdata, handles)
% hObject    handle to Noise_corr_but (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.central_signal handles.bg_signal] = Noise_corr(handles.central_signal, handles.bg_signal, handles.presets);
update_recon_im(hObject, handles)
handles = guidata(hObject);
update_recon_axis(hObject, handles)
Guidata(hObject, handles);


% --- Executes on button press in noise_corr_check.
function noise_corr_check_Callback(hObject, eventdata, handles)
% hObject    handle to noise_corr_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of noise_corr_check


% --- Executes on button press in show_denoised_check.
function show_denoised_check_Callback(hObject, eventdata, handles)
% hObject    handle to show_denoised_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_denoised_check
update_recon_im(hObject, handles);
handles = guidata(hObject);
update_recon_axis(hObject, handles);
handles = guidata(hObject);
guidata(hObject, handles);



function ssrot_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ssrot_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ssrot_edit as text
%        str2double(get(hObject,'String')) returns contents of ssrot_edit as a double


% --- Executes during object creation, after setting all properties.
function ssrot_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ssrot_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chessb_corr_but_new.
function chessb_corr_but_new_Callback(hObject, eventdata, handles)
% hObject    handle to chessb_corr_but_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.working_text.String = 'Correcting chessboard...'
im = handles.showing_im;
im = im - min(im(:));
square_side = sqrt(handles.nframes);
if handles.Sequential_cc_cb.Value
    corrected = chessboard_correction_pyramid(im, square_side);
else
    corrected = chessboard_correction_LS(im, square_side);
end
handles.showing_im = corrected;
handles.working_text.String = 'Finished correcting chessboard'
update_recon_axis(hObject, handles)
guidata(hObject, handles);


% --- Executes on button press in rotate_skewstripe_cb.
function rotate_skewstripe_cb_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_skewstripe_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rotate_skewstripe_cb


% --- Executes on button press in flip_subsq_cb.
function flip_subsq_cb_Callback(hObject, eventdata, handles)
% hObject    handle to flip_subsq_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flip_subsq_cb


% --- Executes on button press in simp_pin_cb.
function simp_pin_cb_Callback(hObject, eventdata, handles)
% hObject    handle to simp_pin_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of simp_pin_cb


% --- Executes on button press in Sh_err_im_cb.
function Sh_err_im_cb_Callback(hObject, eventdata, handles)
% hObject    handle to Sh_err_im_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_recon_axis(hObject, handles);
guidata(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of Sh_err_im_cb


% --- Executes on button press in hide_frame_cb.
function hide_frame_cb_Callback(hObject, eventdata, handles)
% hObject    handle to hide_frame_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
im = handles.recon_im;
if handles.hide_frame_cb.Value
    im = im(handles.fr_p_column + 1:end - handles.fr_p_column, handles.fr_p_line + 1:end - handles.fr_p_line);
end
handles.showing_im = im;
update_recon_axis(hObject, handles);
guidata(hObject, handles)
% Hint: get(hObject,'Value') returns toggle state of hide_frame_cb


% --- Executes on button press in multi_f_cb.
function multi_f_cb_Callback(hObject, eventdata, handles)
% hObject    handle to multi_f_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of multi_f_cb


% --- Executes on button press in Sequential_cc_cb.
function Sequential_cc_cb_Callback(hObject, eventdata, handles)
% hObject    handle to Sequential_cc_cb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Sequential_cc_cb



function rotate_data_edit_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_data_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotate_data_edit as text
%        str2double(get(hObject,'String')) returns contents of rotate_data_edit as a double


% --- Executes during object creation, after setting all properties.
function rotate_data_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotate_data_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rotate_data_button.
function rotate_data_button_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    angle = str2num(handles.rotate_data_edit.String);
    handles.raw_data = imrotate(handles.raw_data, angle, 'bicubic', 'crop');
    handles.rotated_text.String = 'Rotated!';
    set(handles.rotate_data_button,'Enable','off');
catch
    handles.rotated_text.String = 'Error!';
end

update_pattern_id_im(hObject, handles)
handles = guidata(hObject); %Get updated version of handles (necessary?)
guidata(hObject, handles)


% --- Executes on selection change in pattern_cropping_opt.
function pattern_cropping_opt_Callback(hObject, eventdata, handles)
% hObject    handle to pattern_cropping_opt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pattern_cropping_opt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pattern_cropping_opt


% --- Executes during object creation, after setting all properties.
function pattern_cropping_opt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pattern_cropping_opt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
