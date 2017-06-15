%Matlab script for performance plots
%The same values as in the project
clear;
FREQ_MIN = 100;
FREQ_MAX = 100;
FREQ_STEP = 10;
UTIL_MIN = 10;
UTIL_MAX = 100;
UTIL_STEP = 10;
DELTA_TABLE = [0 0.1 0.5];
TOTAL_ITERATIONS = 3;
SAMPLING_RATE = 1000; %Hz

%These variables are used for plotting the performance improvements - delta graph
UTIL_PER_CENT = 50; %the constant utilization for which we are going to plot the graph
FREQ_TABLE = [100]; %the frequencies for which we are going to plot the graph

%Specify the name of the input files
single_core_response_file = 'sc_meas1.xlsx';
max_par_response_file = 'max_par_meas1.xlsx';
performance_response_file = 'performance_meas1.xlsx';
energy_response_file = 'energy_meas1.xlsx';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
									%%%%START%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

UTILIZATION_MEASUREMENTS = (UTIL_MAX - UTIL_MIN)/UTIL_STEP + 1;
DELTA_MEASUREMENTS = size(DELTA_TABLE,2);
FREQUENCY_MEASUREMENTS = (FREQ_MAX - FREQ_MIN)/FREQ_STEP + 1;
TOTAL_ITERATIONS = TOTAL_ITERATIONS + 1;
h_color = {'g'; 'b'; 'r'; 'k'; 'm'; 'c'; 'y'; 'b'};
handle = {'-^' ; '--s'; ':v'; '-.d'; ':x'; '-+'; '--o' ; ':*'};

response_singlecore = single_core_response_measurements(single_core_response_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, SAMPLING_RATE);
response_max_par = max_par_response_measurements(max_par_response_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, DELTA_MEASUREMENTS, FREQUENCY_MEASUREMENTS, SAMPLING_RATE);
response_performance = performance_response_measurements(performance_response_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, DELTA_MEASUREMENTS, FREQUENCY_MEASUREMENTS, SAMPLING_RATE, FREQ_MIN);
response_energy = energy_response_measurements(energy_response_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, DELTA_MEASUREMENTS, FREQUENCY_MEASUREMENTS, SAMPLING_RATE, FREQ_MIN);

for freq=1:FREQUENCY_MEASUREMENTS
	x_name = 'Utilization (%)';
	y_name = 'Performance (%)';
	legend_name = 'Max Parallelism';
	x = [UTIL_MIN:UTIL_STEP:UTIL_MAX];
	
	%Plot max_par
	for util=1:UTILIZATION_MEASUREMENTS
		y(util) = (response_singlecore(util) - response_max_par(freq,1,util)) / response_singlecore(util) * 100;
	end

	title_name = sprintf('F_{LC} = %d', FREQ_MAX - FREQ_STEP*(FREQUENCY_MEASUREMENTS - freq));

	
	figure
	plot(x, y,[h_color{1} handle{1}],'DisplayName',legend_name,'MarkerFaceColor',h_color{1});
	legend(gca, 'show', 'Location', 'Best');
    xlabel(x_name,'FontSize', 20);
    ylabel(y_name,'FontSize', 18);
    set(gca,'FontSize', 16);
	title(title_name);
	grid on	
	
	
	%Plot performance
	for delta=1:DELTA_MEASUREMENTS
		hold on
		legend('-DynamicLegend', 'Location', 'Best');
		for util=1:UTILIZATION_MEASUREMENTS
			y(util) = (response_singlecore(util) - response_performance(freq,delta,util)) / response_singlecore(util) * 100;
		end	
		
		if delta == 1
			legend_name = sprintf('Performance, Delta = 0');
		elseif delta == 2
			legend_name = sprintf('Performance, Delta = 0.1');
		elseif delta == 3
			legend_name = sprintf('Performance, Delta = 0.5');
		end
		
		plot(x, y,[h_color{1+delta} handle{1+delta}],'DisplayName',legend_name, 'MarkerFaceColor', h_color{1+delta});
		legend(gca, 'show', 'Location', 'Best');
		grid on	
	end
	
	%Plot energy
	for delta=1:DELTA_MEASUREMENTS
		hold on
		legend('-DynamicLegend', 'Location', 'Best');
		for util=1:UTILIZATION_MEASUREMENTS
			y(util) = (response_singlecore(util) - response_energy(freq,delta,util)) / response_singlecore(util) * 100;
		end	
		
		if delta == 1
			legend_name = sprintf('Energy, Delta = 0');
		elseif delta == 2
			legend_name = sprintf('Energy, Delta = 0.1');
		elseif delta == 3
			legend_name = sprintf('Energy, Delta = 0.5');
		end

		plot(x, y,[h_color{1 + DELTA_MEASUREMENTS + delta} handle{1 + DELTA_MEASUREMENTS + delta}],'DisplayName',legend_name, 'MarkerFaceColor', h_color{1 + DELTA_MEASUREMENTS + delta});
		legend(gca, 'show', 'Location', 'Best');
		grid on	
	end
end


%
%
%Plots: Performance Improvements - Delta
%
%

util = (UTIL_PER_CENT - UTIL_MIN) / UTIL_STEP + 1;

for k=1:size(FREQ_TABLE)
	freq = FREQ_TABLE(k);
	freq_index = (freq - FREQ_MIN)/FREQ_STEP + 1;
	x_name = 'Delta';
	y_name = 'Makespan (%)';
	legend_name = sprintf('Max Parallelism, F_{LC} = %d', freq);
	x = DELTA_TABLE;
	y = [];
	%axis([10 100 0 100])
	
	%Plot max_par
	for d=1:DELTA_MEASUREMENTS
		y(d) = (response_singlecore(util) - response_max_par(freq_index,d,util)) / response_singlecore(util) * 100;
	end
	title_name = sprintf('Makespan - Delta, Utilization = %.1f', UTIL_PER_CENT / 100);
	
	
	figure
	plot(x, y,[h_color{1} handle{1}],'DisplayName',legend_name,'MarkerFaceColor',h_color{1});
	legend(gca, 'show', 'Location', 'Best');
	xlabel(x_name);
	ylabel(y_name);
	title(title_name);
	grid on	
	
	
	%Plot performance
	hold on
	legend('-DynamicLegend', 'Location', 'Best');
	for d=1:DELTA_MEASUREMENTS
		y(d) = (response_singlecore(util) - response_performance(freq_index,d,util)) / response_singlecore(util) * 100;
	end
	legend_name = sprintf('Performance-centric, F_{LC} = %d', freq);
	plot(x, y,[h_color{1+freq_index} handle{1+freq_index}],'DisplayName',legend_name, 'MarkerFaceColor', h_color{1+freq_index});
	legend(gca, 'show', 'Location', 'Best');
	grid on	

	
	%Plot energy
	hold on
	legend('-DynamicLegend', 'Location', 'Best');
	for d=1:DELTA_MEASUREMENTS
		y(d) = (response_singlecore(util) - response_energy(freq_index,d,util)) / response_singlecore(util) * 100;
	end
	legend_name = sprintf('Energy-efficient, F_{LC} = %d', freq);
	plot(x, y,[h_color{2+freq_index} handle{2+freq_index}],'DisplayName',legend_name, 'MarkerFaceColor', h_color{2+freq_index});
	legend(gca, 'show', 'Location', 'Best');
	grid on	
end


