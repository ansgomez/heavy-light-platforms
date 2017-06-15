%Matlab script for performance plots
%The same values as in the project
clear;
FREQ_MIN = 80;
FREQ_MAX = 100;
FREQ_STEP = 20;
UTIL_MIN = 50;
UTIL_MAX = 50;
UTIL_STEP = 10;
DELTA_TABLE = [0:0.05:1];
TOTAL_ITERATIONS = 10;
SAMPLING_RATE = 10000; %Hz
PERIOD_ms = 100;

%These variables are used for plotting the performance improvements - delta graph
UTIL_PER_CENT = [50]; %the utilizations for which we are going to plot the graph
FREQ_TABLE = [80]; %the frequencies for which we are going to plot the graph

%Specify the name of the input files
single_core_response_file = 'single_util_perf.xlsx';
max_par_response_file = 'Delta/max_par_delta_perf';
performance_response_file = 'Delta/perf_delta_perf.xlsx';
energy_response_file = 'Delta/energ_delta_perf.xlsx';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
									%%%%START%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

UTILIZATION_MEASUREMENTS = (UTIL_MAX - UTIL_MIN)/UTIL_STEP + 1;
DELTA_MEASUREMENTS = size(DELTA_TABLE,2);
FREQUENCY_MEASUREMENTS = (FREQ_MAX - FREQ_MIN)/FREQ_STEP + 1;
TOTAL_ITERATIONS = TOTAL_ITERATIONS + 1;
h_color = {'g'; 'b'; 'r'; 'k'; 'm'; 'y'; 'b'; 'c'};
handle = {'-^' ; '--s'; ':v'; '-.d'; ':x'; '-+'; '--o' ; ':*'};

response_singlecore = single_core_response_measurements(single_core_response_file, TOTAL_ITERATIONS, 10, 10000, PERIOD_ms); %SAMPLING_RATE=10khz
response_max_par = max_par_response_measurements(max_par_response_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, DELTA_MEASUREMENTS, FREQUENCY_MEASUREMENTS, SAMPLING_RATE);
response_performance = performance_response_measurements_delta(performance_response_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, DELTA_MEASUREMENTS, FREQUENCY_MEASUREMENTS, SAMPLING_RATE, FREQ_MIN);
response_energy = energy_response_measurements_delta(energy_response_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, DELTA_MEASUREMENTS, FREQUENCY_MEASUREMENTS, SAMPLING_RATE, FREQ_MIN);

for j=1:size(UTIL_PER_CENT,2)
	util = (UTIL_PER_CENT(j) - UTIL_MIN) / UTIL_STEP + 1;
	x_name = '\Delta';
	y_name = 'Makespan Imprv. (%)';
	x = DELTA_TABLE;
    
	for k=1:size(FREQ_TABLE,2)
 		freq = FREQ_TABLE(k);
		freq_index = (freq - FREQ_MIN)/FREQ_STEP + 1;
        title_name = sprintf('F_{LC} = %d, Utilization = %.1f', freq, UTIL_PER_CENT(j) / 100);
		y = [];
		
		%Plot max_par
		for d=1:DELTA_MEASUREMENTS
			y(d) = (response_singlecore(UTIL_PER_CENT(j) / 10) - response_max_par(freq_index,d,util)) / response_singlecore(UTIL_PER_CENT(j) / 10) * 100;
		end
		
		legend_name = sprintf('Max Parallelism');

        if k ==1
            figure
            legend(gca, 'show', 'Location', 'Best');
            xlabel(x_name,'FontSize', 30);
            ylabel(y_name,'FontSize', 28);
            set(gca,'FontSize', 22);
            set(gca,'YTick',[-40:20:60]);
            set(gca,'XTick',[0:0.2:1]);
            ylim([-40 60]);

            %title(title_name);
            grid on	
        else
            hold on
            legend('-DynamicLegend', 'Location', 'Best');
            %plot(x, y,[h_color{(k-1)*3 + 1} handle{3}],'DisplayName',legend_name, 'MarkerFaceColor', h_color{(k-1)*3 + 1});
            legend(gca, 'show', 'Location', 'Best');
            grid on	
        end
		
		%Plot performance
		hold on
		legend('-DynamicLegend', 'Location', 'Best');
		for d=1:DELTA_MEASUREMENTS
			y(d) = (response_singlecore(UTIL_PER_CENT(j) / 10) - response_performance(freq_index,d,util)) / response_singlecore(UTIL_PER_CENT(j) / 10) * 100;
		end
		legend_name = sprintf('DTM-M');
		plot(x, y,[h_color{(k -1)*3 + 2}],'DisplayName',legend_name, 'MarkerFaceColor', h_color{(k -1)*3 + 2},'LineWidth',2);
		legend(gca, 'show', 'Location', 'Best');
		grid on	

		
		%Plot energy
		hold on
		legend('-DynamicLegend', 'Location', 'Best');
		for d=1:DELTA_MEASUREMENTS
			y(d) = (response_singlecore(UTIL_PER_CENT(j) / 10) - response_energy(freq_index,d,util)) / response_singlecore(UTIL_PER_CENT(j) / 10) * 100;
		end
		legend_name = sprintf('DTM-E');
		plot(x, y,[h_color{(k-1)*3 + 3}],'DisplayName',legend_name, 'MarkerFaceColor', h_color{(k-1)*3 + 3},'LineWidth',2);
		legend(gca, 'show', 'Location', 'Best');
		grid on	
	end
end


