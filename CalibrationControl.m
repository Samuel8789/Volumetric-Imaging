% Calibration control menu: to initiate various calibrations and assemble
% calibration files
% Author: Weijian Yang, 2015-2019

function varargout = CalibrationControl(varargin)
% CALIBRATIONCONTROL MATLAB code for CalibrationControl.fig
%      CALIBRATIONCONTROL, by itself, creates a new CALIBRATIONCONTROL or raises the existing
%      singleton*.
%
%      H = CALIBRATIONCONTROL returns the handle to a new CALIBRATIONCONTROL or the handle to
%      the existing singleton*.
%
%      CALIBRATIONCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALIBRATIONCONTROL.M with the given input arguments.
%
%      CALIBRATIONCONTROL('Property','Value',...) creates a new CALIBRATIONCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CalibrationControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CalibrationControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CalibrationControl

% Last Modified by GUIDE v2.5 24-Oct-2017 15:38:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CalibrationControl_OpeningFcn, ...
                   'gui_OutputFcn',  @CalibrationControl_OutputFcn, ...
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


% --- Executes just before CalibrationControl is made visible.
function CalibrationControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CalibrationControl (see VARARGIN)

% Choose default command line output for CalibrationControl
handles.output = hObject;

% self defined parameters
handles.SLM_handles=varargin{1};                  % SLM handle
handles.f_SLMFocusCalFun=[];                      % fitted function of focal depth vs. effective NA
handles.tLaserSLM=[];                             % lateral calibration matrix
handles.tLaserSLM_focusPlane=[];                  % lateral calibration focusPlane
handles.tLaserSLM_focusPlaneNumber=0;             % lateral calibration, total focus plane loaded
handles.calImageSize=[];                          % lateral calibration, image size

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CalibrationControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CalibrationControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function AxialCalibrationFile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AxialCalibrationFile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AxialCalibrationFile_edit as text
%        str2double(get(hObject,'String')) returns contents of AxialCalibrationFile_edit as a double


% --- Executes during object creation, after setting all properties.
function AxialCalibrationFile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AxialCalibrationFile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BrowseAxialCalibration_button.
function BrowseAxialCalibration_button_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseAxialCalibration_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName,pathName] = uigetfile('*.mat');                        
if max(size(fileName)) == 1 | fileName == 0
    msgbox('No calibration file is selected.','error');
    return;
end
set(handles.AxialCalibrationFile_edit, 'String', [pathName fileName]);
load([pathName fileName]);
handles.f_SLMFocusCalFun=f_SLMFocusCalFun;
guidata(hObject, handles);


function LateralCalibrationFile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to LateralCalibrationFile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LateralCalibrationFile_edit as text
%        str2double(get(hObject,'String')) returns contents of LateralCalibrationFile_edit as a double


% --- Executes during object creation, after setting all properties.
function LateralCalibrationFile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LateralCalibrationFile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BrowseLateralCalibration_button.
function BrowseLateralCalibration_button_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseLateralCalibration_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName,pathName] = uigetfile('*.mat');                        
if max(size(fileName)) == 1 | fileName == 0
    msgbox('No calibration file is selected.','error');
    return;
end
set(handles.LateralCalibrationFile_edit, 'String', [pathName fileName]);
load([pathName fileName]);

if isempty(find(handles.tLaserSLM_focusPlane==focusPlane))
    handles.tLaserSLM_focusPlaneNumber=handles.tLaserSLM_focusPlaneNumber+1;
    handles.tLaserSLM_focusPlane=[handles.tLaserSLM_focusPlane; focusPlane];
    handles.tLaserSLM{handles.tLaserSLM_focusPlaneNumber}=tLaserSLM;                   
    
    set(handles.LateralCalibration_table,'Data',[handles.tLaserSLM_focusPlane*1e6 ones(handles.tLaserSLM_focusPlaneNumber,1)]);
end
handles.calImageSize=calImageSize;

guidata(hObject, handles);


% --- Executes on button press in NewAxialCalibration_button.
function NewAxialCalibration_button_Callback(hObject, eventdata, handles)
% hObject    handle to NewAxialCalibration_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CalibrationControl_AxialCalibration(handles.SLM_handles);


% --- Executes on button press in NewLateralCalibration_button.
function NewLateralCalibration_button_Callback(hObject, eventdata, handles)
% hObject    handle to NewLateralCalibration_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CalibrationControl_LateralCalibration(handles.SLM_handles);


% --- Executes on button press in SaveCalibration_button.
function SaveCalibration_button_Callback(hObject, eventdata, handles)
% hObject    handle to SaveCalibration_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uiputfile('*.mat','Save Calibration File');
if max(size(file)) == 1 | file == 0
    msgbox('No file name input. Calibration file cannot be saved', 'Error');
    return;
end

f_SLMFocusCalFun=handles.f_SLMFocusCalFun;
calImageSize=handles.calImageSize;

[tLaserSLM_focusPlane,index]=sort(handles.tLaserSLM_focusPlane);
for idx=1:handles.tLaserSLM_focusPlaneNumber
    tLaserSLM{idx}=handles.tLaserSLM{index(idx)};
end

if isfield(handles,'adaptiveOpticsCal_depth')
    adaptiveOpticsCal_depth=handles.adaptiveOpticsCal_depth;
    adaptiveOpticsCal_phase=handles.adaptiveOpticsCal_phase;
else
    adaptiveOpticsCal_depth = [];
    adaptiveOpticsCal_phase = [];
end

save([path file],'f_SLMFocusCalFun','tLaserSLM','tLaserSLM_focusPlane','calImageSize','adaptiveOpticsCal_depth','adaptiveOpticsCal_phase');


% --- Executes on button press in Exit_button.
function Exit_button_Callback(hObject, eventdata, handles)
% hObject    handle to Exit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hf=findobj('Name','CalibrationControl');
delete(hf);



function AdaptiveOpticsFile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AdaptiveOpticsFile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AdaptiveOpticsFile_edit as text
%        str2double(get(hObject,'String')) returns contents of AdaptiveOpticsFile_edit as a double


% --- Executes during object creation, after setting all properties.
function AdaptiveOpticsFile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AdaptiveOpticsFile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BrowseAdaptiveOptics_button.
function BrowseAdaptiveOptics_button_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseAdaptiveOptics_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName,pathName] = uigetfile('*.mat');                        
if max(size(fileName)) == 1 | fileName == 0
    msgbox('No adaptive optics file is selected.','error');
    return;
end
set(handles.AdaptiveOpticsFile_edit, 'String', [pathName fileName]);
load([pathName fileName]);
handles.adaptiveOpticsCal_depth=depth;
handles.adaptiveOpticsCal_phase=AOPhase;
guidata(hObject, handles);

