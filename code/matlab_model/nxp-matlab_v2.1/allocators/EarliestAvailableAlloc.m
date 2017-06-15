classdef EarliestAvailableAlloc < Allocator
    %EARLIESTAVAILABLEALLOC This allocation policy always selects the
    %earliest available CPU
    %   At any given time, a job is assigned the CPU which will be
    %   available at the earliest time
    
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     PROPERTIES                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTRUCTOR                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = EarliestAvailableAlloc()
            obj = obj@Allocator();
            obj.name = 'R.R.';
            obj.long_name = 'RoundRobin';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     METHODS                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %This function determines the earliest free cpu
        function [alloc_m, cpu] = earliest_free(obj, procs, alloc_m, job) 
           cpu = 1; 
           
           for i=1:obj.n_procs
               cpu_time(i) = max(job.arrival_time,procs(i).time(end)) + alloc_m(i,2);
           end
           
           cpu_m = [ cpu_time.' alloc_m(:,1) ];
           
           cpu_m = sortrows(cpu_m, 1);
           
           %earliest available core's id is now in 
           %the first row, second column
           cpu = cpu_m(1,2);
           
           alloc_m(cpu,2) = alloc_m(cpu,2) + procs(cpu).calcExecTime(job.instructions);
        end
        
        %This function, when defined, will determine on which CPU to
        %execute each job within a jobset
        function [job_queue, cpu_alloc] = allocate(obj, procs, job_queue, job_set_index, time)
            if(length(procs) > 1)
                aux = 1;
            end
            obj.n_procs = length(procs);
            alloc_m = [linspace(1,obj.n_procs, obj.n_procs).' zeros(obj.n_procs,1)];
            job_set = job_queue(job_set_index);
            
            %sort jobs!
            
            for i=1:length(job_set)
                [alloc_m, cpu_alloc(i)] = obj.earliest_free(procs, alloc_m, job_set(i));
                
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
               cpu_time(i) = time(i);%procs(i).time(end);
           end
           
           ids = (1:1:obj.n_procs).';
           cpu_m = [ cpu_time.' ids ];
           
           cpu_m = sortrows(cpu_m, 1);
           
           %earliest available core's id is now in 
           %the first row, second column
           cpu = cpu_m(1,2);
        end
    end
end

