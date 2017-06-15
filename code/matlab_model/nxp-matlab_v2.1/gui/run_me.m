function varargout = run_me(varargin)
% RUN_ME MATLAB code for run_me.fig
%      RUN_ME, by itself, creates a new RUN_ME or raises the existing
%      singleton*.
%
%      H = RUN_ME returns the handle to a new RUN_ME or the handle to
%      the existing singleton*.
%
%      RUN_ME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUN_ME.M with the given input arguments.
%
%      RUN_ME('Property','Value',...) creates a new RUN_ME or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before run_me_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to run_me_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help run_me

% Last Modified by GUIDE v2.5 23-Nov-2014 13:30:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @run_me_OpeningFcn, ...
                   'gui_OutputFcn',  @run_me_OutputFcn, ...
                   'gui_LayoutFcn',  @run_me_LayoutFcn, ...
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

% --- Executes just before run_me is made visible.
function run_me_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to run_me (see VARARGIN)

% Choose default command line output for run_me
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes run_me wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = run_me_OutputFcn(hObject, eventdata, handles)
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


% --- Creates and returns a handle to the GUI figure. 
function h1 = run_me_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton)
    h1 = hsingleton;
    return;
end

appdata = [];
appdata.GUIDEOptions = struct(...
    'active_h', 220.007446289062, ...
    'taginfo', struct(...
    'figure', 2, ...
    'pushbutton', 16, ...
    'text', 44, ...
    'edit', 19, ...
    'frame', 4, ...
    'radiobutton', 19, ...
    'uipanel', 18, ...
    'popupmenu', 5, ...
    'checkbox', 8), ...
    'override', 1, ...
    'release', 13, ...
    'resize', 'simple', ...
    'accessibility', 'callback', ...
    'mfile', 1, ...
    'callbacks', 1, ...
    'singleton', 1, ...
    'syscolorfig', 1, ...
    'blocking', 0, ...
    'lastSavedFile', '/home/andres/gitlab/nxp-matlab/gui/run_me.m', ...
    'lastFilename', '/home/andres/gitlab/nxp-matlab/gui/interface.fig');
appdata.lastValidTag = 'figure1';
appdata.GUIDELayoutEditor = [];
appdata.initTags = struct(...
    'handle', [], ...
    'tag', 'figure1');

h1 = figure(...
'Color',[0.701960784313725 0.701960784313725 0.701960784313725],...
'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
'DockControls','off',...
'IntegerHandle','off',...
'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
'MenuBar','none',...
'Name','NXP Matlab GUI',...
'NumberTitle','off',...
'PaperPosition',get(0,'defaultfigurePaperPosition'),...
'PaperSize',[8.5 10],...
'PaperType','<custom>',...
'Position',[544 282 476 343],...
'HandleVisibility','callback',...
'UserData',[],...
'Tag','figure1',...
'Visible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'dual_core_tag';

h2 = uipanel(...
'Parent',h1,...
'Title','Dual-Core Properties',...
'UserData',[],...
'Clipping','on',...
'Position',[0.0147058823529412 0.326530612244898 0.460084033613445 0.565597667638484],...
'Tag','dual_core_tag',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'core1_t_tag';

h3 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'CData',[],...
'HorizontalAlignment','right',...
'ListboxTop',0,...
'Position',[0.0868217054263566 0.623044965786902 0.414728682170543 0.1],...
'String','Core 1 Type:',...
'Style','text',...
'UserData',[],...
'Tag','core1_t_tag',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'core2_f_tag';

h4 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'CData',[],...
'HorizontalAlignment','right',...
'ListboxTop',0,...
'Position',[0.0868217054263566 0.0913978494623657 0.414728682170543 0.1],...
'String','Core 2 Freq:',...
'Style','text',...
'UserData',[],...
'Tag','core2_f_tag',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'core1_f_tag';

h5 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'CData',[],...
'HorizontalAlignment','right',...
'ListboxTop',0,...
'Position',[0.0868217054263566 0.473729227761486 0.414728682170543 0.1],...
'String','Core 1 Freq:',...
'Style','text',...
'UserData',[],...
'Tag','core1_f_tag',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'core2_t_tag';

h6 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'CData',[],...
'HorizontalAlignment','right',...
'ListboxTop',0,...
'Position',[0.0868217054263566 0.252077223851418 0.414728682170543 0.1],...
'String','Core 2 Type:',...
'Style','text',...
'UserData',[],...
'Tag','core2_t_tag',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'core1_f_val';

h7 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)run_me('core1_f_val_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[0.558139534883721 0.462976539589444 0.232558139534884 0.118279569892473],...
'String','204',...
'Style','edit',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)run_me('core1_f_val_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','core1_f_val');

appdata = [];
appdata.lastValidTag = 'core1_mhz_tag';

h8 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Position',[0.790697674418605 0.430718475073314 0.201550387596899 0.129032258064516],...
'String','MHz',...
'Style','text',...
'Tag','core1_mhz_tag',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'core2_f_val';

h9 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)run_me('core2_f_val_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[0.558139534883721 0.0806451612903228 0.232558139534884 0.118279569892473],...
'String','204',...
'Style','edit',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)run_me('core2_f_val_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','core2_f_val');

