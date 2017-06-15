classdef IJob < Job
    %IJOB subclass is for jobs with no precedent constraints
    %   By independent job, it is meant that there are no precedence
    %   constraints to execute this job. The execution of this job can be
    %   used to trigger the execution of a DAG, which is composed of
    %   dependent jobs (DJobs)
    
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     PROPERTIES                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %constants
        MAX_DAG = 2;
        
        %vectors
        dag;
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTRUCTOR                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function obj = IJob(task_id, job_id, arrival_time, deadline, instructions)
           if(nargin < 2)
                fprintf('Error: wrong t_id, j_id');
                exit(1);
            end
   
            %default options
            if(nargin >= 2)
                obj.task_id = task_id;
                obj.job_id = job_id;
                obj.arrival_time = 0;
                obj.deadline = 0;
                obj.instructions =  1000000;
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
           
            obj.type = 'I';
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                      METHODS                        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = initDAG(obj, num) 
            obj.type = 'DAG';
            
            if(nargin < 2 || num < 1 || num > obj.MAX_DAG)
                num = randi([1 obj.MAX_DAG]);
            end
            
            %if(num == 1)
                obj.dag = { [DJob('A', obj.task_id, obj.job_id, obj.arrival_time, obj.deadline, obj.instructions)], [DJob('B', obj.task_id, obj.job_id, obj.arrival_time, obj.deadline, obj.instructions)] };
            %else 
            %    obj.dag = { [DJob('C', obj.task_id, obj.job_id, obj.arrival_time, obj.deadline, obj.instructions) DJob('D', obj.task_id, obj.job_id, obj.arrival_time, obj.deadline, obj.instructions)], [DJob('E', obj.task_id, obj.job_id, obj.arrival_time, obj.deadline, obj.instructions)] };
            %end            
        end
        
        function str = toRow(obj)
            str = sprintf('\t[%3d,%3d,%10.2f,%10.2f,%10.2f,%10.2f,%9d,%3d,%10.2f]', obj.task_id, obj.job_id, obj.arrival_time, obj.start_time, obj.finish_time, obj.deadline, obj.instructions, obj.cpu, obj.energy);
            
            if(strcmp(obj.type,'DAG')==1)
                for i=1:length(obj.dag)
                    job_aux = obj.dag{i};
                    
                    if(length(job_aux) > 1)
                        
                    else
                        if(i~=length(obj.dag) || length(obj.dag)==1)
                            str = strcat(str,',\n');
                        end
                        str = strcat(str, job_aux.toRow());
                        
                        if(i~=length(obj.dag))
                            str = strcat(str,',\n');
                        else
                            str = strcat(str,',');
                        end
                    end
                end
%             else
%                 str = strcat(str, ',\n');
            end
        end
        
        %This function helps determine order of job within the global
        %queue. By default, they are ordered by num. of instr. in
        %descdending fashion
        function [obj,idx,varargout]=sort(obj,varargin)
            varargout=cell(1,nargout-2);
            [~,idx,varargout{:}]=sort([obj.instructions],varargin{:});
            obj=obj(idx);
        end
    end
end

