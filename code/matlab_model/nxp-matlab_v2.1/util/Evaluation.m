classdef Evaluation
    %Evaluation of different allocators 
    %   This class creates N simluations, varying only the allocator,
    %   executing them in parallel, and saving each independent result in a
    %   vector for future processing
    
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     PROPERTIES                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %constants
        taskSet;
        procSet;
        
        %scalar variables
        type;       %determines type of evaluation (seq/par)
        sys_pow;    %determines if system power is included (1/0)
        
        %global vectors
        total_inst; %total number of instructions executed in evaluation
        
        %seq vectors
        sims;
        sim_hist;
        allocs;
        alloc_names;
        
        %par vectors
        parsims;
        parsim_hist;
        parallocs;
        
        %seq result vectors
        energy_seq;
        simtime_seq;
        missed_total_seq;
        tot_proc_util_seq;
        execution_time_seq;
		
        %seq result vectors
        energy_par;
        simtime_par;
        missed_total_par;
        tot_proc_util_par;
        execution_time_par;
		
        %reference vectors (for single-core only)
        proc_ref;
        energy_ref;
        missed_ref;
        simtime_ref;
		execution_time_ref;
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTRUCTOR                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = Evaluation(taskSet, procSet, type, allocators, sys_pow)
            obj.taskSet = taskSet;
            obj.procSet = procSet;
            obj.total_inst = [0];

            if(nargin < 3)
                obj.type = ['seq' 'par'];
            else
                obj.type = type;
            end

            if(nargin < 5)
                obj.sys_pow = 0;
            else
                obj.sys_pow = sys_pow; 
            end

            %generate all sequential allocators
            if(strfind(obj.type,'seq') > 0)
                obj.allocs = Allocator.empty(0,length(allocators));
                for i=1:length(allocators)
                   obj.allocs(i) = allocators{i}; 
                end
            end

            %generate all parallel allocators
            if(strfind(obj.type,'par') > 0)
                obj.parallocs = Allocator.empty(0,length(allocators));
                for i=1:length(allocators)
                   obj.parallocs(i) = allocators{i}; 
                end
            end

            obj = obj.setAllocNames();
        end
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     METHODS                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %This function runs all the simulations with different allocators
        function obj = run(obj)

            for j=1:obj.taskSet.n_queues
                %generate all sequential simulations
                if(strfind(obj.type,'seq') > 0)
                    obj.sims = Simulation.empty(0,length(obj.allocs));            
                    for i=1:length(obj.allocs)
                        obj.sims(i) = Simulation(obj.taskSet.n_tasks, obj.procSet, obj.allocs(i), obj.taskSet.job_queue{j}, obj.sys_pow);
                        obj.sims(i) = obj.sims(i).run();
                        %obj.sims(i).exportAll();
                    end
                    obj.sim_hist{j} = obj.sims;
                end

                %generate all parallel simulations
                if(strfind(obj.type,'par') > 0)
                    obj.parsims = ParSimulation.empty(0,length(obj.parallocs));
                    for i=1:length(obj.parallocs)
                        obj.parsims(i) = ParSimulation(obj.taskSet.n_tasks, obj.procSet, obj.parallocs(i), obj.taskSet.job_queue{j}, obj.sys_pow);
                        obj.parsims(i) = obj.parsims(i).run();
                        %obj.parsims(i).exportAll();
                    end
                    obj.parsim_hist{j} = obj.parsims;
                end

                %%%%%%   SAVE RESULTS %%%%%%
                obj.total_inst(j) = obj.taskSet.total_inst(j);
                obj = obj.saveResults(j);
            end

            %%%%%%   SHOW RESULTS %%%%%%
            %obj.generatePlots();
        end
        
        %This function saves all of the relevant results from the
        %evaluation of a job queue
        function obj = saveResults(obj, i)
            %Save parellel results
            if(strfind(obj.type,'par') > 0)
                for j=1:length(obj.parsims)
                    obj.energy_par(i,j) = obj.parsims(j).energy_total;
                    obj.simtime_par(i,j) = obj.parsims(j).simtime;
                    obj.tot_proc_util_par(i,j) = obj.parsims(j).total_proc_util;
                    obj.missed_total_par(i,j) = obj.parsims(j).missed_total;
					obj.execution_time_par(i,j) = obj.parsims(j).mean_execution_time;
                end
            end
            %Save sequential results
            if(strfind(obj.type,'seq') > 0)
                for j=1:length(obj.sims)
                    obj.energy_seq(i,j) = obj.sims(j).energy_total; % j=queue and i=allocator
                    obj.simtime_seq(i,j) = obj.sims(j).simtime;
                    obj.tot_proc_util_seq(i,j) = obj.sims(j).total_proc_util;
                    obj.missed_total_seq(i,j) = obj.sims(j).missed_total;
					obj.execution_time_seq(i,j) = obj.sims(j).mean_execution_time;
                end
            end
        end

        %This function generates the result plots for the evaluation
        function generatePlots(obj)
