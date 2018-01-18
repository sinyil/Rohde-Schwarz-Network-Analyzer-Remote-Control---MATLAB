function varargout = networkAnalyzerDisplay(varargin)
% NETWORKANALYZERDISPLAY MATLAB code for networkAnalyzerDisplay.fig
%      NETWORKANALYZERDISPLAY, by itself, creates a new NETWORKANALYZERDISPLAY or raises the existing
%      singleton*.
%
%      H = NETWORKANALYZERDISPLAY returns the handle to a new NETWORKANALYZERDISPLAY or the handle to
%      the existing singleton*.
%
%      NETWORKANALYZERDISPLAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NETWORKANALYZERDISPLAY.M with the given input arguments.
%
%      NETWORKANALYZERDISPLAY('Property','Value',...) creates a new NETWORKANALYZERDISPLAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before networkAnalyzerDisplay_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to networkAnalyzerDisplay_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help networkAnalyzerDisplay

% Last Modified by GUIDE v2.5 17-Jan-2018 16:09:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @networkAnalyzerDisplay_OpeningFcn, ...
                   'gui_OutputFcn',  @networkAnalyzerDisplay_OutputFcn, ...
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

% --- Executes just before networkAnalyzerDisplay is made visible.
function networkAnalyzerDisplay_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to networkAnalyzerDisplay (see VARARGIN)

% Choose default command line output for networkAnalyzerDisplay
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.pushbutton1,'String','Show Traces on Channel 1');
set(handles.pushbutton2,'String','Save Figure');
set(handles.togglebutton1,'String','Start Autosave');
set(handles.edit1, 'String', 'Set the timer');
set(handles.edit2, 'String', 'Set the timer');

% UIWAIT makes networkAnalyzerDisplay wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = networkAnalyzerDisplay_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
timer1 = str2double(get(handles.edit1, 'String'));

set(handles.pushbutton1,'String','Taking data... Press to restart','BackGroundColor','green');
t1 = clock;
t3 = clock;

axes(handles.axes1);
countFigure = 0;
countFigureAfterAutosave = 0;
while 1
    t2 = clock;
    elapsedTime1 = etime(t2,t1);
    if elapsedTime1 >= timer1
        [stimulusValues, rawData, magdB, phaseAng] = MATLAB_directSCPI_NetworkAnalyzer_MNCL();
        
        % to plot the magnitude on the GUI
        plot(stimulusValues, magdB(:,:));
        xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title('Channel1');
        % to update the figure immediately
        drawnow;
        
        % to autosave the figure as .png or .xlsx
        if handles.togglebutton1.Value == 0
            set(handles.togglebutton1,'String','Start Autosave','BackGroundColor', [0.94 0.94 0.94]);
            countFigureAfterAutosave = 0;
            timer2 = str2double(get(handles.edit2, 'String'));
        elseif handles.togglebutton1.Value == 1
            t4 = clock;
            elapsedTime2 = etime(t4,t3);
            
            set(handles.togglebutton1,'String','Stop Autosaving','BackGroundColor','red');
            if elapsedTime2 >= timer2
                countFigureAfterAutosave = countFigureAfterAutosave + 1;
                
                rawDataSaved = rawData;
                magDataSaved = magdB;
                frequencyRange = stimulusValues;
                
                % to save rawData as .mat file
                %save(strcat('rawDataSaved',num2str(countFigureAfterAutosave*timer2),'.mat'),'rawDataSaved');
                
                % to save into an excel file. (.xlsx)
                xlswrite(strcat('C:\Users\Exper\Desktop\Sinan Y\MATLAB Network Analyzer\RawDataSaved\','rawDataSaved',num2str(countFigureAfterAutosave*timer2),'.xlsx'),rawDataSaved);
                
                % to save magnitude and frequency range vectors as .mat file
                %save(strcat('magDataSaved',num2str(countFigureAfterAutosave*timer2),'.mat'),'magDataSaved');
                %save(strcat('frequencyRange.mat'),'frequencyRange');
                
                % to capture the picture of the figure and save it in Current Folder
                %takeScreenShot(countFigureAfterAutosave*timer2);
                
                t3 = t4;
            end
        end
        
        t1 = t2;
        countFigure = countFigure + 1;
        set(handles.pushbutton1,'Value',countFigure*timer1);
    end
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
takeScreenShot(handles.pushbutton1.Value);

% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sweepPointsSet = get(handles.edit3, 'String');
netAnalyzer = VISA_Instrument('TCPIP::193.140.195.31::INSTR');
netAnalyzer.Write([':SWE:POIN ',sweepPointsSet]);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
startFreqSet = get(handles.edit4, 'String');
netAnalyzer = VISA_Instrument('TCPIP::193.140.195.31::INSTR');
netAnalyzer.Write([':FREQ:STAR ' startFreqSet ' GHz']);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stopFreqSet = get(handles.edit5, 'String');
netAnalyzer = VISA_Instrument('TCPIP::193.140.195.31::INSTR');
netAnalyzer.Write([':FREQ:STOP ',stopFreqSet,' GHz']);

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
        %to set S11 as default
        measure = 'S11';
    case 2
        measure = 'S11';
    case 3
        measure = 'S12';
    case 4
        measure = 'S21';
    case 5
        measure = 'S22';
end
netAnalyzer = VISA_Instrument('TCPIP::193.140.195.31::INSTR');
netAnalyzer.Write(':CONF:TRAC:CAT?');
traceCat = char(netAnalyzer.ReadString());
numberOfTraces = (size(strfind(traceCat,','),2)+1)/2;
%netAnalyzer.Write([':CALC1:PAR1:MEAS Trc1, ' measure]); % to change the trace, Trc1, parameter to selected one.
netAnalyzer.Write([':CALC1:PAR1:DEF Trc', num2str(numberOfTraces+1), ', ', measure]);
%netAnalyzer.Write(':DISP:WIND2:STAT ON'); %to open another window area, WIND2.
%netAnalyzer.Write([':DISP:WIND2:TRAC:FEED Trc', num2str(numberOfTraces+1)]); % to display Trc[] on the device display.

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
netAnalyzer = VISA_Instrument('TCPIP::193.140.195.31::INSTR');
netAnalyzer.Write('*RST');

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end