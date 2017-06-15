classdef FastestAvailableAlloc < Allocator
    %FastestAVAILABLEALLOC This allocation policy always selects the
    %Fastest cpu (that meets the deadline) among the available CPU
    %   At any given time, a job is assigned the Fastest CPU which will be
    %   able to meet its deadline.
    
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     PROPERTIES                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTRUCTOR                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = FastestAvailableAlloc(n_tasks, n_procs)
            obj = obj@Allocator(n_tasks, n_procs);
            obj.name = 'Fastest_available';
            obj.long_name = 'Fastest Available First';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     METHODS                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %This determines the Fastest available cpu that will meet the job's
        %deadline
        function [alloc_m, cpu] = Fastest_available(obj, procs, alloc_m, time, job) 
           cpu = 1; 
           ids = (1:1:obj.n_procs).';
            
           if(length(time) == 1)
                time = ones(obj.n_procs,1)*time;
           end
           
           %%%%%%%%%%%%%%   SELECTION BY FREQUENCY & DEADLINE %%%%%%%%
           %Base decision Matrix
           for i=1:obj.n_procs
               cpu_freq(i) = procs(i).freq;
           end
           cpu_m = [ cpu_freq.' alloc_m(:,1) ];
           cpu_m = sortrows(cpu_m, 1);
           for i=1:obj.n_procs
              cpu_i = cpu_m(i,2);
              approx_exec = procs(cpu_i).calcExecTime(job.instructions);
              approx_finish = time(ids(cpu_i)) + approx_exec + alloc_m(cpu_i,2);
              if approx_finish < job.deadline
                 cpu = cpu_i;
                 alloc_m(cpu_i,2) = alloc_m(cpu_i,2) + approx_exec;
                 return
              end
           end
           
           %if code reaches here, even the fastest proc won't meet deadline
           cpu = cpu_m(end,2); %-> fastest proc!
        end        
        
        %This function, when defined, will determine on which CPU to
        %execute each job within a jobset
        function [job_queue, cpu_alloc] = allocate(obj, procs, job_queue, job_set_index, time)
            alloc_m = [linspace(1,obj.n_procs, obj.n_procs).' zeros(obj.n_procs,1)];
            job_set = job_queue(job_set_index);
            
            for i=1:length(job_set)
                [alloc_m, cpu_alloc(i)] = obj.Fastest_available(procs, alloc_m, time, job_set(i));
                
                job_queue(job_set_index(i)).cpu = cpu_alloc(i);
            end
        end
        
       %This function, when defined, will determine on which CPU to
        %execute each job within a jobset
        function cpu = allocateSingle(obj, procs, job, time)
           cpu = 1; 
           
           if(length(time) == 1)
                time = ones(obj.n_procs,1)*time;
           end
                      
           %%%%%%%%%%%%%%   SELECTION BY FREQUENCY & IDLENESS %%%%%%%%
           %Base decision Matrix
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

