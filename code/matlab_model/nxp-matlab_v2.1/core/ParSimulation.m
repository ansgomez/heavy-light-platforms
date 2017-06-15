classdef ParSimulation < Simulation
    %SIMULATION This class contains all tasks and procs.
    %   A simulation evaluates a random task sets and executes it on a
    %   particular processor set, with a specific allocation policy.
     
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTRUCTOR                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
        function obj = ParSimulation(n_tasks, procSet, alloc, job_queue, sys_pow)
            obj = obj@Simulation(n_tasks, procSet, alloc, job_queue, sys_pow);

            obj.simulation_type = 'Parallel';
             
            obj.last_index = 1;
            obj.last_time = zeros(obj.n_procs,1);
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
            [obj.procs(cpu_i),job] = obj.procs(cpu_i).executeJob(job, obj.last_time(cpu_i));
            %write back execution info
            obj.job_queue(job_i) = job;
            obj.last_time(cpu_i) = max(obj.last_time(cpu_i), job.finish_time);
            %TODO: update allocator info            
        end
         
        %This function executes a dependent and unallocated job (the jth
        %djob of the dag
        function [obj, job_aux] = executeDJob(obj, job_aux, previous_exec)
            %job_aux = job.dag{j};
             
            %Shift earliest free times to finish time of previous IJob or DAG cell
            start_times = max(previous_exec, obj.last_time);
            %Allocate and execute dependent job
            cpu_alloc = obj.allocator.allocateSingle(obj.procs, job_aux, start_times);
            [obj.procs(cpu_alloc),job_aux] = obj.procs(cpu_alloc).executeJob(job_aux, start_times(cpu_alloc));
             
            %write back execution info
            job_aux.cpu = cpu_alloc;
            %job.dag{j} = job_aux;
             
            %advance time (from execution of DJob)
            obj.last_time(cpu_alloc) = max(obj.last_time(cpu_alloc), job_aux.finish_time);    
        end
         
        %This function executes a DAG, whose source node has already been
        %allocated, but the rest of the DAG has not
        function [obj,job] = executeDAGSet(obj, cpu_i, job)
            [obj.procs(cpu_i),job] = obj.procs(cpu_i).executeJob(job, obj.last_time(cpu_i));        
            obj.last_time(cpu_i) = max(obj.last_time(cpu_i), job.finish_time);
            %auxiliary variable to enforce order of execution within the
            %DAG since a proc might be free earlier.
            previous_exec = job.finish_time;
             
            %execute the DAG
            for j=1:length(job.dag)
                job_aux = job.dag{j};
 
                if(length(job_aux) > 1)
                    %auxiliary variable to calculate maximum finish time of
                    %all jobs within the DAG cell
                    previous_exec_aux = previous_exec;
                    for k=0:length(job_aux)
                        job_aux_k = job_aux(k);
                        [obj, job_aux_k] = executeDJob(job_aux_k, previous_exec);
                        job_aux(k) = job_aux_k;
                        previous_exec_aux = max(previous_exec_aux, job_aux_k.finish_time);
                    end
                    previous_exec = previous_exec_aux;
                else 
                    [obj, job_aux] = obj.executeDJob(job_aux, previous_exec);
                    previous_exec = job_aux.finish_time;
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
                first_time = obj.earliestAvailable(min(obj.last_time));
            end
             
            obj.simtime = max(max(obj.last_time));
             
            for i=1:obj.n_procs
                %wrap up all simulation data
                obj.procs(i) = obj.procs(i).endSim(obj.simtime);
            end
            
			obj = obj.calcExecTime();
            obj = obj.calcSystemEnergy();
            obj = obj.calcTotalEnergy();
            obj = obj.calcTotalMissed();
            obj = obj.calcTotalProcUtil();
        end
    end
end