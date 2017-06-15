classdef SlowestIdleAlloc < Allocator
    %SLOWESTIDLEALLOC This allocation policy always selects the
    %slowest cpu (that meets the deadline) among the available CPU
    %   At any given time, a job is assigned the slowest idle CPU 
    %   which will be able to meet its deadline.
    
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     PROPERTIES                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTRUCTOR                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = SlowestIdleAlloc()
            obj = obj@Allocator();
            obj.name = 'Slowest (P)';
            obj.long_name = 'Slowest Idle First';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     METHODS                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %This determines the slowest available cpu that will meet the job's
        %deadline
        function [alloc_m, cpu] = slowest_idle(obj, procs, alloc_m, time, job) 
           cpu = 1; 
           ids = (1:1:obj.n_procs).';
            
           if obj.n_procs == 1
               alloc_m(1,1) = alloc_m(1,2)+procs(1).calcExecTime(job.instructions);
               cpu = 1;
               return;
           end
           
           if(length(time) == 1)
                time = ones(obj.n_procs,1)*time;
           end
           
           %%%%%%%%%%%%%%   SELECTION BY FREQUENCY & IDLENESS %%%%%%%%
           %Base decision Matrix
           for i=1:obj.n_procs
               cpu_freq(i) = procs(i).freq;
           end           
           cpu_m = [ cpu_freq.' alloc_m(:,1) ];
           cpu_m = sortrows(cpu_m, 1);
           %First, select by slow freq & idleness
           for i=1:obj.n_procs
              cpu_i = cpu_m(i,2);
              approx_exec = procs(cpu_i).calcExecTime(job.instructions);
%              approx_finish = time(ids(cpu_i)) + approx_exec + alloc_m(cpu_i,2);
              approx_finish = approx_exec + alloc_m(cpu_i,2) + job.arrival_time;
              %if chosen cpu is idle, choose it, otherwise, continue
              if approx_finish < job.deadline
                if procs(cpu_i).isIdle(time(ids(cpu_i)))==1 %& alloc_m(cpu_i,2)==0
                    cpu = cpu_i;
                    alloc_m(cpu_i,2) = alloc_m(cpu_i,2) + approx_exec;
                    return;
                end
              end
           end
           
           %%%%%%%%%%%%%%   SELECTION BY AVAILABILITY %%%%%%%%
           %Base decision Matrix
           for i=1:obj.n_procs
               cpu_end_time(i) = procs(i).time(end);
           end           
           cpu_m = [ cpu_end_time.' alloc_m(:,1) ];
           cpu_m = sortrows(cpu_m, 1);
           %First, select by slow freq & idleness
           for i=1:obj.n_procs
              cpu_i = cpu_m(i,2);
              approx_exec = procs(cpu_i).calcExecTime(job.instructions);
              approx_finish = time(ids(cpu_i)) + approx_exec + alloc_m(cpu_i,2);
              if approx_finish < job.deadline
                 %if chosen cpu is idle, choose it, otherwise, continue
                cpu = cpu_i;
                alloc_m(cpu_i,2) = alloc_m(cpu_i,2) + approx_exec;
                return;
              end
           end
           
           %if all else fails, choose the fastest one!
           cpu = cpu_m(end,2); %-> fastest proc!
        end        
        
        %This function, when defined, will determine on which CPU to
        %execute each job within a jobset
        function [job_queue, cpu_alloc] = allocate(obj, procs, job_queue, job_set_index, time)
            obj.n_procs = length(procs);
            alloc_m = [linspace(1,obj.n_procs, obj.n_procs).' zeros(obj.n_procs,1)];
            job_set = job_queue(job_set_index);
            
            for i=1:length(job_set)
                [alloc_m, cpu_alloc(i)] = obj.slowest_idle(procs, alloc_m, time, job_set(i));
                
                job_queue(job_set_index(i)).cpu = cpu_alloc(i);
            end
        end
        
       %This function, when defined, will determine on which CPU to
        %execute each job within a jobset
        function cpu = allocateSingle(obj, procs, job, time)
           obj.n_procs = length(procs);
           cpu = 1; 
           
           if(length(time) == 1)
                time = ones(obj.n_procs,1)*time;
           end
                      
           for i=1:obj.n_procs
               cpu_freq(i) = procs(i).freq;
           end
           
           ids = (1:1:obj.n_procs).';
           cpu_m = [ cpu_freq.' ids ];
           
           cpu_m = sortrows(cpu_m, 1);
           
           for i=1:obj.n_procs
              cpu_i = cpu_m(i,2);
              approx_exec = procs(cpu_i).calcExecTime(job.instructions);
              approx_finish = time(ids(i)) + approx_exec;
              if approx_finish < job.deadline
                 cpu = cpu_i;
                 return
              end
           end
           
           %if code reaches here, even the fastest proc won't meet deadline
           cpu = cpu_m(end,2); %-> fastest proc!
        end
    end
end