appdata = [];
appdata.lastValidTag = 'core2_mhz_tag';

h10 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Position',[0.790697674418605 0.0483870967741938 0.201550387596899 0.129032258064516],...
'String','MHz',...
'Style','text',...
'Tag','core2_mhz_tag',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'irc_tag';

h11 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'CData',[],...
'HorizontalAlignment','right',...
'ListboxTop',0,...
'Position',[0.013953488372093 0.823863636363636 0.493023255813953 0.107954545454545],...
'String','Sleep Freq (IRC):',...
'Style','text',...
'UserData',[],...
'Tag','irc_tag',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'irc_val';

h12 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)run_me('irc_val_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[0.562015503875969 0.815371456500489 0.232558139534884 0.118279569892473],...
'String','12',...
'Style','edit',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)run_me('irc_val_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','irc_val');

appdata = [];
appdata.lastValidTag = 'irc_mhz_tag';

h13 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Position',[0.795348837209302 0.789772727272727 0.2 0.130681818181818],...
'String','MHz',...
'Style','text',...
'Tag','irc_mhz_tag',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'core1_type';

h14 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)run_me('core1_type_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[0.558139534883721 0.619318181818182 0.3 0.130681818181818],...
'String',{  'Type'; 'WC'; 'TYP' },...
'Style','popupmenu',...
'Value',2,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)run_me('core1_type_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','core1_type');

appdata = [];
appdata.lastValidTag = 'core2_type';

