%Matlab script for performance plots
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
PERIOD_ms = 100;

%Values for Plots
FREQ_TABLE = [80];
DELTA_TABLE_PLOTS = [0.2 0.5];
UTILIZATION_PER_CENT = 40; %for the makespan, because the makespan improvement is independent of the utilization, so we use bar plots

%Specify the name of the input files
single_core_response_file = 'single_util_perf.xlsx';
max_par_response_file = 'Utilization/max_par_util_perf';
performance_response_file = 'Utilization/perf_util_perf.xlsx';
energy_response_file = 'Utilization/energ_util_perf.xlsx';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
									%%%%START%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

UTILIZATION_MEASUREMENTS = (UTIL_MAX - UTIL_MIN)/UTIL_STEP + 1;
DELTA_MEASUREMENTS = size(DELTA_TABLE,2);
FREQUENCY_MEASUREMENTS = (FREQ_MAX - FREQ_MIN)/FREQ_STEP + 1;
TOTAL_ITERATIONS = TOTAL_ITERATIONS + 1;
h_color = {'g'; 'b'; 'r'; 'k'; 'm'; 'c'; 'y'; 'b'};
handle = {'-^' ; '--s'; ':v'; '-.d'; ':x'; '-+'; '--o' ; ':*'};

response_singlecore = single_core_response_measurements(single_core_response_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, SAMPLING_RATE, PERIOD_ms);
response_max_par = max_par_response_measurements(max_par_response_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, DELTA_MEASUREMENTS, FREQUENCY_MEASUREMENTS, SAMPLING_RATE);
response_performance = performance_response_measurements_delta(performance_response_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, DELTA_MEASUREMENTS, FREQUENCY_MEASUREMENTS, SAMPLING_RATE, FREQ_MIN);
response_energy = energy_response_measurements_delta(energy_response_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, DELTA_MEASUREMENTS, FREQUENCY_MEASUREMENTS, SAMPLING_RATE, FREQ_MIN);

util = UTILIZATION_PER_CENT/10;
for freq_index=1:size(FREQ_TABLE,2)
    freq = (FREQ_TABLE(freq_index) - FREQ_MIN)/FREQ_STEP + 1;
	x_name = 'Allocation Algorithms';
	y_name = 'Makespan (%)';
	title_name = sprintf('F_{LC} = %d', FREQ_MAX - FREQ_STEP*(FREQUENCY_MEASUREMENTS - freq));

	for delta_index=1:size(DELTA_TABLE_PLOTS,2)
        for w=1:size(DELTA_TABLE,2)
            if DELTA_TABLE(w) == DELTA_TABLE_PLOTS(delta_index)
                delta = w;
                break;
            end
        end
		y(1,delta_index) = response_performance(freq,delta,util)/response_singlecore(util)*100;
	end
	
	for delta_index=1:size(DELTA_TABLE_PLOTS,2)
        for w=1:size(DELTA_TABLE,2)
            if DELTA_TABLE(w) == DELTA_TABLE_PLOTS(delta_index)
                delta = w;
                break;
            end
        end
		y(2,delta_index) = response_energy(freq,delta,util)/response_singlecore(util)*100;
	end
	
	figure
	yb = bar(y);
    ylimit = (util+2)*10;
	ylim([0 119]);
	xlabel(x_name,'FontSize', 28);
	ylabel(y_name,'FontSize', 28);
    names{1,1} = 'DTM-M';
    names{1,2} = 'DTM-E';
	set(gca,'XtickLabel',names,'FontSize', 22);
    max_par = response_max_par(freq,1,util)/response_singlecore(util)*100;
    text(0.5,108,'Single-Core','FontSize', 21, 'Color', 'r');
    text(0.5, max_par+10,'Max-Par','FontSize', 21, 'Color', 'g');
    hold on
    plot(xlim,[100 100],'--r','Linewidth',3)
    plot(xlim,[max_par max_par],'--g','Linewidth',3)
    l{1} = '\Delta = 0.2';
    l{2} = '\Delta = 0.5';
    legend(yb, l);

% 	set(yb(1),'FaceColor',h_color{1});
% 	set(yb(2),'FaceColor',h_color{2});
% 	for delta=1:DELTA_MEASUREMENTS
% 		set(yb(2+delta),'FaceColor',h_color{2+delta});
% 	end
% 	for delta=1:DELTA_MEASUREMENTS
% 		set(yb(2+DELTA_MEASUREMENTS+delta),'FaceColor',h_color{2+DELTA_MEASUREMENTS+delta});
% 	end


end
% for freq=1:FREQUENCY_MEASUREMENTS
	% x_name = 'Utilization (%)';
	% y_name = 'Performance (%)';
	% legend_name = 'Max Parallelism';
	% x = [UTIL_MIN:UTIL_STEP:UTIL_MAX];
	
	% %Plot max_par
	% for util=1:UTILIZATION_MEASUREMENTS
		% y(util) = (response_singlecore(util) - response_max_par(freq,1,util)) / response_singlecore(util) * 100;
	% end

	% title_name = sprintf('F_{LC} = %d', FREQ_MAX - FREQ_STEP*(FREQUENCY_MEASUREMENTS - freq));

	
	% figure
	% plot(x, y,[h_color{1} handle{1}],'DisplayName',legend_name,'MarkerFaceColor',h_color{1});
	% legend(gca, 'show', 'Location', 'Best');
	% xlabel(x_name);
	% ylabel(y_name);
	% title(title_name);
	% grid on	
	
	
	% %Plot performance
	% for delta=1:DELTA_MEASUREMENTS
		% hold on
		% legend('-DynamicLegend', 'Location', 'Best');
		% for util=1:UTILIZATION_MEASUREMENTS
			% y(util) = (response_singlecore(util) - response_performance(freq,delta,util)) / response_singlecore(util) * 100;
		% end	
		
		% if delta == 1
			% legend_name = sprintf('Performance, Delta = 0');
		% elseif delta == 2
			% legend_name = sprintf('Performance, Delta = 0.1');
		% elseif delta == 3
			% legend_name = sprintf('Performance, Delta = 0.5');
		% end
		
		% plot(x, y,[h_color{1+delta} handle{1+delta}],'DisplayName',legend_name, 'MarkerFaceColor', h_color{1+delta});
		% legend(gca, 'show', 'Location', 'Best');
		% grid on	
	% end
	
	% %Plot energy
	% for delta=1:DELTA_MEASUREMENTS
		% hold on
		% legend('-DynamicLegend', 'Location', 'Best');
		% for util=1:UTILIZATION_MEASUREMENTS
			% y(util) = (response_singlecore(util) - response_energy(freq,delta,util)) / response_singlecore(util) * 100;
		% end	
		
		% if delta == 1
			% legend_name = sprintf('Energy, Delta = 0');
		% elseif delta == 2
			% legend_name = sprintf('Energy, Delta = 0.1');
		% elseif delta == 3
			% legend_name = sprintf('Energy, Delta = 0.5');
		% end

		% plot(x, y,[h_color{1 + DELTA_MEASUREMENTS + delta} handle{1 + DELTA_MEASUREMENTS + delta}],'DisplayName',legend_name, 'MarkerFaceColor', h_color{1 + DELTA_MEASUREMENTS + delta});
		% legend(gca, 'show', 'Location', 'Best');
		% grid on	
	% end
% end





