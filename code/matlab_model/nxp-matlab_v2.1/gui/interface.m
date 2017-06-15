function varargout = interface(varargin)
% INTERFACE MATLAB code for interface.fig
%      INTERFACE, by itself, creates a new INTERFACE or raises the existing
%      singleton*.
%
%      H = INTERFACE returns the handle to a new INTERFACE or the handle to
%      the existing singleton*.
%
%      INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERFACE.M with the given input arguments.
%
%      INTERFACE('Property','Value',...) creates a new INTERFACE or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before interface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help interface

% Last Modified by GUIDE v2.5 23-Nov-2014 13:24:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @interface_OpeningFcn, ...
                   'gui_OutputFcn',  @interface_OutputFcn, ...
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

% --- Executes just before interface is made visible.
function interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to interface (see VARARGIN)

% Choose default command line output for interface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes interface wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = interface_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function density_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function density_Callback(hObject, eventdata, handles)
% hObject    handle to density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density as text
%        str2double(get(hObject,'String')) returns contents of density as a double
density = str2double(get(hObject, 'String'));
if isnan(density)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save the new density value
handles.metricdata.density = density;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function volume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function volume_Callback(hObject, eventdata, handles)
% hObject    handle to volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volume as text
%        str2double(get(hObject,'String')) returns contents of volume as a double
volume = str2double(get(hObject, 'String'));
if isnan(volume)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save the new volume value
handles.metricdata.volume = volume;
guidata(hObject,handles)

% --- Executes on button press in calculate.
function calculate_Callback(hObject, eventdata, handles)
% hObject    handle to calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%% CALL FRAMEWORK
handles.dualcore_tag.irc_val
andles.dualcore_tag.core1_f_val
andles.dualcore_tag.core2_f_val

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

initialize_gui(gcbf, handles, true);

% --- Executes when selected object changed in unitgroup.
function unitgroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in unitgroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (hObject == handles.english)
    set(handles.text4, 'String', 'lb/cu.in');
    set(handles.text5, 'String', 'cu.in');
    set(handles.text6, 'String', 'lb');
else
    set(handles.text4, 'String', 'kg/cu.m');
    set(handles.text5, 'String', 'cu.m');
    set(handles.text6, 'String', 'kg');
end

% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
if isreset == 1
    handles.dualcore_tag.irc_val = 12;
    handles.dualcore_tag.core1_f_val = 12;
    handles.dualcore_tag.core2_f_val = 12;
%     handles.metricdata.density = 0;
%     handles.metricdata.volume  = 0;
% 
%     set(handles.density, 'String', handles.metricdata.density);
%     set(handles.volume,  'String', handles.metricdata.volume);
%     set(handles.mass, 'String', 0);
% 
%     set(handles.unitgroup, 'SelectedObject', handles.english);
% 
%     set(handles.text4, 'String', 'lb/cu.in');
%     set(handles.text5, 'String', 'cu.in');
%     set(handles.text6, 'String', 'lb');

    % Update handles structure
    guidata(handles.figure1, handles);    
end




% --- Executes on button press in core1_type.
function core1_type_Callback(hObject, eventdata, handles)
% hObject    handle to core1_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function core1_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to core1_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in core2_type.
function core2_type_Callback(hObject, eventdata, handles)
% hObject    handle to core2_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function n_tasks_Callback(hObject, eventdata, handles)
% hObject    handle to n_tasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n_tasks as text
%        str2double(get(hObject,'String')) returns contents of n_tasks as a double


% --- Executes during object creation, after setting all properties.
function n_tasks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_tasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function task_var_Callback(hObject, eventdata, handles)
% hObject    handle to task_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of task_var as text
%        str2double(get(hObject,'String')) returns contents of task_var as a double


% --- Executes during object creation, after setting all properties.
function task_var_CreateFcn(hObject, eventdata, handles)
% hObject    handle to task_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in core2_type.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to core2_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function core1_f_val_Callback(hObject, eventdata, handles)
% hObject    handle to core1_f_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of core1_f_val as text
%        str2double(get(hObject,'String')) returns contents of core1_f_val as a double


