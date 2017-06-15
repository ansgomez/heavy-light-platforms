%Matlab script for performance plots
%The same values as in the project
clear;
FREQ_MIN = 50;
FREQ_MAX = 100;
FREQ_STEP = 10;
UTIL_MIN = 100;
UTIL_MAX = 100;
UTIL_STEP = 10;
DELTA_TABLE = [0];
TOTAL_ITERATIONS = 100;
SAMPLING_RATE = 10000; %Hz
PERIOD_ms = 100;

%Specify the name of the input files
single_core_response_file = 'flow_perf.xlsx';
performance_response_file = 'flow_perf_perf.xlsx';
energy_response_file = 'flow_energ_perf.xlsx';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
									%%%%START%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

UTILIZATION_MEASUREMENTS = (UTIL_MAX - UTIL_MIN)/UTIL_STEP + 1;
DELTA_MEASUREMENTS = size(DELTA_TABLE,2);
FREQUENCY_MEASUREMENTS = (FREQ_MAX - FREQ_MIN)/FREQ_STEP + 1;
TOTAL_ITERATIONS = TOTAL_ITERATIONS + 1;
h_color = {'b'; 'r'; 'r'; 'k'; 'm'; 'c'; 'y'; 'b'};
handle = {'-^' ; '-v'; ':v'; '-.d'; ':x'; '-+'; '--o' ; ':*'};

response_singlecore = single_core_response_measurements(single_core_response_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, SAMPLING_RATE, PERIOD_ms);
response_performance = performance_response_measurements(performance_response_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, DELTA_MEASUREMENTS, FREQUENCY_MEASUREMENTS, SAMPLING_RATE, FREQ_MIN);
response_energy = energy_response_measurements(energy_response_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, DELTA_MEASUREMENTS, FREQUENCY_MEASUREMENTS, SAMPLING_RATE, FREQ_MIN);

util = 1;
delta = 1;

x_name = 'F_{LC} (MHz)';
y_name = 'Makespan Imprv. (%)';
title_name = sprintf('Flow Benchmark - Makespan');
x = [FREQ_MIN:FREQ_STEP:FREQ_MAX];

for freq=1:FREQUENCY_MEASUREMENTS
	y(freq) = (response_singlecore(util) - response_performance(freq,delta,util)) / response_singlecore(util) * 100;
end	
		
legend_name = sprintf('DTM-M');	
figure
plot(x, y,'b-^','DisplayName',legend_name,'MarkerFaceColor','b','LineWidth',2);
legend(gca, 'show', 'Location', 'Best');
xlabel(x_name,'FontSize', 28);
ylabel(y_name,'FontSize', 28);
xlim([50 100]);
ylim([0 50]);
set(gca,'FontSize', 22);
%title(title_name);
grid on	

hold on
legend('-DynamicLegend', 'Location', 'Best');

for freq=1:FREQUENCY_MEASUREMENTS
	y(freq) = (response_singlecore(util) - response_energy(freq,delta,util)) / response_singlecore(util) * 100;
end		

legend_name = sprintf('DTM-E');
plot(x, y,'r-v','DisplayName',legend_name, 'MarkerFaceColor', 'r','LineWidth',2);
legend(gca, 'show', 'Location', 'Best');
grid on	




