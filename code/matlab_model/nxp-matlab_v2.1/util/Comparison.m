classdef Comparison
    %Comparison of different Evaluations with different ProcSets
    %   This class creates M evaluations, varying only the processor set.
    %   Each evaluation will then execute the jobqueues in sequence and
    %   parallel, for each allocator registered
    
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     PROPERTIES                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %variables
        type;
        sys_pow;     %this variable determines if system power is included
        
        %single core reference variables
        single_core_procSet;
        single_core_eval;
        
        %par theo reference values
        par_theo_eval;
        
        %global vectors
        taskSet;
        procSets;
        allocators;
        evals;
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTRUCTOR                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = Comparison(taskSet, procSets, type, allocators)
            obj.taskSet = taskSet;
            if(length(procSets) == 1)
                obj.procSets = ProcSet.empty(0,1);
                obj.procSets(1) = procSets;
            else
                obj.procSets = procSets;
            end
            obj.type = type;
            obj.allocators = allocators;
            
            %no system power by default
            obj.sys_pow = 0;
            
            %initialize TaskSet and ProcSet
            obj.evals = Evaluation.empty(0,length(procSets));
            
            %single core reference
            obj.single_core_procSet = ProcSet(1,ProcSet.HIGH_F, Processor.WC);
        end
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     METHODS                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %This funciton performs the single core simulation and initialites reference vectors
        function obj = runSingleCore(obj)
            alloc{1} = FastestAlwaysAlloc();
            obj.single_core_eval = Evaluation(obj.taskSet, obj.single_core_procSet, 'seq', alloc, obj.sys_pow);
            obj.single_core_eval = obj.single_core_eval.run();
            obj.single_core_eval.proc_ref = obj.single_core_eval.tot_proc_util_seq(:,1);
            obj.single_core_eval.energy_ref = obj.single_core_eval.energy_seq(:,1);
            obj.single_core_eval.missed_ref = obj.single_core_eval.missed_total_seq(:,1);
            obj.single_core_eval.simtime_ref = obj.single_core_eval.simtime_seq(:,1); 
			obj.single_core_eval.execution_time_ref = obj.single_core_eval.execution_time_seq(:,1); 
        end

        %This funciton performs the par theo simulation and initialites
        %reference vectors, depending on the evaluation's procSet
        function obj = runParTheo(obj, procSet)
            par_theo_ts = TaskSet(2,10,'par_theo', procSet);
            alloc{1} = RoundRobinAlloc();
            obj.par_theo_eval = Evaluation(par_theo_ts, procSet, 'par', alloc, obj.sys_pow);
            obj.par_theo_eval = obj.par_theo_eval.run();
            obj.par_theo_eval.proc_ref = obj.par_theo_eval.tot_proc_util_par(:,1);
            obj.par_theo_eval.energy_ref = obj.par_theo_eval.energy_par(:,1);
            obj.par_theo_eval.missed_ref = obj.par_theo_eval.missed_total_par(:,1);
            obj.par_theo_eval.simtime_ref = obj.par_theo_eval.simtime_par(:,1);
			obj.par_theo_eval.execution_time_ref = obj.par_theo_eval.execution_time_par(:,1); 
        end
        
        %This function runs all the simulations with different allocators
        function obj = run(obj)
            %run single core simulation and initiate reference vectors
            obj = obj.runSingleCore();
            
            %run sequential simulations 
            for i=1:length(obj.procSets)
                obj = obj.runParTheo(obj.procSets(i));
                obj.evals(i) = Evaluation(obj.taskSet, obj.procSets(i), obj.type, obj.allocators, obj.sys_pow);
                obj.evals(i) = obj.evals(i).run();
            end
        end

        %This is a generic funciton for plotting single-core vs arbitrary procsets
        function plotGeneric(obj, procSets_i,data_type,plot_type)
            %get datatype for the single-core
            [singlecore_X,singlecore_Y] = obj.getSingleCoreReference(data_type);
            %get datatype for par theo
            [par_theo_X,par_theo_Y] = obj.getParTheoReference(data_type);
            %default values
            if(nargin < 3)
                data_type = 'energy'; %plot the energy consumption
            end
            if(nargin < 4)
                plot_type = 'abs'; %plot absolute values
            end
            
            %initialize plot with single-core results
            aux = obj.getPlotTitle(procSets_i, data_type, plot_type);
            
            %transform single core reference data and plot
            dataY = Plot.transformType(plot_type,singlecore_Y,singlecore_Y);
            Plot.XY(singlecore_X, dataY,aux,1,1);
           
            %iterate through each of the preselected procsets
            for j=1:length(procSets_i)
                eval = obj.evals(procSets_i(j));
                %plot data for all allocators
                for k=1:length(eval.alloc_names)
                    %extract the relevant data
                    multicore_Y = obj.getPlotData(eval,data_type);
                    %get the legend name for this iteration
                    legend = obj.getLegend(procSets_i,j,k,eval);
                    %transform plot data as necessesary
                    dataY = Plot.transformType(plot_type,multicore_Y(:,k),singlecore_Y);
                    %Add the data to the plot
                    Plot.addXY(singlecore_X, dataY, legend, k+1, k+1);
                end
            end   
            
            %transform par theo reference data and plot
            dataY = Plot.transformType(plot_type,par_theo_Y,singlecore_Y);
            Plot.addXY(singlecore_X, dataY,obj.getLegend(),k+2,k+2);
        end

        %function compareScatterSingle(obj,procSets_i, singe_core_ref, multi_core_ref, label)
        %This functions merges all of the results for arbitrary procsets
        function compareScatter(obj, procSets_i, data_type, plot_type)
            %default values
            if(nargin < 3)
                data_type = 'missed'; %plot the energy consumption
            end
            if(nargin < 4)
                plot_type = 'abs'; %plot absolute values
            end
            
            %get datatype for the single-core
            [singlecore_X,singlecore_Y] = obj.getSingleCoreReference('energy');
            [singlecore_X,singlecore_Z] = obj.getSingleCoreReference(data_type);
            %get datatype for par theo
            [par_theo_X,par_theo_Y] = obj.getParTheoReference('energy');
            [par_theo_X,par_theo_Z] = obj.getParTheoReference(data_type);
            
            %initialize scatter with single-core results
            aux = obj.getScatterTitle(procSets_i, data_type, plot_type);
            
            %transform single core reference data and plot
            dataY = Plot.transformType(plot_type,singlecore_Y,singlecore_Y);
            dataZ = Plot.transformType(plot_type,singlecore_Z,singlecore_Z);
            Plot.scatterXYZ(singlecore_X, dataY, dataZ, aux,1,1);

            %iterate through each of the preselected procsets
            for j=1:length(procSets_i)
                eval = obj.evals(procSets_i(j));
                %plot data for all allocators
                for k=1:length(eval.alloc_names)
                    %extract the relevant data
                    multicore_Y = obj.getPlotData(eval,'energy');
                    multicore_Z = obj.getPlotData(eval,data_type);
                    %get the legend name for this iteration
                    legend = obj.getLegend(procSets_i,j,k,eval);
                    %transform plot data as necessesary
                    dataY = Plot.transformType(plot_type,multicore_Y(:,k),singlecore_Y);
                    dataZ = Plot.transformType(plot_type,multicore_Z(:,k),singlecore_Z);
                    %Add the data to the plot
                    Plot.addScatterXYZ(singlecore_X, dataY, dataZ, legend, k+1, k+1);
                end
            end   
            
            %transform par theo reference data and plot
            dataY = Plot.transformType(plot_type,par_theo_Y,singlecore_Y);
            dataZ = Plot.transformType(plot_type,par_theo_Z,singlecore_Z);
            Plot.addScatterXYZ(singlecore_X, dataY, dataZ, obj.getLegend(),k+2,k+2);
        end
        
        
        %This funciton prints the most relevant plots from a single Comparison
        function plotAll(obj, procSets_i)
            if(nargin < 2)
                procSets_i = [1];
            end
            
