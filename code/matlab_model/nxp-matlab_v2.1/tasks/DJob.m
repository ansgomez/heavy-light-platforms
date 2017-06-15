classdef DJob < Job
    %DJOB subclass describes jobs with precedence constraints
    %   Dependent jobs share the same task_id of their 'initial'
    %   (independent) job, as well as their deadline.
    
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     PROPERTIES                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %variables
        name;
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTRUCTOR                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function obj = DJob(name,task_id, job_id, arrival_time, deadline, instructions)
            if(nargin < 3)
                fprintf('Error: wrong name, t_id, j_id');
                exit(1);
            end
   
            %default options
            if(nargin >= 2)
                obj.name = name; 
                obj.task_id = task_id;
                obj.job_id = job_id;
                obj.arrival_time = 0;
                obj.deadline = 0;
                obj.instructions =  randi([obj.MIN_INST, obj.MAX_INST]);
            end

            if(nargin >= 3)
               obj.arrival_time = arrival_time;
            end

            if(nargin >= 4)
               obj.deadline = deadline;
            end

            if(nargin >= 5)
               obj.instructions = instructions;
            end
            
            obj.type = 'D';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                      METHODS                        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function str = toRow(obj)
            str = sprintf('\t[%3d,"%1s\",%10.2f,%10.2f,%10.2f,%10.2f,%9d,%3d,%10.2f]', obj.task_id, obj.name, obj.arrival_time, obj.start_time, obj.finish_time, obj.deadline, obj.instructions, obj.cpu, obj.energy);            
        end
        
        %This function helps determine order of job within the global
        %queue. By default, they are ordered by arrival time, in ascending
        %fashion
        function [obj,idx,varargout]=sort(obj,varargin)
            varargout=cell(1,nargout-2);
            [~,idx,varargout{:}]=sort([obj.arrival_time],varargin{:});
            obj=obj(idx);
        end
   end
end
