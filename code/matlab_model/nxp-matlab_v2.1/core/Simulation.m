classdef Simulation
    %SIMULATION This class contains all tasks and procs.
    %   A simulation evaluates a random task sets and executes it on a
    %   particular processor set, with a specific allocation policy.
    
    properties(Constant)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTANTS                       %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %system constants
        SYS_P_ACT = 0.8; %[mW/MHz]
        %SYS_P_SLEEP = 0.08; %[mW/MHz] 
    end
    
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     PROPERTIES                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %constants
        n_tasks;
        n_procs;
        
        %entities
        tasks;
        job_queue;
        allocator;
        procs;
        
        %statistics
        executed_total;
        missed_total
        energy_total;
        total_proc_util;
        system_energy;
        simtime;
        mean_execution_time; 
		
        %system power/energy variables
        sys_p_act;
        sys_p_sleep;
        sleep_time;
        sys_e_act;
        sys_e_sleep;
        sys_e_total;
        
        %auxiliary variables
        simulation_type;
        last_index;
        last_time;
        include_sys_pow;

    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTRUCTOR                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function obj = Simulation(n_tasks, procSet, alloc, job_queue, sys_pow)
            obj.n_tasks = n_tasks;
            obj.procs = procSet.procs;
            obj.n_procs = procSet.n_procs;
            obj.allocator = alloc;
            obj.job_queue = job_queue;
            
            if nargin < 5
                obj.include_sys_pow = 0;
            else
                obj.include_sys_pow = sys_pow;
            end
            
            obj.simulation_type = 'Sequential';

            %system power defined from vars
            %obj.sys_p_act = obj.SYS_P_ACT*max(procSet.procs(:).freq);
            obj.sys_p_sleep = obj.SYS_P_ACT*Processor.SYS_IRC_FREQ();
            
            %system power defined from constants
            obj.sys_p_act = obj.SYS_P_ACT*Processor.SYS_FREQ();
            %obj.sys_p_sleep = obj.SYS_P_ACT*102;
            
            %init aux vars
            obj.last_index = 1;
            obj.last_time = 0;
        end
          
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     METHODS                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %This function determins the next jobset to allocate, based on
        %current time.
        function [obj, job_set_index] = findNextJobSet(obj, now)
            job = obj.job_queue(obj.last_index);
            job_set_index = [ obj.last_index ];
            
            %if the end of the queue was reached, return
            if obj.last_index == length(obj.job_queue)
                obj.last_index = obj.last_index + 1;
                return
            end
            
            %if next arrival is the future, jump to it
            if job.arrival_time > now
                [obj, job_set_index] = obj.findNextJobSet(job.arrival_time);
            else
                obj.last_index = obj.last_index + 1;
                job = obj.job_queue(obj.last_index);
                %create new job set with all jobs that arrived in the past
                while job.arrival_time <= now && strcmp(job.type,'DAG')~=1
                    job_set_index = [job_set_index obj.last_index];
                    obj.last_index = obj.last_index + 1;
                    if obj.last_index > length(obj.job_queue)
                        break
                    else 
                        job = obj.job_queue(obj.last_index);
                    end 
                end
            end
        end
        
        %This function determines the earliest available time, based on all
        %cpu's availability, as well as the current time. This acts as the
        %time for the next event.
        function earliest = earliestAvailable(obj, time)
            aux = zeros(1,obj.n_procs);
            for i=1:obj.n_procs
                core = obj.procs(i);
                aux(i) = core.time(end);
            end
            earliest = max( [min(aux) time] );
        end
        
        function [obj, cpu_alloc] = allocate(obj, job_set_index, time)
           [job_queue_aux, cpu_alloc] = obj.allocator.allocate(obj.procs, obj.job_queue, job_set_index, time);
           
           obj.job_queue = job_queue_aux;
        end
        
        %This function execute one (already allocated) (independent) job
        function obj = executeIJob(obj, cpu_i, job_i)
            job = obj.job_queue(job_i);
            [obj.procs(cpu_i),job] = obj.procs(cpu_i).executeJob(job, obj.last_time);
            %write back execution info
            obj.job_queue(job_i) = job;
            obj.last_time = max(obj.last_time, job.finish_time);
            %TODO: update allocator info            
        end
        
        %This function executes a dependent and unallocated job (the jth
        %djob of the dag
        function [obj, job_aux] = executeDJob(obj, job_aux)
            %job_aux = job.dag{j};
            
            %Allocate and execute dependent job
            cpu_alloc = obj.allocator.allocateSingle(obj.procs, job_aux, obj.last_time);            
            [obj.procs(cpu_alloc),job_aux] = obj.procs(cpu_alloc).executeJob(job_aux, obj.last_time);
            
            %write back execution info
            job_aux.cpu = cpu_alloc;
            %job.dag{j} = job_aux;
            
            %advance time (from execution of DJob)
            obj.last_time = max(obj.last_time, job_aux.finish_time);    
        end
        
        %This function executes a DAG, whose source node has already been
        %allocated, but the rest of the DAG has not
        function [obj,job] = executeDAGSet(obj, cpu_i, job)
            [obj.procs(cpu_i),job] = obj.procs(cpu_i).executeJob(job, obj.last_time);        
            obj.last_time = max(obj.last_time, job.finish_time);

            %execute the DAG
            for j=1:length(job.dag)
                job_aux = job.dag{j};

                if(length(job_aux) > 1)
                     for k=0:length(job_aux)
                         job_aux_k = job_aux(k);
                         [obj, job_aux_k] = executeDJob(job_aux_k);
                         job_aux(k) = job_aux_k;
                     end
                else 
                    [obj, job_aux] = obj.executeDJob(job_aux);
                end
                
                %write back execution of jth DAG cell
                job.dag{j} = job_aux;
            end
        end
        
        %This function executes an (already allocated) set of jobs on their
        %respective cpu.
        function obj = executeSet(obj, job_set_index, cpu_index)
            jobs = obj.job_queue(job_set_index);
            for i=1:length(job_set_index)
                cpu_i = cpu_index(i);
                job = jobs(i);
                
                if(strcmp(job.type,'I') == 1)
                    obj = obj.executeIJob(cpu_i,job_set_index(i));
                elseif (strcmp(job.type,'DAG') == 1)
                    [obj,job] = obj.executeDAGSet(cpu_i, job);
                    %write back execution info
                    obj.job_queue(job_set_index(i)) = job;
                else
                    %empty
                end
            end
        end
        
        %This function iterates the entire job queue, allocates it (by
        %sets) and executes them (by sets).
        function obj = run(obj)
            first_time = 0;
            
            while obj.last_index <= length(obj.job_queue)
                %find next job set to execute
                [obj, job_set_index] = obj.findNextJobSet(first_time); 
                %allocate job set
                [obj, cpu_index] = obj.allocate(job_set_index, obj.last_time);
                
                %execute allocated job set and writeback stats to alloc
                obj = obj.executeSet(job_set_index, cpu_index);
                
                %next step in time
                first_time = obj.earliestAvailable(obj.last_time);
            end
            
            obj.simtime = max(obj.last_time);
            
            %wrap up all proc simulation data
            for i=1:obj.n_procs
                obj.procs(i) = obj.procs(i).endSim(obj.simtime);
            end
			
			obj = obj.calcExecTime();
            obj = obj.calcSystemEnergy();
            obj = obj.calcTotalEnergy();
            obj = obj.calcTotalMissed();
            obj = obj.calcTotalProcUtil();
        end
        
		%This function calculates the execution time of the jobs during the simulation. This execution time is when both tasks have been terminated.
		function obj = calcExecTime(obj)
			exec_times = zeros(length(obj.procs), TaskSet.ITER);
			for i=1:length(obj.procs)
				job_finished_offset = (length(obj.procs(i).time) - 2) / TaskSet.ITER;
				for j=1:TaskSet.ITER
					exec_times(i, j) = obj.procs(i).time(j*job_finished_offset + 1) - obj.procs(i).time((j-1)*job_finished_offset + 2);
				end
			end

			job_exec_times = zeros(1, TaskSet.ITER);
			for j=1:TaskSet.ITER
				job_exec_times(j) = max(exec_times(:, j));
			end

			obj.mean_execution_time = mean(job_exec_times);
		end
		
        function obj = calcSystemEnergy(obj)
            time_set = [0 obj.simtime];
            obj.sleep_time = 0;
            %calculate the total intersection of sleep times
            for i=1:obj.n_procs
                time_set = range_intersection(time_set,obj.procs(i).sleep_times);
            end
            %calculate total sleep time from the interval set
            for i=1:2:length(time_set)
                obj.sleep_time = obj.sleep_time + (time_set(i+1)-time_set(i));
            end
            %calculate system active and sleep energies from the sleep & sim time
            obj.sys_e_act = (obj.simtime-obj.sleep_time)*obj.sys_p_act;
            obj.sys_e_sleep = obj.sleep_time*obj.sys_p_sleep;
            obj.sys_e_total = obj.sys_e_act+obj.sys_e_sleep;
        end
        
        %This function returns the total energy consumption of the
        %simulation, from all of the processors (after the sim)
        function obj = calcTotalEnergy(obj)
            obj.energy_total = 0;
            %add processor energies
            for i=1:obj.n_procs
                obj.energy_total = obj.energy_total + obj.procs(i).total_energy;
            end
            %(when applicable) add system power
            if obj.include_sys_pow == 1
                obj.energy_total = obj.energy_total+obj.sys_e_total;
            end
        end
        
        %This function returns the total percentage of deadlines missed for 
        %the simulation, from all of the processors (after the sim)
        function obj = calcTotalMissed(obj)
            obj.missed_total = 0;
            obj.executed_total = 0;
            for i=1:obj.n_procs
                obj.missed_total  = obj.missed_total  + length(obj.procs(i).missed);
                obj.executed_total = obj.executed_total + obj.procs(i).exec_jobs;
            end
            obj.missed_total = 100* (obj.missed_total/obj.executed_total);
        end
        
        %This function returns the total sum of utilization for all procs
        function obj = calcTotalProcUtil(obj)
            obj.total_proc_util = 0;
            for i=1:obj.n_procs
                obj.total_proc_util = obj.total_proc_util + obj.procs(i).util;
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %              GET   SET    METHODS                   %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = includeSystemPower(obj)
            obj.include_sys_pow = 1;
        end
        
        function obj = excludeSystemPower(obj)
            obj.include_sys_pow = 0;
        end
        
        function obj = setSystemPowerActiveIdleRatio(obj, ratio)
            obj.sys_p_sleep = obj.sys_p_act/ratio;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                 EXPORT    METHODS                   %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %This function exports all of the simulation's data
        function exportAll(obj)            
            %create simulation folder
            prefix = sprintf('results_%s_%s/', obj.allocator.name, lower(obj.simulation_type));
            [status,message,messageid] = mkdir(prefix);

            max_time = obj.simtime;

            %%%%%%%%    EXPORT   PROCESSOR   INFO   %%%%%%%
            for i=1:obj.n_procs
                %export processor data
                obj.procs(i) = obj.procs(i).exportAll(prefix, max_time);
            end

            %%%%%%%%    EXPORT   GLOBAL   INFO   %%%%%%%
            %export all JS objects
            obj.exportJS(prefix);
        end
        
        %This function creates javascript files containing the simulation's
        %global data, such as jobqueue tables, processor info, etc.
        function exportJS(obj, prefix)
            %copy html template
            name = sprintf('%sindex.html',prefix);
            copyfile('html/base.html',name);

            %create css directory
            name = sprintf('%scss/', prefix);
            [status,message,messageid] = mkdir(name);
            copyfile('html/css/*',name);
            
            %create img directory
            name = sprintf('%simg/', prefix);
            [status,message,messageid] = mkdir(name);
            copyfile('html/img/*',name);
            
            %create js directory
            name = sprintf('%sjs/', prefix);
            [status,message,messageid] = mkdir(name);
            copyfile('html/js/*',name);
            
            %export all JS data
            obj.exportJobQueueData(name);
            obj.exportProcsData(name);
            obj.exportSummary(name);            
            
            %export bootstrapping functions
            name = sprintf('%s/js/Func.js', prefix);
            fid = fopen(name,'w');
            %register simulation summary
            fprintf(fid,'var summaryTable = tabulate("Simulation Summary", sim,[0,1,2,3,4], summaryColNames);\n');
            %register processor tables
            for i=1:length(obj.procs)
                str = sprintf('var proc%dTable = tabulate("Proc %d",proc%d,[0,1,2,3,4,5,6], procColNames);\n', i, i, i);
                fprintf(fid,str);
            end
            %register jobqueue table
            fprintf(fid,'var jobQueueTable = tabulate("Job Queue", job_queue,[0,1,2,3,4,5,6,7,8], queueColNames);\n');
            %register graphs table
            fprintf(fid,'createGraphTable(%d);\n',length(obj.procs));
            fclose(fid);            
        end

        %This function generates a javascript file containing the job
        %queue's data
        function exportJobQueueData(obj, prefix)
            name = sprintf('%sJobQueue.js',prefix);
            fid = fopen(name,'w');
            fprintf(fid,'var job_queue = [\n');
            for i=1:length(obj.job_queue)
                fprintf(fid,obj.job_queue(i).toRow());
                if i ~= length(obj.job_queue)
                    if(strcmp(obj.job_queue(i).type,'DAG') == 1)
                        fprintf(fid,'\n');
                    else
                        fprintf(fid,',\n');
                    end
                else
                    if(strcmp(obj.job_queue(i).type,'DAG') == 1)
                        fprintf(fid,'\n');
                    else
                        fprintf(fid,',\n');
                    end
                end
            end
            fprintf(fid,'];');
            fclose(fid);
        end
        
        %This function generates a javascript file containing the cpu's
        %information (like frequency, cpi, power, etc)
        function exportProcsData(obj, prefix)
            name = sprintf('%sProcs.js',prefix);
            fid = fopen(name,'w');
            for i=1:length(obj.procs)
                fprintf(fid,'var proc%d = [\n',i);
                fprintf(fid,sprintf('\t%s',obj.procs(i).toJSRow()));
                fprintf(fid,'\n];\n');
            end
            fclose(fid);
        end
        
        %This function generates a javascript file containing the
        %simulation's summary of results
        function exportSummary(obj, prefix)
            name = sprintf('%sSummary.js',prefix);
            
            n_jobs = length(obj.job_queue);
            p_missed = obj.missed_total;
            total_e = obj.energy_total;
            max_time = obj.simtime;
            
            fid = fopen(name,'w');
            fprintf(fid,'var sim = [\n');
            fprintf(fid,sprintf('\t[%d, %d, %d, %d, %d, %d]', obj.n_procs, obj.n_tasks, n_jobs, p_missed, total_e, max_time) );
            fprintf(fid,'\n];\n');
            fprintf(fid,'var algorithm = "%s"\n',obj.allocator.long_name);
            fprintf(fid,'var execution = "%s"\n',obj.simulation_type);
            fclose(fid);
        end
    end
end

