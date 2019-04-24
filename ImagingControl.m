% Main control of the imaging system using SLM
% This software can perform coordinate calibration, set up the depth of
% the imaging plane, load and switch holographic phase pattern on SLM, etc.
% Author: Weijian Yang, 2015-2019

% This program assumes the SLM is from BNS (Meadowlark Optics) or Holoeye
% To use this program, uncomment Line 92-96, 129-133, 144-148 in this file
% and uncomment Line 32 and 36 in "f_SLMActivation_Calibration.m"

function varargout = ImagingControl(varargin)
% IMAGINGCONTROL MATLAB code for ImagingControl.fig
%      IMAGINGCONTROL, by itself, creates a new IMAGINGCONTROL or raises the existing
%      singleton*.
%
%      H = IMAGINGCONTROL returns the handle to a new IMAGINGCONTROL or the handle to
%      the existing singleton*.
%
%      IMAGINGCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGINGCONTROL.M with the given input arguments.
%
%      IMAGINGCONTROL('Property','Value',...) creates a new IMAGINGCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImagingControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImagingControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImagingControl

% Last Modified by GUIDE v2.5 25-Oct-2017 14:41:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImagingControl_OpeningFcn, ...
                   'gui_OutputFcn',  @ImagingControl_OutputFcn, ...
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


% --- Executes just before ImagingControl is made visible.
function ImagingControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImagingControl (see VARARGIN)

% Choose default command line output for ImagingControl
handles.output = hObject;

% self defined parameters
CFG2;
handles.SLM_handles=[];                       % SLM handles
handles.f_SLMFocusCalFun=[];                  % fitted function of focal depth vs. effective NA
handles.tLaserSLM=[];                         % lateral transform matrix
handles.tLaserSLM_focusPlane=[];              % focal planes of the lateral transform matrix
handles.calImageSize=[];                      % lateral calibration image size

handles.SLMPreset=SLMPreset;
handles.ROIList=[];                           % xyz coordinate on the hologram table
handles.ROIWeight=[];                         % weight on the hologram table
handles.SLMPhase = [];                        % SLM phase pattern

handles.stateNum = 0;                         % number of SLM state
handles.ItineraryTableData = [];              % itinerary table data
handles.repetition = 10;                      % number of repetition
handles.SLMPhaseSet = [];                     % SLM phase pattern set for cycling
handles.ROIlistName = [];                     % file name of the SLM phase pattern

handles.applyAO = 0;                          % apply adaptive optics?
handles.adaptiveOpticsCal_phase = [];         % phase matrix calibrated by adaptive optics
handles.adaptiveOpticsCal_depth = [];         % corresponding depth for the phase matrix from adaptive optics

% initialize SLM
handles.SLM_handles=1;
% if strcmp(SLM, 'BNS')
%     handles.SLM_handles = BNS_SLMOverDrive_Initialize(calibratedRegionalLUTfileName, SLMInitializationImageFileName);
% else
%     handles.SLM_handles = Holoeye_SLM_LoadImage(zeros(SLMm, SLMn), SLM_M, SLM_N, SLMm0, SLMn0);
% end
weight=1;
objectiveNA=0.4;
f_SLMActivation_Calibration( handles.SLM_handles, [handles.SLMPreset 0], weight, objectiveNA, handles );  

set(handles.Status2_text, 'String', 'SLM Reset.');
drawnow;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ImagingControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ImagingControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CFG2;
% if strcmp(SLM, 'BNS')
%     BNS_SLMOverDrive_Close(handles.SLM_handles);
% else
%     close(handles.SLM_handles);
% end

delete(hObject);


% --- Executes on button press in Exit_button.
function Exit_button_Callback(hObject, eventdata, handles)
% hObject    handle to Exit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CFG2;
% if strcmp(SLM, 'BNS')
%     BNS_SLMOverDrive_Close(handles.SLM_handles);
% else
%     close(handles.SLM_handles);
% end

hf=findobj('Name','ImagingControl');
delete(hf);


function CalibrationFile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to CalibrationFile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CalibrationFile_edit as text
%        str2double(get(hObject,'String')) returns contents of CalibrationFile_edit as a double


% --- Executes during object creation, after setting all properties.
function CalibrationFile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CalibrationFile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BrowseCalibrationFile_button.
function BrowseCalibrationFile_button_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseCalibrationFile_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fileName,pathName] = uigetfile('*.mat');                        
if max(size(fileName)) == 1 | fileName == 0
    msgbox('No calibration file is selected.','error');
    return;
