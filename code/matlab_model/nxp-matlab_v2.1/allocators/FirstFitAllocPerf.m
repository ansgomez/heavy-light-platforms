classdef FirstFitAllocPerf < Allocator
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
        
        function obj = FirstFitAllocPerf()
            obj = obj@Allocator();
            obj.name = 'FirstFitPerfomance';
            obj.long_name = 'First Fit Performance';
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
			f1_scale = (1*procs(1).freq)/(procs(1).freq + procs(2).freq);
			f2_scale = 1 - f1_scale;
			threshold_cpu1 = total_inst*f1_scale;
			threshold_cpu2 = total_inst*f2_scale;
			%if by assigning the task to the TC its budget is not exceeded, then assign it to the TC
			if(alloc_m(2,2)+job.instructions <= threshold_cpu2)
				cpu = 2;
			%if it is exceeded, then check the threshold of the WC and if it is not exceeded assign it to the WC 
			elseif(alloc_m(1,2)+job.instructions <= threshold_cpu1)
				cpu = 1;
			%if both budgets are exceeded, then calculate the extra instructions for each processor and divide them with the 
			%processor's frequency. Assign the task to the processor with the lowest diff/freq. If they are the same, the TC
			%is favoured, because of energy efficiency reasons (same execution time, less energy consumption).
			else
				diff1 = alloc_m(1,2)+job.instructions - threshold_cpu1;
				diff2 = alloc_m(2,2)+job.instructions - threshold_cpu2;
				time1 = diff1 * Processor.CPI/ (procs(1).freq * 1000);
				time2 = diff2 * Processor.CPI/ (procs(2).freq * 1000);
				if(time2 <= time1)
					cpu = 2;
				else
					cpu = 1;
				end
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
                [alloc_m, cpu_alloc(i)] = obj.first_fit2(procs, alloc_m, job_set(i), total_inst);
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

