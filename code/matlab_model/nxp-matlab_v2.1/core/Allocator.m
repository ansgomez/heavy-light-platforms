classdef Allocator  < matlab.mixin.Heterogeneous
    %ALLOCATOR This interface determines which CPU a job is executed on
    %   The allocator maintains data about previous jobs executions, and
    %   based on this info, it makes its allocation decisions.
    
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     PROPERTIES                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %constants
        name;
        n_procs;
        long_name;
        
        %decision-making data
        task_table;
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTRUCTOR                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = Allocator()
            %empty
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     METHODS                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %This function, when defined, will determine on which CPU to
        %execute each job within a jobset
        function [job_queue, cpu_alloc] = allocate(obj, procs, job_queue, job_set_index, time)
            %empty
        end
        
        %This function, when defined, will determine on which CPU to
        %execute each job within a jobset
        function cpu_alloc = allocateSingle(obj, procs, job, time)
            %empty
        end
        
        %This function, when define, will update the allocator's decision
        %table with the new information from the job's execution
        function obj = updateTable(obj, job)
            %empty
        end
    end
    
end

