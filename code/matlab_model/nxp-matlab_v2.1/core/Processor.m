classdef Processor
    %PROCESSOR This class holds the processor's info. 
    %   The main variables include frequency and power consumption. This
    %   class holds information regarding all of the jobs executed on a
    %   processor, and is responsible for exporting it at the end of the
    %   simulation
    
    
    properties (Constant)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTANTS                       %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %MAXIMUM PROC FREQUENCY
        MAX_F = 204; %[MHZ]
        %MAXIMUM PROC FREQUENCY
        MED_F = 150; %[MHZ]
        %MAXIMUM PROC FREQUENCY
        LOW_F = 102; %[MHZ]
        %CPI
        CPI = 1;
        %IRC Frequency - determines sleep power of a core
        %IRC_FREQ = 0; %[MHz]
        
        %Processor Types
        WC = 1;
        TYP = 2;
    end
    
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     PROPERTIES                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %identifiers
        proc_id;
        type;

        %scalar 'constant' variables
        freq;
        p_act;
        p_sleep;
        
        %vector variables
        curr_job;
        time_cjob;
        energy;
        time;
        missed;
        sleep_times;         %timestamps of sleep times, to help calculate system sleep power
        
        %auxiliary variables
        util;
        total_inst_exe;   %total instructions executed
        total_energy;
        energy_aux;
        exec_time;
        exec_jobs;
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                    CONSTRUCTOR                      %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = Processor(id, freq, type)

           if(nargin == 0)
               fprintf('Error: wrong proc id!\n');
           end
            
           if(nargin >= 1)
               obj.proc_id = id;
               %create a core type,freq, in case none is provided
               obj.type = mod(id,2)+1;
               %obj.freq = obj.MAX_F / (obj.type);
               %obj.p_act = obj.P_DENSITY(obj.type) * obj.freq;
               %obj.p_sleep = obj.P_DENSITY(obj.type) * Processor.IRC_FREQ();
           end
            
           if(nargin >= 2)
               obj.freq = freq;
           end
           
           %set active/sleep powers according to type
           if(nargin >= 3)
               obj.type = type;
               obj.p_act = obj.P_DENSITY(type)*obj.freq;
               obj.p_sleep = obj.P_DENSITY(type) * Processor.IRC_FREQ(); 
           end
           
           %initialize variables
           obj.curr_job = [ 0 ];
           obj.time_cjob = [ 0 ];
           obj.energy = [ 0 ];
           obj.time = [ 0 ];
           obj.sleep_times = -1;
           obj.energy_aux = 0;
           obj.util = 0;
           obj.exec_time = 0;
           obj.exec_jobs = 0;
           obj.total_energy = 0;
           obj.total_inst_exe = 0;
        end
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                      METHODS                        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %This function returns 1 if the proc is sleep at time t, 0 otherwise
        function sleep = isIdle(obj, time_t)
            if (obj.time(end) > time_t)
                sleep = 0; %this means it's busy
            else
                sleep = 1; %this means it's sleep
            end
        end
        
        %This function determines the time of the next event
        function next_time = nextTime(obj, start_time)
            %if start time is in the future, jump to it
            if obj.time(end) < start_time
                next_time = start_time;
            %otherwise, wait until processor is free
            else
                next_time = obj.time(end);
            end
        end
        
        %This function performs the initial traces on both the job and the
        %processor
        function obj = traceStart(obj, job)
            %increase energy by sleep power (if necessary)
            if job.start_time > obj.time(end)
                %if the job starts (much) after the previous ended, add sleep
                e_aux = obj.energy(end)+(job.start_time-obj.time(end))*obj.p_sleep;
                if obj.sleep_times == -1
                    obj.sleep_times = [0 job.start_time];
                else
                    obj.sleep_times = [obj.sleep_times obj.time(end) job.start_time];
                end
            else
                %initial case where 1st job arrived at t=0
                if obj.sleep_times == -1
                    obj.sleep_times = [0 0];
                end
                
                %if the two jobs are continuous, there was no sleep
                e_aux = obj.energy(end);
            end
            
            %update other variables
            obj.energy = [obj.energy e_aux];
            obj.time = [obj.time job.start_time];
            obj.curr_job = [obj.curr_job 0 job.task_id];
            obj.time_cjob = [obj.time_cjob job.start_time job.start_time];            
        end
        
        %This function performs the ending traces on both the job and the
        %processor
        function obj = traceStop(obj, job)
           obj.energy = [obj.energy obj.energy_aux];
           obj.time = [obj.time job.finish_time];
           %TODO change task_id to 'task_id'.'job_id'
           obj.curr_job = [obj.curr_job job.task_id 0];
           obj.time_cjob = [obj.time_cjob job.finish_time job.finish_time];            
           
           %check if deadline was missed
           if job.finish_time > job.deadline 
               obj.missed = [obj.missed job];
           end
        end
        
        %This function calculates the execution time of a number of
        %instructions according to the CPI and the frequency.
        function time_ms = calcExecTime(obj, instructions)
            cycles = instructions * Processor.CPI;
            time_ms = cycles/(obj.freq*1000); %scaled for millisec
        end

        %This function 'executes' one job and updates the statistics
        function [obj, job] = executeJob(obj, job, now)
           %find the time for the job's start
           start_time = max(obj.nextTime(job.arrival_time),now);
           job.start_time = start_time;
           
           %%%%%%%   TRACE JOB START    %%%%%
           obj = obj.traceStart(job);
           
           %%%%%%%   ACTUAL EXECUTION   %%%%%
           t = obj.calcExecTime(job.instructions);
           e = t * obj.p_act;
           job.finish_time = job.start_time + t;
           job.energy = e;
           obj.energy_aux = obj.energy(end) + e;
           obj.exec_jobs = obj.exec_jobs + 1;
           obj.exec_time = obj.exec_time + t;
           obj.total_inst_exe = obj.total_inst_exe + job.instructions;
           
           %%%%%%%   TRACE JOB END    %%%%%%
            obj = obj.traceStop(job);
        end

        %This function finalizes all of the processor's data
        function obj = endSim(obj, end_time)
            %increase energy by sleep power (if necessary)
            if end_time > obj.time(end)
                %if the sim ends (much) after the last job ended, add sleep power
                e_aux = obj.energy(end)+(end_time-obj.time(end))*obj.p_sleep;
                if obj.sleep_times == -1
                    obj.sleep_times = [0 end_time];
                else
                    obj.sleep_times = [obj.sleep_times obj.time(end) end_time];
                end
            else
                %if the last job ended the simulation, no sleep power
                e_aux = obj.energy(end);
                %if util was 100%, no sleep time
                if obj.sleep_times == -1
                    obj.sleep_times = [0 0];
                end
            end
            
            obj.energy = [obj.energy e_aux];
            obj.time = [obj.time end_time];
            obj.curr_job = [obj.curr_job obj.curr_job(end)];
            obj.time_cjob = [obj.time_cjob end_time]; 
            obj.util = 100*obj.exec_time / end_time;
            obj.total_energy = e_aux;
        end
        
        %This function returns the type of the proc in string format
        function str = getType(obj)
            if obj.type == Processor.WC
                str = 'WC';
            elseif obj.type == Processor.TYP
                str = 'TYP';
            else
                str = '?';
                exit(0);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %              GET   SET    METHODS                   %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %This function sets the sleep power according to a ratio
        function obj = setActiveSleepRatio(obj, ratio)
            obj.p_sleep = (obj.P_DENSITY(obj.type)/ratio) * 12; %IRC runs at 12MHz
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                 EXPORT    METHODS                   %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %This function exports all of the processor's data (figs, csv and js)
        function obj = exportAll(obj, prefix, end_time)
            %export all data
            obj.exportData(prefix);
            obj.exportPlots(prefix);
        end
        
        %This function exports the processor's characteristics to js
        function str = toJSRow(obj)
            str = sprintf('[%3d, %3d, %3d, %10.2f, %10.2f, %10.2f, %10.2f]', obj.proc_id, obj.freq, Processor.CPI, obj.p_act, obj.p_sleep, obj.total_energy, obj.util);
        end
        
        %This function exports all of the jobs data (energy, schedule, etc)
        %to csv format in the 'data' folder
        function exportData(obj, prefix)
            prefix = sprintf('%s/data/', prefix);
            [status,message,messageid] = mkdir(prefix);
            
            %export processor data
            name = sprintf('%score_%d_energy.csv',prefix, obj.proc_id);
            csvwrite(name,obj.energy.');
            name = sprintf('%score_%d_curr_job.csv',prefix, obj.proc_id);
            csvwrite(name,obj.curr_job.');
            name = sprintf('%score_%d_time_cjob.csv',prefix, obj.proc_id);
            csvwrite(name,obj.time_cjob.');
            name = sprintf('%score_%d_time.csv',prefix, obj.proc_id);
            csvwrite(name,obj.time.'); 
            
            %export missed deadlines
            name = sprintf('%score_%d_missed.csv',prefix, obj.proc_id);
            len = length(obj.missed);
            fid = fopen(name,'w');
            if len > 0
                for i=1:len
                    fprintf(fid, sprintf('%3d,%s\n',i,obj.missed(i).toRow()));
                end
            end
            fclose(fid);
        end
        
        %This function exports the processor's plots to fig, png and jpeg
        %files
        function exportPlots(obj, prefix)
            prefix = sprintf('%s/sim/', prefix);
            [status,message,messageid] = mkdir(prefix);
            
            %Save energy
            h = figure('Visible','Off');
            plot(obj.time, obj.energy);
            str = sprintf('Core %d: Energy vs Time',obj.proc_id);
            title(str);
            ylabel('Energy (uJ)');
            xlabel('Time (ms)');
            name = sprintf('%score%d_energy_v_time',prefix, obj.proc_id);
            obj.savePlots(h, name);
            
            %Save schedule
            h = figure('Visible','Off');
            plot(obj.time_cjob, obj.curr_job);
            str = sprintf('Core %d: Scheduling Function',obj.proc_id);
            title(str);
            ylabel('Task');
            set(gca,'ytick', (0:1:max(obj.curr_job)));
            xlabel('Time (ms)');
            axis([xlim 0 (max(obj.curr_job)+1)])
            name = sprintf('%score%d_curr_job_v_time',prefix, obj.proc_id);
            obj.savePlots(h, name);
        end
        
        %This functions saves a figure to different formats
        function savePlots(obj, h, name)
            %saveas(h,name,'fig')
            saveas(h,name,'png') 
            %saveas(h,name,'jpg')
        end
    end
    
    methods (Static)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                 STATIC    METHODS                   %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %This function returns(and sets) the Power Density
        function out=POW_DENSITY(P_WC,P_TYP)
            persistent p_density;
            if isempty(p_density)
                %Normalized Power Density Constants
                %%%%   Array[1]=Worst-Case  ;   Array[2]=Nominal
                p_density   = [0.8 0.56]; %Active Power [mW/MHz]
            end
            if nargin
                p_density = [P_WC, P_TYP]; 
            end
            out=p_density;             
        end
        
        function out=P_DENSITY(type)
            den = Processor.POW_DENSITY();
            out = den(type);
        end
        
        
        %This function returns(and sets) the IRC Frequency
        function out=IRC_FREQ(f)
            persistent irc;
            if isempty(irc), irc = 0; end
            if nargin, irc=f; end
            out=irc; 
        end
        
        %This function returns(and sets) the IRC Frequency
        function out=SYS_IRC_FREQ(f)
            persistent sys_irc;
            if isempty(sys_irc), sys_irc = 0; end
            if nargin, sys_irc=f; end
            out=sys_irc; 
        end
        
        %This function returns(and sets) the IRC Frequency
        function out=SYS_FREQ(f)
            persistent sys_irc;
            if isempty(sys_irc), sys_irc = 0; end
            if nargin, sys_irc=f; end
            out=sys_irc; 
        end
    end
end

