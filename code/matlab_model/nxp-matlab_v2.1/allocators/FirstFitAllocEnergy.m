classdef FirstFitAllocEnergy < Allocator
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
        
        function obj = FirstFitAllocEnergy()
            obj = obj@Allocator();
            obj.name = 'FirstFitEnergy';
            obj.long_name = 'First Fit Energy';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     METHODS                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %This function determines the best fit
        function [alloc_m, cpu] = first_fit0(obj, procs, alloc_m, job, total_inst) 
          %if energy efficient proc hasn't met it's budget, assign it
           %todo: generic N proc case
           f1_scale = (1*procs(1).freq)/(procs(1).freq + procs(2).freq);
           threshold_cpu1 = total_inst*f1_scale;
           threshold_cpu2 = total_inst - threshold_cpu1;
           if(alloc_m(1,2)+job.instructions < threshold_cpu1)
               cpu = 1;
           elseif (alloc_m(2,2)+job.instructions > threshold_cpu2)
               %balance by selecting cpu with least instr.
               if alloc_m(1,2) > alloc_m(2,2)
                   cpu = 2;
               else
                   cpu = 1;
               end
           else
               cpu = 2;
           end
           
           alloc_m(cpu,2) = alloc_m(cpu,2) + (job.instructions);
        end
        
        %This function determines the best fit
        function [alloc_m, cpu] = first_fit(obj, procs, alloc_m, job, total_inst) 
          %if energy efficient proc hasn't met it's budget, assign it
           %todo: generic N proc case
           f1_scale = (1*procs(1).freq)/(procs(1).freq + procs(2).freq);
           threshold_cpu1 = total_inst*f1_scale;
           if(alloc_m(1,2)+job.instructions <= threshold_cpu1)
               cpu = 1;
           else
               cpu = 2;
           end
           
           alloc_m(cpu,2) = alloc_m(cpu,2) + (job.instructions);
        end
        
        %This function determines the best fit
        function [alloc_m, cpu] = first_fit2(obj, procs, alloc_m, job, total_inst) 
           %if energy efficient proc hasn't met it's budget, assign it
           %todo: generic N proc case
           f2_scale = (1*procs(2).freq)/(procs(1).freq + procs(2).freq);
           threshold_cpu2 = total_inst*f2_scale;
           if(alloc_m(2,2)+job.instructions < threshold_cpu2)
               cpu = 2;
           else
               cpu = 1;
           end
           
           alloc_m(cpu,2) = alloc_m(cpu,2) + (job.instructions);
        end
        
        %This function, when defined, will determine on which CPU to
        %execute each job within a jobset
        function [job_queue, cpu_alloc] = allocateSorted(obj, procs, job_queue, job_set_index, time)
            if(length(procs) > 1)
                aux = 1;
            end
            obj.n_procs = length(procs);
            alloc_m = [linspace(1,obj.n_procs, obj.n_procs).' zeros(obj.n_procs,1)];
            job_set = job_queue(job_set_index);
            
            %sort jobs!
            n_jobs = length(job_set);
            [job_set_o, job_set_o_i] = sort(job_set,'descend');
            total_inst = sum([job_set_o(:).instructions]);% + min([job_set_o(:).instructions])/2;
            total_cpu = zeros(1,2);
            
            for i=1:length(job_set_o)
                [alloc_m, cpu_alloc(i)] = obj.first_fit(procs, alloc_m, job_set_o(i), total_inst);
                job_queue(job_set_index(job_set_o_i(i))).cpu = cpu_alloc(i);
                total_cpu(cpu_alloc(i)) = total_cpu(cpu_alloc(i)) + job_set_o(i).instructions;
            end
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
            
            total_inst = sum([job_set(:).instructions]);% + min([job_set_o(:).instructions])/2;
            total_cpu = zeros(1,2);
            
            for i=1:length(job_set)
                [alloc_m, cpu_alloc(i)] = obj.first_fit(procs, alloc_m, job_set(i), total_inst);
                job_queue(job_set_index(i)).cpu = cpu_alloc(i);
                total_cpu(cpu_alloc(i)) = total_cpu(cpu_alloc(i)) + job_set(i).instructions;
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

