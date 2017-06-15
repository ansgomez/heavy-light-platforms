classdef ProcSet
    %ProcSet class is a set or Processors to be used in an Evaluation
    %   This class is one of the three basic elements to a Simulation
    %   (along with Allocator and JobQueue). Processors within a set can
    %   have different frequencies and/or power characteristics.
    
    properties (Constant)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTANTS                       %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %HOMOGENOUS FREQUENCY DISTRIBUTION (ALL HIGH)
        HOM_F = 1;
        %HETEROGENEOUS FREQUENCY DISTRIBUTION (divides F by powers of 2)
        HET_F = 2;
        %HIGH FREQUENCY
        HIGH_F = 3;
        %MEDIUM FREQUENCY
        MED_F = 4;
        %LOW FREQUENCY
        LOW_F = 5;
    end
    
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     PROPERTIES                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %constants
        n_procs;
        name;
        
        %auxiliary vectors
        freqs;
        
        %Processor vector
        procs;
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTRUCTOR                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = ProcSet(n_procs, set_freq, set_type, freq_vec)
           obj.n_procs = n_procs;
           obj.name = '';
           
           if nargin < 3
                type = mod(1:n_procs,2);
           else
                if length(set_type) == 1
                    type = ones(1,n_procs)*set_type;
                else
                    type = set_type;
                end
           end
         
           
           %initialize processors
           obj.procs = Processor.empty(0,n_procs);
           
           %if frequency vector is specified
           if nargin == 4
                   for i=1:obj.n_procs
                       obj.freqs(i) = freq_vec(i);
                       obj.procs(i) = Processor(i, obj.freqs(i), type(i));
                       aux = sprintf('F_{%d,%s}=%dM ', i, obj.procs(i).getType(), obj.freqs(i));
                       obj.name = [obj.name aux];
                   end
           else
               %%%%%%%%%%%% INITIALIZE PROCESSORS %%%%%%%%%%%%

               %if type is heterogeneous frequency distribution
               if set_freq == ProcSet.HET_F
                   for i=1:obj.n_procs
                       obj.freqs(i) = 204/(2^(i-1));
                       obj.procs(i) = Processor(i, obj.freqs(i), type(i));
                       aux = sprintf('F_{%d,%s}=%dM ', i, obj.procs(i).getType(), obj.freqs(i));
                       obj.name = [obj.name aux];
                   end
               %if type is homogeneous frequency distribution
               elseif set_freq == ProcSet.HOM_F || set_freq == ProcSet.HIGH_F
                   for i=1:obj.n_procs
                       obj.freqs(i) = Processor.MAX_F;
                       obj.procs(i) = Processor(i, obj.freqs(i), type(i));
                       aux = sprintf('F_{%d,%s}=%dM ', i, obj.procs(i).getType(), obj.freqs(i));
                       obj.name = [obj.name aux];
                   end
               %if type is homogeneous medium frequency
               elseif set_freq == ProcSet.MED_F
                   for i=1:obj.n_procs
                       obj.freqs(i) = Processor.MED_F;
                       obj.procs(i) = Processor(i, obj.freqs(i), type(i));
                       aux = sprintf('F_{%d,%s}=%dM ', i, obj.procs(i).getType(), obj.freqs(i));
                       obj.name = [obj.name aux];
                   end
               %if type is homogeneous medium frequency
               elseif set_freq == ProcSet.LOW_F
                   for i=1:obj.n_procs
                       obj.freqs(i) = Processor.LOW_F;
                       obj.procs(i) = Processor(i, obj.freqs(i), type(i));
                       aux = sprintf('F_{%d,%s}=%dM ', i, obj.procs(i).getType(), obj.freqs(i));
                       obj.name = [obj.name aux];
                   end
               else
                   %frequency type not recognized
                    exit(0);
               end
           end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     METHODS                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %This function sets the sleep power of ALL processors to ZERO. This
        %is to be used a sample reference case.
        function obj = setSleepZero(obj)
            for i=1:obj.n_procs
                obj.procs(i).p_sleep = 0;
            end
        end
        
        %This function returns the information of the ProcSet's frequencies
        %in string form
        function name = toString(obj)
            name = obj.name;
        end
        
        %This function returns the information of the ProcSet's power model
        %in string form
        function name = toPowerString(obj)
            name = [];
            
            for i=1:obj.n_procs
                if obj.procs(i).p_sleep == 0
                    name = sprintf('P_{act}=%d , P_{sleep} = %d ', obj.procs(i).p_act, obj.procs(i).p_sleep);
                    return
                else
                    name = sprintf('P_{act}=%d , P_{sleep} = %d ', obj.procs(i).p_act, obj.procs(i).p_sleep);
                end
               %aux = sprintf('P_{act,sleep_{%d}}=[%3.1f,%3.1f]mW \n',i,obj.procs(i).p_act,obj.procs(i).p_sleep);
               %name = [name aux]; 
            end
        end
    end
end

