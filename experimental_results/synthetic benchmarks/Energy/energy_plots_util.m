%Matlab script for energy plots
%The same values as in the project
clear;
FREQ_MIN = 80;
FREQ_MAX = 100;
FREQ_STEP = 20;
UTIL_MIN = 10;
UTIL_MAX = 100;
UTIL_STEP = 10;
DELTA_TABLE = [0.2 0.5];
TOTAL_ITERATIONS = 10;
SAMPLING_RATE = 10000; %Hz

%Values for Plots
FREQ_TABLE = [80];
DELTA_TABLE_PLOTS = [0.2 0.5];

%Specify the name of the input files
single_core_energy_file = 'single_util_energ.xlsx';
max_par_energy_file = 'Utilization/max_par_util_energ.xlsx';
performance_energy_file = 'Utilization/perf_util_energ.xlsx';
energy_energy_file = 'Utilization/energ_util_energ.xlsx';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
									%%%%START%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

UTILIZATION_MEASUREMENTS = (UTIL_MAX - UTIL_MIN)/UTIL_STEP + 1;
DELTA_MEASUREMENTS = size(DELTA_TABLE,2);
FREQUENCY_MEASUREMENTS = (FREQ_MAX - FREQ_MIN)/FREQ_STEP + 1;
TOTAL_ITERATIONS = TOTAL_ITERATIONS + 1;
h_color = {'g'; 'b'; 'r'; 'k'; 'm'; 'c'; 'y'; 'b'};
handle = {'-^' ; '-*'; '-v'; '--+'; '--x'; '-+'; '-o' ; '-*'};
%handle = {'-^' ; '--s'; ':v'; '-.d'; ':x'; '-+'; '--o' ; ':*'};

energy_singlecore = single_core_energy_measurements(single_core_energy_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS);
energy_max_par = max_par_energy_measurements(max_par_energy_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, DELTA_MEASUREMENTS, FREQUENCY_MEASUREMENTS);
energy_performance = performance_energy_measurements(performance_energy_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, DELTA_MEASUREMENTS, FREQUENCY_MEASUREMENTS);
energy_energy = energy_energy_measurements(energy_energy_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, DELTA_MEASUREMENTS, FREQUENCY_MEASUREMENTS);

for freq_index=1:size(FREQ_TABLE,2)
    freq = (FREQ_TABLE(freq_index) - FREQ_MIN)/FREQ_STEP + 1;
	x_name = 'Single-Core Utilization (%)';
	y_name = 'Energy Savings (%)';
	legend_name = 'Max Par.';
	x = [UTIL_MIN:UTIL_STEP:UTIL_MAX];
	
	%Plot max_par
	for util=1:UTILIZATION_MEASUREMENTS
		y(util) = (energy_singlecore(util) - energy_max_par(freq,1,util)) / energy_singlecore(util) * 100;
	end
	title_name = sprintf('F_{LC} = %d', FREQ_MAX - FREQ_STEP*(FREQUENCY_MEASUREMENTS - freq));

	
	figure
	h(1) = plot(x, y,[h_color{1} handle{1}],'DisplayName',legend_name, 'MarkerFaceColor',h_color{1}, 'Linewidth', 2, 'MarkerSize',10);
	legend(gca, 'show', 'Location', 'Best');
    xlabel(x_name,'FontSize', 28);
    ylabel(y_name,'FontSize', 30);
    xlim([10 100]);
    ylim([-30 30]);
    set(gca,'YTick',[-30:10:30]);
    
    set(gca,'FontSize', 26);
	%title(title_name);
	grid on	
	
	
	%Plot performance
	for delta_index=1:size(DELTA_TABLE_PLOTS,2)
        for w=1:size(DELTA_TABLE,2)
            if DELTA_TABLE(w) == DELTA_TABLE_PLOTS(delta_index)
                delta = w;
                break;
            end
        end
		hold on
		legend('-DynamicLegend', 'Location', 'Best');
		for util=1:UTILIZATION_MEASUREMENTS
			y(util) = (energy_singlecore(util) - energy_performance(freq,delta,util)) / energy_singlecore(util) * 100;
        end	
        
        if DELTA_TABLE(delta) == 0.2
            legend_name = 'DTM-M, \Delta = 0.2';
        elseif DELTA_TABLE(delta) == 0.5
            legend_name = 'DTM-M, \Delta = 0.5';
        else
            legend_name = sprintf('DTM-M, Delta = %.1f', DELTA_TABLE(delta));
        end
		
		
		h(1+delta_index) = plot(x, y,[h_color{1+delta_index} handle{1+delta_index}], 'DisplayName',legend_name, 'MarkerFaceColor', h_color{1+delta_index}, 'Linewidth', 2, 'MarkerSize',10);
		legend(gca, 'show', 'Location', 'Best');
		grid on	
	end
	
	%Plot energy
	for delta_index=1:size(DELTA_TABLE_PLOTS,2)
        for w=1:size(DELTA_TABLE,2)
            if DELTA_TABLE(w) == DELTA_TABLE_PLOTS(delta_index)
                delta = w;
                break;
            end
        end
		hold on
		legend('-DynamicLegend', 'Location', 'Best');
		for util=1:UTILIZATION_MEASUREMENTS
			y(util) = (energy_singlecore(util) - energy_energy(freq,delta,util)) / energy_singlecore(util) * 100;
        end	
        
        if DELTA_TABLE(delta) == 0.2
            legend_name = 'DTM-E, \Delta = 0.2';
        elseif DELTA_TABLE(delta) == 0.5
            legend_name = 'DTM-E, \Delta = 0.5';
        else
            legend_name = sprintf('DTM-E, Delta = %.1f', DELTA_TABLE(delta));
        end
        
		h(1 + size(DELTA_TABLE_PLOTS,2)) = plot(x, y,[h_color{1+delta_index} handle{1 + size(DELTA_TABLE_PLOTS,2) + delta_index}], 'DisplayName',legend_name, 'MarkerFaceColor', h_color{1+delta_index}, 'Linewidth', 2, 'MarkerSize',10);
		legend(gca, 'show', 'Location', 'Best');
		grid on	
    end
    
    legend(gca, 'FontSize', 22);
    
    h_legend=legend('Max Par','DTM-M, \Delta = 0.2','DTM-M, \Delta = 0.5','DTM-E, \Delta = 0.2','DTM-E, \Delta = 0.5');
    set(h_legend,'FontSize',21);
end



