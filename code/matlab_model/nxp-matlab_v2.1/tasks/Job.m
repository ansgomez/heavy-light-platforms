classdef Job < matlab.mixin.Heterogeneous
    %JOB This class represents a single job.
    %   A job can vary in terms on instructions to be executed, as well as
    %   the cpu it is mapped to. In addition, it can also be linked to a
    %   dependency DAG (implemented as a cell array) that gets activated
    %   upon the completion of a job
    
    properties (Access = public)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     PROPERTIES                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %identifiers        
        task_id;
        job_id;
        type;
        
        %job properties
        arrival_time;
        start_time;
        finish_time;
        deadline;
        instructions;
        energy;
        cpu;
    end

    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTRUCTOR                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = Job(task_id, job_id, arrival_time, deadline, instructions)
            %empty
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                      METHODS                        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %This function helps determine order of j[~,idx]=sort([obj.instructions],varargin{:});ob within the global
        %queue. By default, they are ordered by num. of instr. in
        %descdending fashion
        function [obj,idx,varargout]=sort(obj,varargin)
            varargout=cell(1,nargout-2);
            %[~,idx,varargout{:}]=sort([obj.instructions],varargin{:});
            [~,idx]=sort([obj.instructions],varargin{:});
            obj=obj(idx);
        end
         
        %This function exports a job's info to csv format
        function str = toRow(obj)
            %empty
        end
    end
end
