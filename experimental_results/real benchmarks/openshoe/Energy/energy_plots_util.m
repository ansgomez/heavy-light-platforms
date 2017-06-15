%Matlab script for energy plots
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

%Specify the name of the input files
single_core_energy_file = 'openshoe_energ.xlsx';
performance_energy_file = 'openshoe_perf_energ.xlsx';
energy_energy_file = 'openshoe_energ_energ.xlsx';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
									%%%%START%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

UTILIZATION_MEASUREMENTS = (UTIL_MAX - UTIL_MIN)/UTIL_STEP + 1;
DELTA_MEASUREMENTS = size(DELTA_TABLE,2);
FREQUENCY_MEASUREMENTS = (FREQ_MAX - FREQ_MIN)/FREQ_STEP + 1;
TOTAL_ITERATIONS = TOTAL_ITERATIONS + 1;
h_color = {'g'; 'b'; 'r'; 'k'; 'm'; 'c'; 'y'; 'b'};
handle = {'-^' ; '--s'; ':v'; '-.d'; ':x'; '-+'; '--o' ; ':*'};

energy_singlecore = single_core_energy_measurements(single_core_energy_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS);
energy_performance = performance_energy_measurements(performance_energy_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, DELTA_MEASUREMENTS, FREQUENCY_MEASUREMENTS);
energy_energy = energy_energy_measurements(energy_energy_file, TOTAL_ITERATIONS, UTILIZATION_MEASUREMENTS, DELTA_MEASUREMENTS, FREQUENCY_MEASUREMENTS);

util = 1;
delta = 1;

x_name = 'F_{LC} (MHz)';
y_name = 'Energy savings (%)';
title_name = sprintf('Openshoe Benchmark - Energy Savings');
x = [FREQ_MIN:FREQ_STEP:FREQ_MAX];

for freq=1:FREQUENCY_MEASUREMENTS
	y(freq) = (energy_singlecore(util) - energy_performance(freq,delta,util)) / energy_singlecore(util) * 100;
end	
		
legend_name = sprintf('Performance');	
figure
plot(x, y,'b-^','DisplayName',legend_name,'MarkerFaceColor','b','LineWidth',2);
legend(gca, 'show', 'Location', 'Best');
xlabel(x_name,'FontSize', 28);
ylabel(y_name,'FontSize', 28);
set(gca,'FontSize', 22);
ylim([-5 15]);
xlim([50 100]);
%title(title_name);
grid on	

hold on
legend('-DynamicLegend', 'Location', 'Best');

for freq=1:FREQUENCY_MEASUREMENTS
	y(freq) = (energy_singlecore(util) - energy_energy(freq,delta,util)) / energy_singlecore(util) * 100;
end		

legend_name = sprintf('Energy');
plot(x, y,'r-v','DisplayName',legend_name, 'MarkerFaceColor', 'r','LineWidth',2);
legend(gca, 'show', 'Location', 'Best');
grid on	