% --- Executes during object creation, after setting all properties.
function core1_f_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to core1_f_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function core2_f_val_Callback(hObject, eventdata, handles)
% hObject    handle to core2_f_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of core2_f_val as text
%        str2double(get(hObject,'String')) returns contents of core2_f_val as a double


% --- Executes during object creation, after setting all properties.
function core2_f_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to core2_f_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function irc_val_Callback(hObject, eventdata, handles)
% hObject    handle to irc_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of irc_val as text
%        str2double(get(hObject,'String')) returns contents of irc_val as a double


% --- Executes during object creation, after setting all properties.
function irc_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to irc_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ntask_val_Callback(hObject, eventdata, handles)
% hObject    handle to ntask_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ntask_val as text
%        str2double(get(hObject,'String')) returns contents of ntask_val as a double


% --- Executes during object creation, after setting all properties.
function ntask_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ntask_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function var_val_Callback(hObject, eventdata, handles)
% hObject    handle to var_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of var_val as text
%        str2double(get(hObject,'String')) returns contents of var_val as a double


% --- Executes during object creation, after setting all properties.
function var_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to var_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in firstfit_val.
function firstfit_val_Callback(hObject, eventdata, handles)
% hObject    handle to firstfit_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of firstfit_val


% --- Executes on button press in rr_val.
function rr_val_Callback(hObject, eventdata, handles)
% hObject    handle to rr_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rr_val


% --- Executes on button press in maxpar_val.
function maxpar_val_Callback(hObject, eventdata, handles)
% hObject    handle to maxpar_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of maxpar_val



function sys_irc_freq_val_Callback(hObject, eventdata, handles)
% hObject    handle to sys_irc_freq_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sys_irc_freq_val as text
%        str2double(get(hObject,'String')) returns contents of sys_irc_freq_val as a double


% --- Executes during object creation, after setting all properties.
function sys_irc_freq_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sys_irc_freq_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in static_c1_val.
function static_c1_val_Callback(hObject, eventdata, handles)
% hObject    handle to static_c1_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of static_c1_val


% --- Executes on button press in static_c2_val.
function static_c2_val_Callback(hObject, eventdata, handles)
% hObject    handle to static_c2_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of static_c2_val


% --- Executes on button press in static_exe_button.
function static_exe_button_Callback(hObject, eventdata, handles)
% hObject    handle to static_exe_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sprintf('NOW GOING TO EXECUTE!')

clearvars -except hObject eventData handles

irc_freq =  str2num(get(handles.irc_val,'String'))
core_type = get(handles.core1_type,'String');

c1_type = core_type{get(handles.core1_type,'Value')}
c1_freq = str2num(get(handles.core1_f_val,'String'))

c2_type = core_type{get(handles.core2_type,'Value')}
c2_freq = str2num(get(handles.core2_f_val,'String'))

sys_irc_freq =  str2num(get(handles.sys_irc_freq_val,'String'))
sys_freq =  str2num(get(handles.sys_freq_val,'String'))

wc_p_den = str2num(get(handles.p_den_wc,'String'))
typ_p_den = str2num(get(handles.p_den_typ,'String'))
Processor.POW_DENSITY(wc_p_den,typ_p_den)

var = str2num(get(handles.var_val,'String'))

% Design Space Exploration WITH Core's Sleep Power
%%% GLOBALS
WITH_SYS_POW = 1;
WITHOUT_SYS_POW = 0;

%Number of queues sweeping util range
n_queues = 10;

%Set the IRC frequency to 12MHz -> sleep power != 0
Processor.IRC_FREQ(irc_freq);
Processor.SYS_IRC_FREQ(sys_irc_freq);
Processor.SYS_FREQ(sys_freq);
display(sprintf('IRC Freq = %d', Processor.IRC_FREQ()));

if strcmp(c1_type,'WC') == 1
    c1_d_type = Processor.WC;
else
    c1_d_type = Processor.TYP;
end
if strcmp(c2_type,'WC') == 1
    c2_d_type = Processor.WC; 
else
    c2_d_type = Processor.TYP;
end

proc_type = [c1_d_type c2_d_type];
freq_vec = [c1_freq c2_freq];
%Processor Set
procSets = ProcSet(2, '', proc_type, freq_vec);

% BENINI TASK SET WITH VARIABILITY
n_tasks = 2;
taskSet = TaskSet(n_tasks, n_queues, 'benini_var', procSets, var); 

