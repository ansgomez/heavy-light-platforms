classdef Task
    %TASK This class contains all of the task's info (period, wcet, etc)
    %   Tasks contain an array of jobs to be executed within a certain
    %   deadline.
    
    properties (Constant)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTANTS                       %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        N_JOBS = 10;
%         MIN_P_MS = 10;
%         MAX_P_MS = 100;
        PERIOD_MS = 100; %120; %50;
        MIN_INST = 500000;
        MAX_INST = 10000000;
    end
    
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     PROPERTIES                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %constants
        INST;
        
        %variables
        task_id;
        period;
        n_jobs;
        util;
        total_inst;
        
        %vectors
        jobs;
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTRUCTOR                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function obj = Task(id, p, n_jobs)
           
           if nargin  == 0
               fprintf('Error: wrong task_id');
           end
           
           if nargin >= 1
               obj.n_jobs = obj.N_JOBS;
               obj.period = obj.PERIOD_MS; %randi([obj.MIN_P_MS, obj.MAX_P_MS]);
               obj.task_id = id;
           end
           
           if nargin >= 2
               obj.period = p;
           end
           
           if nargin >= 3
               obj.n_jobs = n_jobs;
           end
           
           obj.INST = randi([obj.MIN_INST, obj.MAX_INST]);
           obj.jobs = Job.empty(0,obj.n_jobs);
           obj = obj.genJobs();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                      METHODS                        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function obj = genJobs(obj)
            if(obj.task_id == 0)
                for i=1:obj.n_jobs 
                    arrival = (i-1)*obj.period;
                    aux = IJob(obj.task_id, i, arrival, arrival+obj.period);
                    aux = aux.initDAG();
                    obj.jobs(i) = aux;
                end                
            else
                for i=1:obj.n_jobs 
                    arrival = (i-1)*obj.period;
                    aux = IJob(obj.task_id, i, arrival, arrival+obj.period, obj.INST);
                    obj.jobs(i) = aux;
                end
            end
        end
    end    
end

