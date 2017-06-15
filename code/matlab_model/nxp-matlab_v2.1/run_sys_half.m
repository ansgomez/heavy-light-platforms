% Adding specific sub-folders to Matlab's path
addpath('./allocators/');
addpath('./core/');
addpath('./gui/');
addpath('./tasks/');
addpath('./util/');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% POWER NUMBERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Processor.IRC_FREQ(12);
Processor.SYS_IRC_FREQ(12);
Processor.SYS_FREQ(Processor.MAX_F/2);
display(sprintf('IRC Freq = %d', Processor.IRC_FREQ()));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DSE PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GLOBALS
WITH_SYS_POW = 1;
WITHOUT_SYS_POW = 0;
%Number of queues sweeping util range
n_queues = 10;

%Initialize processor architecture
proc_freq = ProcSet.HIGH_F; %set frequency F1=F2=Fmax=204
proc_type = [Processor.WC Processor.TYP]; %set processor type
%Processor Set
procSets = ProcSet(2, proc_freq, proc_type); %init proc object

% With the above commands, the power values are:
%------------------------------------------
%        | Pactive (mW)  |    Psleep (mW) |
%-----------------------------------------|
%   WC   |    163.2      |      9.60      | 
%-----------------------------------------|
%  TYP   |    114.2      |      6.72      |
%-----------------------------------------|
%  SYS   |     81.6      |      9.60      |
%------------------------------------------

% WORKLOAD VARIABLES
n_tasks = 2;
var_high  = 0.50;
taskSet_high = TaskSet(n_tasks, n_queues, 'benini_var', procSets, var_high); 
var_low  = 0.10;
taskSet_low = TaskSet(n_tasks, n_queues, 'benini_var', procSets, var_low); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN EXPERIMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% HIGH PARALLELISM DSE WITH SYSTEM POWER
dse2 = DSE(procSets, taskSet_high);
dse2 = dse2.runDynamic(WITH_SYS_POW);

% LOW PARALLELISM DSE WITH SYSTEM POWER
dse4 = DSE(procSets, taskSet_low);
dse4 = dse4.runDynamic(WITH_SYS_POW);