h15 = uicontrol(...
'Parent',h2,...
'Units','normalized',...
'Callback',@(hObject,eventdata)run_me('core2_type_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[0.562790697674419 0.244318181818182 0.302325581395349 0.130681818181818],...
'String',{  'Type'; 'WC'; 'TYP' },...
'Style','popupmenu',...
'Value',3,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)run_me('core2_type_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','core2_type');

appdata = [];
appdata.lastValidTag = 'sysperiph_tag';

h16 = uibuttongroup(...
'Parent',h1,...
'Title','System Peripherals',...
'Clipping','on',...
'Position',[0.5 0.606413994169096 0.485294117647059 0.309037900874636],...
'Tag','sysperiph_tag',...
'SelectedObject',[],...
'SelectionChangeFcn',[],...
'OldSelectedObject',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'sysfreq_tag';

h17 = uicontrol(...
'Parent',h16,...
'Units','normalized',...
'Position',[0.0295362220717671 0.503841229193342 0.502369668246446 0.295774647887324],...
'String','Sleep Freq (IRC):',...
'Style','text',...
'Tag','sysfreq_tag',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'sys_irc_freq_val';

h18 = uicontrol(...
'Parent',h16,...
'Units','normalized',...
'Callback',@(hObject,eventdata)run_me('sys_irc_freq_val_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[0.550660792951542 0.545454545454545 0.246696035242291 0.306818181818182],...
'String','12',...
'Style','edit',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)run_me('sys_irc_freq_val_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','sys_irc_freq_val');

appdata = [];
appdata.lastValidTag = 'sysfreq_mhz_tag';

h19 = uicontrol(...
'Parent',h16,...
'Units','normalized',...
'Position',[0.777187711577527 0.489756722151088 0.208530805687204 0.295774647887324],...
'String','MHz',...
'Style','text',...
'Tag','sysfreq_mhz_tag',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text34';

h20 = uicontrol(...
'Parent',h16,...
'Units','normalized',...
'HorizontalAlignment','right',...
'Position',[0.0401785714285714 0.0813060179257362 0.459821428571429 0.295774647887324],...
'String','System Freq:',...
'Style','text',...
'Tag','text34',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'sys_freq_val';

h21 = uicontrol(...
'Parent',h16,...
'Units','normalized',...
'Callback',@(hObject,eventdata)run_me('sys_freq_val_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[0.549107142857143 0.125 0.245535714285714 0.295454545454545],...
'String','204',...
'Style','edit',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)run_me('sys_freq_val_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','sys_freq_val');

appdata = [];
appdata.lastValidTag = 'text35';

h22 = uicontrol(...
'Parent',h16,...
'Units','normalized',...
'Position',[0.777187711577528 0.0672215108834828 0.208530805687204 0.295774647887324],...
'String','MHz',...
'Style','text',...
'Tag','text35',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'dyn_alg_tag';

h23 = uibuttongroup(...
'Parent',h1,...
'Title','Static Alg.',...
'Clipping','on',...
'Position',[0.260504201680672 0.0787172011661808 0.195378151260504 0.212827988338192],...
'Tag','dyn_alg_tag',...
'SelectedObject',[],...
'SelectionChangeFcn',[],...
'OldSelectedObject',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'dyn_exe_button';

h24 = uicontrol(...
'Parent',h23,...
'Units','normalized',...
'Callback',@(hObject,eventdata)run_me('dyn_exe_button_Callback',hObject,eventdata,guidata(hObject)),...
'CData',[],...
'ListboxTop',0,...
'Position',[0.101123595505618 0.236363636363636 0.764044943820225 0.490909090909091],...
'String','Execute',...
'UserData',[],...
'Tag','dyn_exe_button',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'uipanel16';

h25 = uibuttongroup(...
'Parent',h1,...
'Title','Dynamic Alg.',...
'Clipping','on',...
'Position',[0.0168067226890756 0.0787172011661808 0.226890756302521 0.215743440233236],...
'Tag','uipanel16',...
'SelectedObject',[],...
'SelectionChangeFcn',[],...
'OldSelectedObject',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'static_exe_button';

h26 = uicontrol(...
'Parent',h25,...
'Units','normalized',...
'Callback',@(hObject,eventdata)run_me('static_exe_button_Callback',hObject,eventdata,guidata(hObject)),...
'CData',[],...
'ListboxTop',0,...
'Position',[0.126126126126126 0.232142857142857 0.72972972972973 0.5],...
'String','Execute',...
'ButtonDownFcn',@(hObject,eventdata)run_me('static_exe_button_ButtonDownFcn',hObject,eventdata,guidata(hObject)),...
'UserData',[],...
'Tag','static_exe_button',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pow_den_panel';

h27 = uipanel(...
'Parent',h1,...
'Title','Power Densities',...
'Clipping','on',...
'Position',[0.508403361344538 0.285714285714286 0.468487394957983 0.309037900874636],...
'Tag','pow_den_panel',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text40';

h28 = uicontrol(...
'Parent',h27,...
'Units','normalized',...
'Position',[0.0228310502283105 0.488636363636364 0.356164383561644 0.295454545454545],...
'String','WC',...
'Style','text',...
'Tag','text40',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'p_den_wc';

h29 = uicontrol(...
'Parent',h27,...
'Units','normalized',...
'Callback',@(hObject,eventdata)run_me('p_den_wc_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[0.389232404479022 0.535051216389245 0.255707762557078 0.306818181818182],...
'String','0.8',...
'Style','edit',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)run_me('p_den_wc_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','p_den_wc');

appdata = [];
appdata.lastValidTag = 'text41';

h30 = uicontrol(...
'Parent',h27,...
'Units','normalized',...
'Position',[0.639269406392694 0.477272727272727 0.319634703196347 0.295454545454545],...
'String','mW/MHz',...
'Style','text',...
'Tag','text41',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text42';

h31 = uicontrol(...
'Parent',h27,...
'Units','normalized',...
'Position',[0.0273972602739726 0.102272727272727 0.365296803652968 0.295454545454545],...
'String','TYP',...
'Style','text',...
'Tag','text42',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'p_den_typ';

h32 = uicontrol(...
'Parent',h27,...
'Units','normalized',...
'Callback',@(hObject,eventdata)run_me('p_den_typ_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[0.387622000043276 0.114596670934699 0.254505055446836 0.295454545454545],...
'String','0.56',...
'Style','edit',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)run_me('p_den_typ_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','p_den_typ');

appdata = [];
appdata.lastValidTag = 'text43';

h33 = uicontrol(...
'Parent',h27,...
'Units','normalized',...
'Position',[0.662100456621004 0.0568181818181818 0.296803652968037 0.295454545454545],...
'String','mW/MHz',...
'Style','text',...
'Tag','text43',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'task_tag';

h34 = uibuttongroup(...
'Parent',h1,...
'Title','Task Load',...
'UserData',[],...
'Clipping','on',...
'Position',[0.510504201680672 0.0874635568513119 0.455882352941176 0.17201166180758],...
'ResizeFcn',@(hObject,eventdata)run_me('task_tag_ResizeFcn',hObject,eventdata,guidata(hObject)),...
'Tag','task_tag',...
'SelectedObject',[],...
'SelectionChangeFcn',[],...
'OldSelectedObject',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'var_tag';

h35 = uicontrol(...
'Parent',h34,...
'Units','normalized',...
'CData',[],...
'Position',[0.0288575899843506 0.467013194722111 0.515555555555556 0.475409836065574],...
'String','Variability:',...
'Style','text',...
'UserData',[],...
'Tag','var_tag',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'var_aux_tag';

h36 = uicontrol(...
'Parent',h34,...
'Units','normalized',...
'CData',[],...
'FontSize',8,...
'Position',[0.139968701095462 0.0975609756097561 0.297777777777778 0.365853658536585],...
'String','(0-1)',...
'Style','text',...
'UserData',[],...
'Tag','var_aux_tag',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'var_val';

h37 = uicontrol(...
'Parent',h34,...
'Units','normalized',...
'Callback',@(hObject,eventdata)run_me('var_val_Callback',hObject,eventdata,guidata(hObject)),...
'CData',[],...
'Position',[0.504100156494523 0.418232706917233 0.306666666666667 0.524590163934426],...
'String','0.5',...
'Style','edit',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)run_me('var_val_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'UserData',[],...
'Tag','var_val');


hsingleton = h1;


% --- Set application data first then calling the CreateFcn. 
function local_CreateFcn(hObject, eventdata, createfcn, appdata)

if ~isempty(appdata)
   names = fieldnames(appdata);
   for i=1:length(names)
       name = char(names(i));
       setappdata(hObject, name, getfield(appdata,name));
   end
end

if ~isempty(createfcn)
   if isa(createfcn,'function_handle')
       createfcn(hObject, eventdata);
   else
       eval(createfcn);
   end
end


% --- Handles default GUIDE GUI creation and callback dispatch
function varargout = gui_mainfcn(gui_State, varargin)

gui_StateFields =  {'gui_Name'
    'gui_Singleton'
    'gui_OpeningFcn'
    'gui_OutputFcn'
    'gui_LayoutFcn'
    'gui_Callback'};
gui_Mfile = '';
for i=1:length(gui_StateFields)
    if ~isfield(gui_State, gui_StateFields{i})
        error(message('MATLAB:guide:StateFieldNotFound', gui_StateFields{ i }, gui_Mfile));
    elseif isequal(gui_StateFields{i}, 'gui_Name')
        gui_Mfile = [gui_State.(gui_StateFields{i}), '.m'];
    end
end

numargin = length(varargin);

if numargin == 0
    % RUN_ME
    % create the GUI only if we are not in the process of loading it
    % already
    gui_Create = true;
elseif local_isInvokeActiveXCallback(gui_State, varargin{:})
    % RUN_ME(ACTIVEX,...)
    vin{1} = gui_State.gui_Name;
    vin{2} = [get(varargin{1}.Peer, 'Tag'), '_', varargin{end}];
    vin{3} = varargin{1};
    vin{4} = varargin{end-1};
    vin{5} = guidata(varargin{1}.Peer);
    feval(vin{:});
    return;
elseif local_isInvokeHGCallback(gui_State, varargin{:})
    % RUN_ME('CALLBACK',hObject,eventData,handles,...)
    gui_Create = false;
else
    % RUN_ME(...)
    % create the GUI and hand varargin to the openingfcn
    gui_Create = true;
end

if ~gui_Create
    % In design time, we need to mark all components possibly created in
    % the coming callback evaluation as non-serializable. This way, they
    % will not be brought into GUIDE and not be saved in the figure file
    % when running/saving the GUI from GUIDE.
    designEval = false;
    if (numargin>1 && ishghandle(varargin{2}))
        fig = varargin{2};
        while ~isempty(fig) && ~ishghandle(fig,'figure')
            fig = get(fig,'parent');
        end
        
        designEval = isappdata(0,'CreatingGUIDEFigure') || isprop(fig,'__GUIDEFigure');
    end
        
    if designEval
        beforeChildren = findall(fig);
    end
    
    % evaluate the callback now
    varargin{1} = gui_State.gui_Callback;
    if nargout
        [varargout{1:nargout}] = feval(varargin{:});
    else       
        feval(varargin{:});
    end
    
    % Set serializable of objects created in the above callback to off in
    % design time. Need to check whether figure handle is still valid in
    % case the figure is deleted during the callback dispatching.
    if designEval && ishghandle(fig)
        set(setdiff(findall(fig),beforeChildren), 'Serializable','off');
    end
else
    if gui_State.gui_Singleton
        gui_SingletonOpt = 'reuse';
    else
        gui_SingletonOpt = 'new';
    end

    % Check user passing 'visible' P/V pair first so that its value can be
    % used by oepnfig to prevent flickering
    gui_Visible = 'auto';
    gui_VisibleInput = '';
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        % Recognize 'visible' P/V pair
        len1 = min(length('visible'),length(varargin{index}));
        len2 = min(length('off'),length(varargin{index+1}));
        if ischar(varargin{index+1}) && strncmpi(varargin{index},'visible',len1) && len2 > 1
            if strncmpi(varargin{index+1},'off',len2)
                gui_Visible = 'invisible';
                gui_VisibleInput = 'off';
            elseif strncmpi(varargin{index+1},'on',len2)
                gui_Visible = 'visible';
                gui_VisibleInput = 'on';
            end
        end
    end
    
    % Open fig file with stored settings.  Note: This executes all component
    % specific CreateFunctions with an empty HANDLES structure.

    
    % Do feval on layout code in m-file if it exists
    gui_Exported = ~isempty(gui_State.gui_LayoutFcn);
    % this application data is used to indicate the running mode of a GUIDE
    % GUI to distinguish it from the design mode of the GUI in GUIDE. it is
    % only used by actxproxy at this time.   
    setappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]),1);
    if gui_Exported
        gui_hFigure = feval(gui_State.gui_LayoutFcn, gui_SingletonOpt);

        % make figure invisible here so that the visibility of figure is
        % consistent in OpeningFcn in the exported GUI case
        if isempty(gui_VisibleInput)
            gui_VisibleInput = get(gui_hFigure,'Visible');
        end
        set(gui_hFigure,'Visible','off')

        % openfig (called by local_openfig below) does this for guis without
        % the LayoutFcn. Be sure to do it here so guis show up on screen.
        movegui(gui_hFigure,'onscreen');
    else
        gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        % If the figure has InGUIInitialization it was not completely created
        % on the last pass.  Delete this handle and try again.
        if isappdata(gui_hFigure, 'InGUIInitialization')
            delete(gui_hFigure);
            gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        end
    end
    if isappdata(0, genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]))
        rmappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]));
    end

    % Set flag to indicate starting GUI initialization
    setappdata(gui_hFigure,'InGUIInitialization',1);

    % Fetch GUIDE Application options
    gui_Options = getappdata(gui_hFigure,'GUIDEOptions');
    % Singleton setting in the GUI M-file takes priority if different
    gui_Options.singleton = gui_State.gui_Singleton;

    if ~isappdata(gui_hFigure,'GUIOnScreen')
        % Adjust background color
        if gui_Options.syscolorfig
            set(gui_hFigure,'Color', get(0,'DefaultUicontrolBackgroundColor'));
        end

        % Generate HANDLES structure and store with GUIDATA. If there is
        % user set GUI data already, keep that also.
        data = guidata(gui_hFigure);
        handles = guihandles(gui_hFigure);
        if ~isempty(handles)
            if isempty(data)
                data = handles;
            else
                names = fieldnames(handles);
                for k=1:length(names)
                    data.(char(names(k)))=handles.(char(names(k)));
                end
            end
        end
        guidata(gui_hFigure, data);
    end

    % Apply input P/V pairs other than 'visible'
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        len1 = min(length('visible'),length(varargin{index}));
        if ~strncmpi(varargin{index},'visible',len1)
            try set(gui_hFigure, varargin{index}, varargin{index+1}), catch break, end
        end
    end

    % If handle visibility is set to 'callback', turn it on until finished
    % with OpeningFcn
    gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
    if strcmp(gui_HandleVisibility, 'callback')
        set(gui_hFigure,'HandleVisibility', 'on');
    end

    feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});

    if isscalar(gui_hFigure) && ishghandle(gui_hFigure)
        % Handle the default callbacks of predefined toolbar tools in this
        % GUI, if any
        guidemfile('restoreToolbarToolPredefinedCallback',gui_hFigure); 
        
        % Update handle visibility
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);

        % Call openfig again to pick up the saved visibility or apply the
        % one passed in from the P/V pairs
        if ~gui_Exported
            gui_hFigure = local_openfig(gui_State.gui_Name, 'reuse',gui_Visible);
        elseif ~isempty(gui_VisibleInput)
            set(gui_hFigure,'Visible',gui_VisibleInput);
        end
        if strcmpi(get(gui_hFigure, 'Visible'), 'on')
            figure(gui_hFigure);
            
            if gui_Options.singleton
                setappdata(gui_hFigure,'GUIOnScreen', 1);
            end
        end

        % Done with GUI initialization
        if isappdata(gui_hFigure,'InGUIInitialization')
            rmappdata(gui_hFigure,'InGUIInitialization');
        end

        % If handle visibility is set to 'callback', turn it on until
        % finished with OutputFcn
        gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility, 'callback')
            set(gui_hFigure,'HandleVisibility', 'on');
        end
        gui_Handles = guidata(gui_hFigure);
    else
        gui_Handles = [];
    end

    if nargout
        [varargout{1:nargout}] = feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    else
        feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    end

    if isscalar(gui_hFigure) && ishghandle(gui_hFigure)
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
    end
end

function gui_hFigure = local_openfig(name, singleton, visible)

% openfig with three arguments was new from R13. Try to call that first, if
% failed, try the old openfig.
if nargin('openfig') == 2
    % OPENFIG did not accept 3rd input argument until R13,
    % toggle default figure visible to prevent the figure
    % from showing up too soon.
    gui_OldDefaultVisible = get(0,'defaultFigureVisible');
    set(0,'defaultFigureVisible','off');
    gui_hFigure = openfig(name, singleton);
    set(0,'defaultFigureVisible',gui_OldDefaultVisible);
else
    gui_hFigure = openfig(name, singleton, visible);  
    %workaround for CreateFcn not called to create ActiveX
    if feature('HGUsingMATLABClasses')
        peers=findobj(findall(allchild(gui_hFigure)),'type','uicontrol','style','text');    
        for i=1:length(peers)
            if isappdata(peers(i),'Control')
                actxproxy(peers(i));
            end            
        end
    end
end

function result = local_isInvokeActiveXCallback(gui_State, varargin)

try
    result = ispc && iscom(varargin{1}) ...
             && isequal(varargin{1},gcbo);
catch
    result = false;
end

function result = local_isInvokeHGCallback(gui_State, varargin)

try
    fhandle = functions(gui_State.gui_Callback);
    result = ~isempty(findstr(gui_State.gui_Name,fhandle.file)) || ...
             (ischar(varargin{1}) ...
             && isequal(ishghandle(varargin{2}), 1) ...
             && (~isempty(strfind(varargin{1},[get(varargin{2}, 'Tag'), '_'])) || ...
                ~isempty(strfind(varargin{1}, '_CreateFcn'))) );
catch
    result = false;
end


