classdef DSE
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %global variables
        taskSet;
        n_procs;
        procSets;
        
        %allocation cell arrays
        static_allocators;   %for static allocation
        dynamic_allocators;  %for dynamic allocation
%         par_ref_alloc;       %for theo. par. ref.
        
        %comparison objects
        c_dyn;
        c_stat;
%         c_par_ref;
    end
    
    methods
        
        function obj = DSE(procSets, taskSet)
%             if(nargin < 2)
%                 obj = obj.genTaskSet();
%             else
                obj.taskSet = taskSet;
%             end
            
            obj.procSets = procSets;
            obj.n_procs = 2;
            
            %define allocator vector
            obj.static_allocators{1} = FastestAlwaysAlloc();
            obj.static_allocators{2} = SlowestAlwaysAlloc();
            
            %define allocator vector
            obj.dynamic_allocators{1} = EarliestAvailableAlloc();
			obj.dynamic_allocators{2} = FirstFitAllocEnergyOpt();
            obj.dynamic_allocators{3} = FirstFitAllocPerf();
			obj.dynamic_allocators{4} = FirstFitAllocEnergy();
            %obj.dynamic_allocators{2} = EarliestSortedAlloc();
            %obj.dynamic_allocators{2} = SlowestAlwaysAlloc();
            %obj.dynamic_allocators{2} = SlowestIdleAlloc();
            %obj.dynamic_allocators{3} = FastestIdleAlloc();
            
            %define parallel reference vector
%             obj.par_ref_alloc = EarliestAvailableAlloc();
        end
        
        function obj = genTaskSet(obj, type, variability)
            if (nargin < 2)
               type = 'benini_var'; 
            elseif (nargin < 3)
                variability = 0.0;
            end
            if exist('taskSet') == 1
                %empty
            else
                obj.taskSet = TaskSet(obj.n_tasks, n_queues, type, variability);
            end
        end
        
        function obj = runStatic(obj, sys_pow)
            if(nargin < 2)
                sys_pow = 0;
            end
            %generate comparison object
            obj.c_stat = Comparison(obj.taskSet,obj.procSets,['seq'],obj.static_allocators); 
            if sys_pow == 1
                obj.c_stat = obj.c_stat.includeSystemPower();
            end
            obj.c_stat = obj.c_stat.run();
            %show results
            obj.c_stat.plotAll();
        end
        
        function obj = runDynamic(obj, sys_pow)
            if(nargin < 2)
                sys_pow = 0;
            end
            %generate comparison object
            obj.c_dyn = Comparison(obj.taskSet,obj.procSets,['par'],obj.dynamic_allocators); 
            if sys_pow == 1
                obj.c_dyn = obj.c_dyn.includeSystemPower();
            end
            obj.c_dyn = obj.c_dyn.run();
            %show results
            obj.c_dyn.plotAll();
        end
        
        function str = toString(obj)
            %IRC Frequency determines core's sleep power
            str = sprintf('Ntasks=%d\nNqueues=%d\nIRC Freq = %d\n', obj.taskSet.n_tasks, obj.taskSet.n_queues, Processor.IRC_FREQ);
        end
    end
    
end