%             obj.plotGeneric(procSets_i,'energy','abs');
            obj.plotGeneric(procSets_i,'energy','rel');
			obj.plotGeneric(procSets_i,'performance','rel');
%             obj.plotGeneric(procSets_i,'inst','abs');
%             obj.compareScatter(procSets_i,'simtime');
%             obj.compareScatter(procSets_i,'missed'); 
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %              GET   SET    METHODS                   %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
        %This function returns the selected sequential data from an eval
        function seq = getSeqPlotData(obj, eval, data)
            if strcmp(data,'energy') == 1
                seq = eval.energy_seq;
            elseif strcmp(data,'inst') == 1
                %eval.energy_seq./obj.single_core_eval.total_inst;
                seq = bsxfun(@rdivide,eval.energy_seq,obj.single_core_eval.total_inst.');
            elseif strcmp(data,'missed') == 1
                seq = eval.missed_total_seq;
            elseif strcmp(data,'simtime') == 1
                seq = eval.simtime_seq;
            else
                %data type not recognized
                err = MException('ResultChk:OutOfRange','Requested data unavailable');
                errCause = MException('ResultChk:BadInput', 'SeqData type not recognized');
                err = addCause(err,errCause);
                throw(err);
            end
        end
        
        %This function returns the parallel sequential data from an eval
        function par = getParPlotData(obj, eval, data)
            if strcmp(data,'energy') == 1
                par = eval.energy_par;
            elseif strcmp(data,'inst') == 1
                %eval.energy_par./obj.single_core_eval.total_inst;
                par = bsxfun(@rdivide,eval.energy_par,obj.single_core_eval.total_inst.');
            elseif strcmp(data,'missed') == 1
                par = eval.missed_total_par;
            elseif strcmp(data,'simtime') == 1
                par = eval.simtime_par;
			elseif strcmp(data,'performance') == 1
                par = eval.execution_time_par;
            else
                %data type not recognized
                err = MException('ResultChk:OutOfRange','Requested data unavailable');
                errCause = MException('ResultChk:BadInput', 'ParData type not recognized');
                err = addCause(err,errCause);
                throw(err);
            end
        end
        
        %This function returns the appropriate data vector according to simulation and data type
        function multi_core = getPlotData(obj, eval, data)
            %set correct energy vector (according to type)
            if (strfind(obj.type,'seq') > 0)
                multi_core = obj.getSeqPlotData(eval,data);
            elseif (strfind(obj.type,'par') > 0)
                multi_core = obj.getParPlotData(eval,data);
            else
                %data type not recognized
                err = MException('ResultChk:OutOfRange','Requested data unavailable');
                errCause = MException('ResultChk:BadInput', 'Plot type not recognized');
                err = addCause(err,errCause);
                throw(err);
            end 
        end
        
        %This function returns the appropriate reference data
        function [x,y] = getSingleCoreReference(obj,data_type)
            x = obj.single_core_eval.proc_ref;
            if strcmp(data_type,'energy') == 1
                y = obj.single_core_eval.energy_ref;
            elseif strcmp(data_type,'inst') == 1
                y = obj.single_core_eval.energy_ref ./ obj.single_core_eval.total_inst.';
            elseif strcmp(data_type,'missed') == 1
                y = obj.single_core_eval.missed_total_seq;
            elseif strcmp(data_type,'simtime') == 1
                y = obj.single_core_eval.simtime_seq;
			elseif strcmp(data_type,'performance') == 1
                y = obj.single_core_eval.execution_time_ref;
            else
                %data type not recognized
                err = MException('ResultChk:OutOfRange','Requested data unavailable');
                errCause = MException('ResultChk:BadInput', 'SingleRefData type not recognized');
                err = addCause(err,errCause);
                throw(err);
            end
        end
        
        %This function returns the appropriate reference data
        function [x,y] = getParTheoReference(obj,data_type)
            x = obj.single_core_eval.proc_ref;
            if strcmp(data_type,'energy') == 1
                y = obj.par_theo_eval.energy_ref;
            elseif strcmp(data_type,'inst') == 1
                y = obj.par_theo_eval.energy_ref ./ obj.par_theo_eval.total_inst.';
            elseif strcmp(data_type,'missed') == 1
                y = obj.par_theo_eval.missed_total_par;
            elseif strcmp(data_type,'simtime') == 1
                y = obj.par_theo_eval.simtime_par;
			elseif strcmp(data_type,'performance') == 1
                y = obj.par_theo_eval.execution_time_ref;
            else
                %data type not recognized
                err = MException('ResultChk:OutOfRange','Requested data unavailable');
                errCause = MException('ResultChk:BadInput', 'ParRefData type not recognized');
                err = addCause(err,errCause);
                throw(err);
            end
        end
        
        %This function returns a plot's legend based on the type
        function aux = getLegend(obj, procSets_i, j, k, eval)
            %par theo case
            if (nargin < 2)
               aux = ['Max.Parallelism'];
               return;
            end
            %set the legend for the plot
            if(length(procSets_i)==1)
                aux = [eval.alloc_names{k}];
            else
                aux = [obj.procSets(procSets_i(j)).toString() eval.alloc_names{k}];
            end
        end
        
        %This function returns the units for a Y label based on data type
        function aux = getLabelUnits(obj,data_type, plot_type)
            if strcmp(plot_type,'rel') == 1
                aux = 'Savings (%)';
            else
                if strcmp(data_type,'energy') == 1
                    aux = '[uJ]';
                elseif strcmp(data_type,'inst') == 1
                    aux = '[uJ/inst]';
                elseif strcmp(data_type,'missed') == 1
                    aux = '[%]';
                elseif strcmp(data_type,'simtime') == 1
                    aux = '[ms]';
                else
                    %data type not recognized
                    err = MException('ResultChk:OutOfRange','Requested data unavailable');
                    errCause = MException('ResultChk:BadInput', 'LabelUnitsData type not recognized');
                    err = addCause(err,errCause);
                    throw(err);
                end
            end
        end

        %This function returns the Y label for a particular plot and data type
        function aux = getLabelY(obj, data_type, plot_type)
            %get the units
            aux = obj.getLabelUnits(data_type,plot_type);
            %add the name
            if strcmp(data_type,'energy') == 1
                aux = sprintf('Energy %s', aux);
            elseif strcmp(data_type,'inst') == 1
                aux = sprintf('Energy per Instruction %s', aux);
            elseif strcmp(data_type,'missed') == 1
                aux = sprintf('Deadlines Missed %s', aux);
            elseif strcmp(data_type,'simtime') == 1
                aux = sprintf('Completion Time %s', aux);
			elseif strcmp(data_type,'performance') == 1
                aux = sprintf('Execution Time %s', aux);
            else
                %data type not recognized
                err = MException('ResultChk:OutOfRange','Requested data unavailable');
                errCause = MException('ResultChk:BadInput', 'LabelYData type not recognized');
                err = addCause(err,errCause);
                throw(err);
            end
        end

        %This function returns the title of a plot based on the type and procsets
        function aux = getPlotTitle(obj,procSets_i, data_type, plot_type)
            labelY = obj.getLabelY(data_type,plot_type);
                        
            if(length(procSets_i)==1)
                title = sprintf('%s (%s , N_{tasks}=%d, \\Delta = %1.2f, IRC=%dM)', obj.procSets(procSets_i(1)).toString(), obj.single_core_eval.systemPowerString(), obj.taskSet.n_tasks, obj.taskSet.variability, Processor.IRC_FREQ());
            else
                title = sprintf('Energy Comparison - (%s)', obj.single_core_eval.systemPowerString());
            end
            aux = {'Single Core Util (%)', labelY, title, 'Single Core (WC)'};
        end
        
        %This function returns the title of a plot based on the type and procsets
        function aux = getScatterTitle(obj,procSets_i, data_type, plot_type)
            labelY = obj.getLabelY('energy',plot_type);
            labelZ = obj.getLabelY(data_type,plot_type);
            
            if(length(procSets_i)==1)
                title = sprintf('%s (%s , N_{tasks}=%d, IRC=%dM)', obj.procSets(procSets_i(1)).toString(), obj.single_core_eval.systemPowerString(), obj.taskSet.n_tasks, Processor.IRC_FREQ());
            else
                title = sprintf('Energy Comparison - (%s)', obj.single_core_eval.systemPowerString());
            end
            aux = {'Single Core Util (%)', labelY, title, labelZ};
        end
        
        %This function will make all power calculations include system power
        function obj = includeSystemPower(obj)
            obj.sys_pow = 1;
        end

        %This function will make all power calculations exclude system power
        function obj = excludeSystemPower(obj)
            obj.sys_pow = 0;
        end
    end
end