end
set(handles.CalibrationFile_edit, 'String', [pathName fileName]);

load([pathName fileName]);
handles.f_SLMFocusCalFun=f_SLMFocusCalFun;
handles.tLaserSLM=tLaserSLM;               
handles.tLaserSLM_focusPlane=tLaserSLM_focusPlane;
handles.calImageSize=calImageSize;

% sort AO by depth (small -> large)
[~,sort_indx] = sort(adaptiveOpticsCal_depth,'ascend');
handles.adaptiveOpticsCal_depth = adaptiveOpticsCal_depth(sort_indx);
handles.adaptiveOpticsCal_phase = adaptiveOpticsCal_phase(:,:,sort_indx);

set(handles.CalImageSize_edit, 'String', [num2str(calImageSize(1)) ' x ' num2str(calImageSize(2))]);
guidata(hObject, handles);


% --- Executes on button press in AddState_button.
function AddState_button_Callback(hObject, eventdata, handles)
% hObject    handle to AddState_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fileName,pathName] = uigetfile('*.mat');                        
if max(size(fileName)) == 1 | fileName == 0
    msgbox('No hologram file is selected.','error');
    return;
end
load([pathName fileName]);

handles.stateNum=handles.stateNum+1;
stateID=handles.stateNum;

handles.SLMPhaseSet{stateID}=SLMPhase;
handles.ROIlistName{stateID}=fileName;
handles.ItineraryTableData(stateID,1)=handles.stateNum;
tempData=[handles.ROIlistName' num2cell(handles.ItineraryTableData)];
set(handles.Itinerary_table,'Data',tempData);

guidata(hObject, handles);


% --- Executes on button press in DeleteState_button.
function DeleteState_button_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteState_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

deleteStateID=str2double(get(handles.DeleteState_edit, 'String'));
index=find(handles.ItineraryTableData(:,1)==deleteStateID);
if isempty(index)
    msgbox('No such state is found', 'Error');
    return;
else
    handles.stateNum=handles.stateNum-1;
    handles.ItineraryTableData(index,:)=[];
    handles.ROIlistName{index}=[];
    handles.SLMPhaseSet{index}=[];
    handles.ROIlistName=handles.ROIlistName(~cellfun('isempty',handles.ROIlistName));
    handles.SLMPhaseSet=handles.SLMPhaseSet(~cellfun('isempty',handles.SLMPhaseSet));
    
    tempData=[handles.ROIlistName' num2cell(handles.ItineraryTableData)];
    set(handles.Itinerary_table,'Data',tempData);
end

guidata(hObject, handles);


function DeleteState_edit_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteState_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DeleteState_edit as text
%        str2double(get(hObject,'String')) returns contents of DeleteState_edit as a double


% --- Executes during object creation, after setting all properties.
function DeleteState_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DeleteState_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Repetition_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Repetition_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Repetition_edit as text
%        str2double(get(hObject,'String')) returns contents of Repetition_edit as a double
handles.repetition=round(str2num(get(handles.Repetition_edit,'string')));

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function Repetition_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Repetition_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in StartExperiment_button.
function StartExperiment_button_Callback(hObject, eventdata, handles)
% hObject    handle to StartExperiment_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 CFG2;
 calllib('Blink_SDK_C', 'Write_overdrive_image', handles.SLM_handles, 1, handles.SLMPhaseSet{1}, 0, 0);
 
 
% start experiment and actuate SLM
 set(handles.StartExperiment_button,'enable','off');
 set(handles.Status_text, 'String', ['Current Repetition : 0; Experiment in progress...']); 
 drawnow;
 
 idx_lut = [2:handles.stateNum,1];
 for ii=1:handles.repetition
    for idx=1:handles.stateNum
        if strcmp(SLM, 'BNS')   % change the second to last parameter to 0 if there will not be an incoming trigger
            calllib('Blink_SDK_C', 'Write_overdrive_image', handles.SLM_handles, 1, handles.SLMPhaseSet{idx_lut(idx)}, 1, 0);
        else
            Holoeye_SLM_LoadImage( handles.SLMPhaseSet{idx_lut(idx)}, SLM_M, SLM_N, SLMm0, SLMn0, handles.SLM_handles, calibratedLUTFunctionfileName );
        end
    end
%     if mod(ii,50)==0
%         set(handles.Status_text, 'String', ['Current Repetition : ' num2str(ii)]);
%         drawnow;
%     end
 end

set(handles.Status_text, 'String', ['Current Repetition : ' num2str(handles.repetition) '; Experiment finished.']); 
set(handles.StartExperiment_button,'enable','on');
f_SLMActivation_Calibration( handles.SLM_handles, [handles.SLMPreset 0], 1, 0.4, handles );

guidata(hObject, handles);


% --- Executes on button press in SaveItinerary_button.
function SaveItinerary_button_Callback(hObject, eventdata, handles)
% hObject    handle to SaveItinerary_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uiputfile('*.mat','Save Itinerary List');
if max(size(file)) == 1 | file == 0
    msgbox('No file name input. Itinerary List file cannot be saved', 'Error');
    return;
end
ItineraryData.SLMPhaseSet = handles.SLMPhaseSet;
ItineraryData.ROIlistName=handles.ROIlistName;
ItineraryData.ItineraryTableData=handles.ItineraryTableData;
ItineraryData.stateNum=handles.stateNum;
ItineraryData.repetition=handles.repetition;

save([path file],'ItineraryData');

% --- Executes on button press in LoadItinerary_button.
function LoadItinerary_button_Callback(hObject, eventdata, handles)
% hObject    handle to LoadItinerary_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fileName,pathName] = uigetfile('*.mat');                        
if max(size(fileName)) == 1 | fileName == 0
    msgbox('No Itinerary List file is selected.','error');
    return;
end
load([pathName fileName]);
handles.SLMPhaseSet=ItineraryData.SLMPhaseSet;
handles.ROIlistName=ItineraryData.ROIlistName;
handles.ItineraryTableData=ItineraryData.ItineraryTableData;
handles.stateNum=ItineraryData.stateNum;
handles.repetition=ItineraryData.repetition;

tempData=[handles.ROIlistName' num2cell(handles.ItineraryTableData)];
set(handles.Itinerary_table,'Data',tempData);

set(handles.Repetition_edit, 'String', num2str(handles.repetition));

guidata(hObject, handles);


% --- Executes on button press in EmptyTable_button.
function EmptyTable_button_Callback(hObject, eventdata, handles)
% hObject    handle to EmptyTable_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ROIList=cell(4,3);
handles.ROIWeight=cell(4,1);
set(handles.ROI_table,'Data',[handles.ROIList handles.ROIWeight]); 

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in LoadHologram_button.
function LoadHologram_button_Callback(hObject, eventdata, handles)
% hObject    handle to LoadHologram_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.applyAO = get(handles.ApplyAO_checkbox, 'Value');

[fileName,pathName] = uigetfile('*.mat');                        
if max(size(fileName)) == 1 | fileName == 0
    msgbox('No ROI list file is selected.','error');
    return;
end
load([pathName fileName]);
set(handles.ROI_table,'Data',ROITableData);

rowNum=size(ROITableData,1); rowIndicator=zeros(1,rowNum);
for idx=1:rowNum
    rowIndicator(idx)=~isempty(ROITableData{idx,1});
end
realRowNum=sum(rowIndicator);

handles.ROIList=cell2mat(ROITableData(1:realRowNum,1:3));
handles.ROIWeight=cell2mat(ROITableData(1:realRowNum,4));

% acuatate the SLM
% ROI coordinate conversion
xyImage=handles.ROIList(:,1:2);
zImage=handles.ROIList(:,3)*1e-6;      % convert unit to [m]
xyp=zeros(size(xyImage));

% ROI x,y: the following consider different focus for tLaserSLM, use 'linearinterp' for fitting 
for idx=1:size(xyImage,1)
    [dump, zPositionID]=min(abs(handles.tLaserSLM_focusPlane-zImage(idx)));
    xyp(idx,:)=tforminv(handles.tLaserSLM{zPositionID},xyImage(idx,:));
    
    if length(handles.tLaserSLM_focusPlane)>1
        if zPositionID==1
            tempzID=[1 2];
        else if zPositionID==length(handles.tLaserSLM_focusPlane)
               tempzID=[length(handles.tLaserSLM_focusPlane)-1 length(handles.tLaserSLM_focusPlane)];
            else
                tempzID=[zPositionID-1 zPositionID zPositionID+1];
            end
        end
            
        for idx1=1:length(tempzID)
            xyTemp(idx1,:)=tforminv(handles.tLaserSLM{tempzID(idx1)},xyImage(idx,:));
        end
        
        [calFun1,dump1,dump2] = fit( handles.tLaserSLM_focusPlane(tempzID), xyTemp(:,1), 'linearinterp' );
        [calFun2,dump1,dump2] = fit( handles.tLaserSLM_focusPlane(tempzID), xyTemp(:,2), 'linearinterp' );

        xyp(idx,1)=calFun1(zImage(idx));
        xyp(idx,2)=calFun2(zImage(idx));        
    end
end

% ROI z
xyzp=zeros(size(xyp,1),3);
xyzp(:,1:2)=xyp;
xyzp(:,3)=zImage;
objectiveNA=handles.f_SLMFocusCalFun(xyzp(:,3));
weight=handles.ROIWeight;

handles.SLMxyzp=xyzp;                
handles.objectiveNA=objectiveNA;

% acuatate SLM
handles.SLMPhase=f_SLMActivation_Calibration( handles.SLM_handles, xyzp, weight, objectiveNA, handles );
%msgbox('SLM Actuated.', 'Confirmation');

for idx=1:3
    set(handles.Status2_text, 'String', '');
    drawnow;     pause(0.1);
    set(handles.Status2_text, 'String', 'New hologram loaded.');
    drawnow;     pause(0.1);
end

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in SaveHologram_button.
function SaveHologram_button_Callback(hObject, eventdata, handles)
% hObject    handle to SaveHologram_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ROITableData = get(handles.ROI_table,'Data');
rowNum=size(ROITableData,1); rowIndicator=zeros(1,rowNum);

for idx=1:rowNum
    rowIndicator(idx)=~isempty(ROITableData{idx,1});
end
realRowNum=sum(rowIndicator);

handles.ROIList=cell2mat(ROITableData(1:realRowNum,1:3));
handles.ROIWeight=cell2mat(ROITableData(1:realRowNum,4));

% ROI coordinate conversion
xyImage=handles.ROIList(:,1:2);
zImage=handles.ROIList(:,3)*1e-6;      % convert unit to [m]
xyp=zeros(size(xyImage));

% ROI x,y: the following consider different focus for tLaserSLM, use 'linearinterp' for fitting 
for idx=1:size(xyImage,1)
    [dump, zPositionID]=min(abs(handles.tLaserSLM_focusPlane-zImage(idx)));
    xyp(idx,:)=tforminv(handles.tLaserSLM{zPositionID},xyImage(idx,:));
    
    if length(handles.tLaserSLM_focusPlane)>1
        if zPositionID==1
            tempzID=[1 2];
        else if zPositionID==length(handles.tLaserSLM_focusPlane)
               tempzID=[length(handles.tLaserSLM_focusPlane)-1 length(handles.tLaserSLM_focusPlane)];
            else
                tempzID=[zPositionID-1 zPositionID zPositionID+1];
            end
        end
            
        for idx1=1:length(tempzID)
            xyTemp(idx1,:)=tforminv(handles.tLaserSLM{tempzID(idx1)},xyImage(idx,:));
        end
        
        [calFun1,dump1,dump2] = fit( handles.tLaserSLM_focusPlane(tempzID), xyTemp(:,1), 'linearinterp' );
        [calFun2,dump1,dump2] = fit( handles.tLaserSLM_focusPlane(tempzID), xyTemp(:,2), 'linearinterp' );

        xyp(idx,1)=calFun1(zImage(idx));
        xyp(idx,2)=calFun2(zImage(idx));        
    end
end

% ROI z
xyzp=zeros(size(xyp,1),3);
xyzp(:,1:2)=xyp;
xyzp(:,3)=zImage;
objectiveNA=handles.f_SLMFocusCalFun(xyzp(:,3));
weight=handles.ROIWeight;

handles.SLMxyzp=xyzp;                
handles.objectiveNA=objectiveNA;

% acuatate SLM
%handles.SLMPhase=f_SLMActivation_Calibration( handles.SLM_handles, xyzp, weight, objectiveNA, handles );
%msgbox('SLM Actuated.', 'Confirmation');

% save the hologram
[file,path] = uiputfile('*.mat','Save Hologram File');
if max(size(file)) == 1 | file == 0
    msgbox('No file name input. Hologram file cannot be saved', 'Error');
    return;
end
ROITableData = get(handles.ROI_table,'Data');
SLMPhase = handles.SLMPhase;
save([path file],'ROITableData','SLMPhase');

% Update handles structure
guidata(hObject,handles);


% --- Executes on button press in ActuateSLM_button.
function ActuateSLM_button_Callback(hObject, eventdata, handles)
% hObject    handle to ActuateSLM_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.applyAO = get(handles.ApplyAO_checkbox, 'Value');

ROITableData = get(handles.ROI_table,'Data');
rowNum=size(ROITableData,1); rowIndicator=zeros(1,rowNum);

for idx=1:rowNum
    rowIndicator(idx)=~isempty(ROITableData{idx,1});
end
realRowNum=sum(rowIndicator);

handles.ROIList=cell2mat(ROITableData(1:realRowNum,1:3));
handles.ROIWeight=cell2mat(ROITableData(1:realRowNum,4));

% ROI coordinate conversion
xyImage=handles.ROIList(:,1:2);
zImage=handles.ROIList(:,3)*1e-6;      % convert unit to [m]
xyp=zeros(size(xyImage));

% ROI x,y: the following consider different focus for tLaserSLM, use 'linearinterp' for fitting 
for idx=1:size(xyImage,1)
    [dump, zPositionID]=min(abs(handles.tLaserSLM_focusPlane-zImage(idx)));
    xyp(idx,:)=tforminv(handles.tLaserSLM{zPositionID},xyImage(idx,:));
    
    if length(handles.tLaserSLM_focusPlane)>1
        if zPositionID==1
            tempzID=[1 2];
        else if zPositionID==length(handles.tLaserSLM_focusPlane)
               tempzID=[length(handles.tLaserSLM_focusPlane)-1 length(handles.tLaserSLM_focusPlane)];
            else
                tempzID=[zPositionID-1 zPositionID zPositionID+1];
            end
        end
            
        for idx1=1:length(tempzID)
            xyTemp(idx1,:)=tforminv(handles.tLaserSLM{tempzID(idx1)},xyImage(idx,:));
        end
        
        [calFun1,dump1,dump2] = fit( handles.tLaserSLM_focusPlane(tempzID), xyTemp(:,1), 'linearinterp' );
        [calFun2,dump1,dump2] = fit( handles.tLaserSLM_focusPlane(tempzID), xyTemp(:,2), 'linearinterp' );

        xyp(idx,1)=calFun1(zImage(idx));
        xyp(idx,2)=calFun2(zImage(idx));        
    end
end

% ROI z
xyzp=zeros(size(xyp,1),3);
xyzp(:,1:2)=xyp;
xyzp(:,3)=zImage;
objectiveNA=handles.f_SLMFocusCalFun(xyzp(:,3));
weight=handles.ROIWeight;

handles.SLMxyzp=xyzp;                
handles.objectiveNA=objectiveNA;

% acuatate SLM
handles.SLMPhase=f_SLMActivation_Calibration( handles.SLM_handles, xyzp, weight, objectiveNA, handles );
%msgbox('SLM Actuated.', 'Confirmation');

for idx=1:3
    set(handles.Status2_text, 'String', '');
    drawnow;     pause(0.1);
    set(handles.Status2_text, 'String', 'New hologram loaded.');
    drawnow;     pause(0.1);
end

% Update handles structure
guidata(hObject,handles);


% --- Executes on button press in ResetSLM_button.
function ResetSLM_button_Callback(hObject, eventdata, handles)
% hObject    handle to ResetSLM_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
weight=1;
f_SLMActivation_Calibration( handles.SLM_handles, [handles.SLMPreset 0], weight, 0.4, handles );

set(handles.Status2_text, 'String', 'SLM Reset.');
drawnow;

% Update handles structure
guidata(hObject,handles);


function CalImageSize_edit_Callback(hObject, eventdata, handles)
% hObject    handle to CalImageSize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CalImageSize_edit as text
%        str2double(get(hObject,'String')) returns contents of CalImageSize_edit as a double


% --- Executes during object creation, after setting all properties.
function CalImageSize_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CalImageSize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NewCalibration_button.
function NewCalibration_button_Callback(hObject, eventdata, handles)
% hObject    handle to NewCalibration_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CalibrationControl(handles.SLM_handles);


% --- Executes when entered data in editable cell(s) in Itinerary_table.
function Itinerary_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to Itinerary_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.ItineraryTableData)
    return;
end

if eventdata.Indices(1) > handles.stateNum
    return;
end

% change sequence
if eventdata.Indices(2)==2 && ~isempty(eventdata.NewData)
    handles.ItineraryTableData(eventdata.Indices(1),1)=round(eventdata.NewData);
end

% rearrange sequence
[~,index] = sort(handles.ItineraryTableData(:,1),'ascend');
handles.ItineraryTableData=handles.ItineraryTableData(index,:);
handles.ROIlistName=handles.ROIlistName(index);
handles.SLMPhaseSet=handles.SLMPhaseSet(index);

tempData=[handles.ROIlistName' num2cell(handles.ItineraryTableData)];
set(handles.Itinerary_table,'Data',tempData);

guidata(hObject, handles);


% --- Executes on button press in ApplyAO_checkbox.
function ApplyAO_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyAO_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ApplyAO_checkbox
