classdef TaskSet
    %TASKSET class is used to group N job queues together
    %   This class facilitates the comparison of different evaluations. It
    %   is responsible for holding all of the (randomly generated) job
    %   queues to be evaluated by different allocation strategies.
    

    properties (Constant)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTANTS                       %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        UTIL_MIN = 0.10;
        UTIL_MAX = 0.98;
        
        ITER = 20;
    end
    
    properties
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     PROPERTIES                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %constants
        n_tasks;
        n_queues;
        
        %scalar variables
        variability;
        
        %global statistics vectors
        job_mean_exe_ms;
        job_var_exe_ms;
        
        %global vectors cell arrays
        job_queue;
        total_inst;
        single_core_exec_ms;
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTRUCTOR                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = TaskSet(n_tasks, n_queues, type, procSet, variability)
            obj.n_tasks = n_tasks;
            obj.n_queues = n_queues;
            
            if(nargin < 3)
                type = 'benini';
            elseif (nargin < 4)
                procSet = ProcSet(2, ProcSet.HET_F, [Processor.WC Processor.WC]);
            elseif (nargin < 5)
                variability = 0; %variability should be decimal (max 1.0)
            end
            
            if strcmp(type,'realtime') == 1
                for i=1:n_queues;
                    %generate all tasks & job queues
                    tasks = Task.empty(0,obj.n_tasks);
                    tot_inst = 0;
                    for j=1:obj.n_tasks
                        tasks(j) = Task(j);
                        tot_inst = tot_inst + tasks(j).INST;
                    end
                    printf('Warning, there have been changes which might make realtime useless');
                    obj.job_queue{i} = obj.joinTaskQueues(tasks);
                    obj.total_inst(i) = tot_inst;
                    clear tasks;
                end
            elseif strcmp(type,'benini') == 1
                util = linspace(TaskSet.UTIL_MIN, TaskSet.UTIL_MAX,n_queues);
                
                inst_iter = util*(Task.PERIOD_MS*Processor.MAX_F/Processor.CPI)*1e3;
                for i=1:n_queues
                    jobs = Job.empty(0,TaskSet.ITER*n_tasks);
                    count = 1;
                    dist_acc = zeros(1,n_tasks);
                    for j=1:TaskSet.ITER
                        arrival = (j-1)*Task.PERIOD_MS;
                        deadline = (j)*Task.PERIOD_MS;
                        dist = rand(1,n_tasks); %random task cuts
                        dist = (dist/n_tasks) * inst_iter(i); %normalize and scale
                        dist_acc = dist_acc + dist;
                        for k=1:n_tasks
                            jobs(count) = IJob(k,j,arrival,deadline, dist(k));
                            count = count + 1;
                        end
                    end
                    %save avg single-cpu exec times
                    dist_avg = dist_acc/TaskSet.ITER;
                    obj.single_core_exec_ms{i} = dist_avg*(Processor.CPI/Processor.MAX_F)*1e-3;
                    %save average exec time for all jobs
                    obj.job_mean_exe_ms(i) = mean(obj.single_core_exec_ms{i});
                    %save stdev exec time for all jobs
                    obj.job_var_exe_ms(i) = std(obj.single_core_exec_ms{i});
                    %save job queue
                    obj.job_queue{i} = jobs;
                    %save total inst
                    obj.total_inst(i) = TaskSet.ITER*inst_iter(i);
                end
            elseif strcmp(type,'benini_var') == 1
                util = linspace(TaskSet.UTIL_MIN, TaskSet.UTIL_MAX,n_queues);
                %n_queues shows the utilisation values that we plot
                inst_iter = util*(Task.PERIOD_MS*Processor.MAX_F/Processor.CPI)*1e3;  %number of instructions
                for i=1:n_queues
                    jobs = Job.empty(0,TaskSet.ITER*n_tasks); %for each util value we have TaskSet.ITER = 20 iterations
                    count = 1;
                    dist_acc = zeros(1,n_tasks);
                    for j=1:TaskSet.ITER
                        arrival = (j-1)*Task.PERIOD_MS;
                        deadline = (j)*Task.PERIOD_MS;
                        dist = ones(1,n_tasks); %perfect task cuts
                        dist = (dist/n_tasks) * inst_iter(i); %normalize and scale
                        %introduce manual variability to the instruction
                        %distributions
                        for k=1:2:(n_tasks-mod(n_tasks,2))
                            dist(k) = dist(k)*(1+variability);
                            dist(k+1) = dist(k+1)*(1-variability);
                        end
                        dist_acc = dist_acc + dist;	%instructions distribution for each task
                        %assign instruction distribution to jobs
                        for k=1:n_tasks
                            jobs(count) = IJob(k,j,arrival,deadline, dist(k));
                            count = count + 1;
                        end
                    end
                    %save avg single-cpu exec times
                    dist_avg = dist_acc/TaskSet.ITER;
                    obj.single_core_exec_ms{i} = dist_avg*(Processor.CPI/Processor.MAX_F)*1e-3;
                    %save average exec time for all jobs
                    obj.job_mean_exe_ms(i) = mean(obj.single_core_exec_ms{i});
                    %save stdev exec time for all jobs
                    obj.job_var_exe_ms(i) = std(obj.single_core_exec_ms{i});
                    %save job queue
                    obj.job_queue{i} = jobs;
                    %save total inst
                    obj.total_inst(i) = TaskSet.ITER*inst_iter(i);
                end
             elseif strcmp(type,'par_theo') == 1
                 %todo: generic nproc
                n_procs = procSet.n_procs;
                obj.n_tasks = n_procs;
                util = linspace(TaskSet.UTIL_MIN, TaskSet.UTIL_MAX,n_queues);
                
                inst_iter = util*(Task.PERIOD_MS*Processor.MAX_F/Processor.CPI)*1e3;
                for i=1:n_queues
                    jobs = Job.empty(0,TaskSet.ITER*n_procs);
                    count = 1;
                    dist_acc = zeros(1,n_procs);
                    for j=1:TaskSet.ITER
                        arrival = (j-1)*Task.PERIOD_MS;
                        deadline = (j)*Task.PERIOD_MS;
                        dist = ones(1,n_procs); %random task cuts
                        freqs = procSet.freqs;
                        for k=1:n_procs
                            %to distribute instr for all procs, regarless
                            %of their frequency relations, must scale by:
                            % 1/(1+Sum(f_j~=i)/f_i)
                            %dist(k) = (dist(k)/(1+sum(setdiff(freqs,freqs(k)))/freqs(k))) * inst_iter(i); %normalize and scale
                            %dist(k) = (1/(1+sum(freqs(k))/freqs(k))) * inst_iter(i); %normalize and scale
                            dist(k) = inst_iter(i)*freqs(k)/(sum(freqs)); %normalize and scale
                            dist_acc = dist_acc + dist;
                            jobs(count) = IJob(i,j,arrival,deadline, dist(k));
                            count = count + 1;
                        end
                    end
                    %save avg single-cpu exec times
                    dist_avg = dist_acc/TaskSet.ITER;
                    obj.single_core_exec_ms{i} = dist_avg*(Processor.CPI/Processor.MAX_F)*1e-3;
                    %save average exec time for all jobs
                    obj.job_mean_exe_ms(i) = mean(obj.single_core_exec_ms{i});
                    %save variance exec time for all jobs
                    obj.job_var_exe_ms(i) = var(obj.single_core_exec_ms{i});
                    %save job queue
                    obj.job_queue{i} = jobs;
                    %save total inst
                    obj.total_inst(i) = TaskSet.ITER*inst_iter(i);                    
                end
             elseif strcmp(type,'zupt') == 1
                 %todo: generic nproc
                n_procs = procSet.n_procs;
                obj.n_tasks = n_procs;
                util = linspace(TaskSet.UTIL_MIN, TaskSet.UTIL_MAX,n_queues);
                
                inst_iter = util*(Task.PERIOD_MS*Processor.MAX_F/Processor.CPI)*1e3;
                for i=1:n_queues
                    jobs = Job.empty(0,TaskSet.ITER*n_procs);
                    count = 1;
                    dist_acc = zeros(1,n_procs);
                    for j=1:TaskSet.ITER
                        arrival = (j-1)*Task.PERIOD_MS;
                        deadline = (j)*Task.PERIOD_MS;
                        dist = ones(1,n_procs); %random task cuts
                        freqs = procSet.freqs;
                        for k=1:n_procs
                            %to distribute instr for all procs, regarless
                            %of their frequency relations, must scale by:
                            % 1/(1+Sum(f_j~=i)/f_i)
                            %dist(k) = (dist(k)/(1+sum(setdiff(freqs,freqs(k)))/freqs(k))) * inst_iter(i); %normalize and scale
                            %dist(k) = (1/(1+sum(freqs(k))/freqs(k))) * inst_iter(i); %normalize and scale
                            dist(k) = inst_iter(i)*freqs(k)/(sum(freqs)); %normalize and scale
                            dist_acc = dist_acc + dist;
                            jobs(count) = IJob(i,j,arrival,deadline, dist(k));
                            count = count + 1;
                        end
                    end
                    %save avg single-cpu exec times
                    dist_avg = dist_acc/TaskSet.ITER;
                    obj.single_core_exec_ms{i} = dist_avg*(Processor.CPI/Processor.MAX_F)*1e-3;
                    %save average exec time for all jobs
                    obj.job_mean_exe_ms(i) = mean(obj.single_core_exec_ms{i});
                    %save variance exec time for all jobs
                    obj.job_var_exe_ms(i) = var(obj.single_core_exec_ms{i});
                    %save job queue
                    obj.job_queue{i} = jobs;
                    %save total inst
                    obj.total_inst(i) = TaskSet.ITER*inst_iter(i);                    
                end
            else
                %ERROR
            end
            
            obj.variability = variability;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     METHODS                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %This function generates a queue of jobs to processed
        function queue = joinTaskQueues(obj, tasks) 
            queue = [];
            
            %add all jobs from all tasks
            for i=1:obj.n_tasks
                queue = [queue tasks(i).jobs];
            end
            
            %sort all jobs in the que by arrival time 
            %(as defined by the Job.sort() method)
            queue = sort(queue);
        end

    end
    
end

