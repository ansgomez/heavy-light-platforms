classdef FastestAlwaysAlloc < Allocator
    %FASTESTALWAYSALLOC This allocation policy always selects the
    %Fastest cpu always
    %   At any given time, a job is assigned the Fastest CPU
    
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     PROPERTIES                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTRUCTOR                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = FastestAlwaysAlloc()
            obj = obj@Allocator();
            obj.name = 'Only Core 1';
            obj.long_name = 'Fastest Always';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     METHODS                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %This determines the Fastest Always cpu that will meet the job's
        %deadline
        function [alloc_m, cpu] = fastest_always(obj, procs, alloc_m, time, job) 
           cpu = obj.n_procs; 
                      
           %%%%%%%%%%%%%%   SELECTION BY FREQUENCY   %%%%%%%%

           %Base decision Matrix
           for i=1:obj.n_procs
               cpu_freq(i) = procs(i).freq;
           end
           ids = (1:1:obj.n_procs).';
           cpu_m = [ cpu_freq.' ids ];
           cpu_m = sortrows(cpu_m, 1);
           
           %always choose the fastest
           cpu = 1;%cpu_m(end,2); 
        end        
        
        %This function, when defined, will determine on which CPU to
        %execute each job within a jobset
        function [job_queue, cpu_alloc] = allocate(obj, procs, job_queue, job_set_index, time)
            obj.n_procs = length(procs);
            alloc_m = [linspace(1,obj.n_procs, obj.n_procs).' zeros(obj.n_procs,1)];
            job_set = job_queue(job_set_index);
            
            for i=1:length(job_set)
                [alloc_m, cpu_alloc(i)] = obj.fastest_always(procs, alloc_m, time, job_set(i));
                
                job_queue(job_set_index(i)).cpu = cpu_alloc(i);
            end
        end
        
       %This function, when defined, will determine on which CPU to
        %execute each job within a jobset
        function cpu = allocateSingle(obj, procs, job, time)
           obj.n_procs = length(procs);
           cpu = obj.n_procs; 
                      
           %%%%%%%%%%%%%%   SELECTION BY FREQUENCY   %%%%%%%%

           %Base decision Matrix
           for i=1:obj.n_procs
               cpu_freq(i) = procs(i).freq;
           end
           ids = (1:1:obj.n_procs).';
           cpu_m = [ cpu_freq.' ids ];
           cpu_m = sortrows(cpu_m, 1);
           
           %always choose the fastest
           cpu = 1;cpu_m(end,2); 
        end
    end
end