%             %%%%% PLOT SEQ VS PAR RATIO PER ALLOC %%%%%%
%             for j=1:length(obj.allocs)
%                 title = [obj.procSet.toString() obj.allocs(j).long_name];
%                 %%%%% PLOT ENERGY %%%%%%
%                 Plot.XYRatio(obj.energy_par(:,j),obj.energy_seq(:,j),{'Energy (par)'; 'Energy (seq)'; title } );
%                 %%%%% PLOT SIMTIME %%%%%
%                 Plot.XYRatio(obj.simtime_par(:,j),obj.simtime_seq(:,j),{'SimTime (par)'; 'SimTime (seq)'; title} );
%             end

            %%%%% PLOT SEQUENTIAL UTILIZATION %%%%%
            if(strfind(obj.type,'seq') > 0)
                for j=1:length(obj.allocs)
                    title = [obj.procSet.toString() ' (Seq)'];
                    Plot.XY(obj.tot_proc_util_seq(:,j),obj.energy_seq(:,j),{'Total Proc Util Seq (%)', 'Total Energy Seq (mJ)', title, obj.allocs(j).long_name}, j);
                end
            end

            %%%%% PLOT PARALLEL UTILIZATION %%%%%
            if(strfind(obj.type,'par') > 0)
                for j=1:length(obj.allocs)
                    title = [obj.procSet.toString() ' (Par)'];
                    Plot.XY(obj.tot_proc_util_par(:,j),obj.energy_par(:,j),{'Total Proc Util Par (%)', 'Total Energy Par (mJ)', title, obj.allocs(j).long_name},j);
                end
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %              GET   SET    METHODS                   %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %This funciton sets the evaluation to include system power in all
        %simulations
        function obj = includeSystemPower(obj)
            obj.sys_pow = 1;
        end

        %This funciton sets the evaluation to exclude system power in all
        %simulations
        function obj = excludeSystemPower(obj)
            obj.sys_pow = 0;
        end

        %This function returns the system power settings in string form
        function str = systemPowerString(obj)
            if(obj.sys_pow==1)
                %str = 'P_{sys}=P_{WC}';
                str = sprintf('P_{sys}=(%s)*P_{WC}',strtrim(rats(Processor.SYS_FREQ()/Processor.MAX_F)));
            else
                str = 'P_{sys}=0';
            end
        end

        %This function sets the alloc names
        function obj = setAllocNames(obj)
            obj.alloc_names = {};
            
            if(strfind(obj.type,'seq') > 0)
                for i=1:length(obj.allocs)
                    obj.alloc_names{i} = obj.allocs(i).name;
                end
            end
            
            if(strfind(obj.type,'par') > 0)
                for i=1:length(obj.parallocs)
                    obj.alloc_names{i} = obj.parallocs(i).name;
                end
            end
        end
        
        %This function returns all of the data from the evaluation, in
        %three different vectors
        function [seq,par,alloc_names] = getData(obj)
            alloc_names = obj.alloc_names;
            
            if(strfind(obj.type,'par') > 0)
                par = {obj.tot_proc_util_par, obj.energy_par};
            else
                par = {};
            end

            if(strfind(obj.type,'seq') > 0)
                seq = {obj.tot_proc_util_seq, obj.energy_seq};
            else
                seq = {};
            end
        end
    end
end