% HIGH PARALLELISM DSE WITH SYSTEM POWER
dse2 = DSE(procSets, taskSet);
dse2 = dse2.runDynamic(WITH_SYS_POW);

% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in dyn_exe_button.
function dyn_exe_button_Callback(hObject, eventdata, handles)
% hObject    handle to dyn_exe_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sprintf('NOW GOING TO EXECUTE!')

%clearvars -except hObject eventData handles

%handles=guidata(gcf)

irc_freq =  str2num(get(handles.irc_val,'String'))
core_type = get(handles.core1_type,'String');

c1_type = core_type{get(handles.core1_type,'Value')}
c1_freq = str2num(get(handles.core1_f_val,'String'))

c2_type = core_type{get(handles.core2_type,'Value')}
c2_freq = str2num(get(handles.core2_f_val,'String'))

sys_irc_freq =  str2num(get(handles.sys_irc_freq_val,'String'))
sys_freq =  str2num(get(handles.sys_freq_val,'String'))

wc_p_den = str2num(get(handles.p_den_wc,'String'))
typ_p_den = str2num(get(handles.p_den_typ,'String'))
Processor.POW_DENSITY(wc_p_den,typ_p_den)

var = str2num(get(handles.var_val,'String'))

% Design Space Exploration WITH Core's Sleep Power
%%% GLOBALS
WITH_SYS_POW = 1;
WITHOUT_SYS_POW = 0;

%Number of queues sweeping util range
n_queues = 10;

%Set the IRC frequency to 12MHz -> sleep power != 0
Processor.IRC_FREQ(irc_freq);
Processor.SYS_IRC_FREQ(sys_irc_freq);
Processor.SYS_FREQ(sys_freq);
display(sprintf('IRC Freq = %d', Processor.IRC_FREQ()));

if strcmp(c1_type,'WC') == 1
    c1_d_type = Processor.WC;
else
    c1_d_type = Processor.TYP;
end
if strcmp(c2_type,'WC') == 1
    c2_d_type = Processor.WC; 
else
    c2_d_type = Processor.TYP;
end

proc_type = [c1_d_type c2_d_type];
freq_vec = [c1_freq c2_freq];
%Processor Set
procSets = ProcSet(2, '', proc_type, freq_vec);

% BENINI TASK SET WITH VARIABILITY
n_tasks = 2;
taskSet = TaskSet(n_tasks, n_queues, 'benini_var', procSets, var); 

% HIGH PARALLELISM DSE WITH SYSTEM POWER
dse2 = DSE(procSets, taskSet);
if (sys_freq == 0)
    dse2 = dse2.runStatic(WITHOUT_SYS_POW);
else
    dse2 = dse2.runStatic(WITH_SYS_POW);
end

dse2

% --- Executes when task_tag is resized.
function task_tag_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to task_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function sys_freq_val_Callback(hObject, eventdata, handles)
% hObject    handle to sys_freq_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sys_freq_val as text
%        str2double(get(hObject,'String')) returns contents of sys_freq_val as a double


% --- Executes during object creation, after setting all properties.
function sys_freq_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sys_freq_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in core1_type.
function core_1_type_Callback(hObject, eventdata, handles)
% hObject    handle to core1_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns core1_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from core1_type


% --- Executes during object creation, after setting all properties.
function core_1_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to core1_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in core2_type.
function core_2_type_Callback(hObject, eventdata, handles)
% hObject    handle to core2_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns core2_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from core2_type


% --- Executes during object creation, after setting all properties.
function core2_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to core2_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over static_exe_button.
function static_exe_button_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to static_exe_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function p_den_wc_Callback(hObject, eventdata, handles)
% hObject    handle to p_den_wc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of p_den_wc as text
%        str2double(get(hObject,'String')) returns contents of p_den_wc as a double


% --- Executes during object creation, after setting all properties.
function p_den_wc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_den_wc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function p_den_typ_Callback(hObject, eventdata, handles)
% hObject    handle to p_den_typ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of p_den_typ as text
%        str2double(get(hObject,'String')) returns contents of p_den_typ as a double


% --- Executes during object creation, after setting all properties.
function p_den_typ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_den_typ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
