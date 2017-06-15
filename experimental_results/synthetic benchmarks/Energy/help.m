
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
	h(1) = plot(x, y,[h_color{1} handle{1}],'DisplayName',legend_name, 'MarkerFaceColor',h_color{1}, 'Linewidth', 2, 'MarkerSize', 10);
	legend(gca, 'show', 'Location', 'Best');
    xlabel(x_name,'FontSize', 28);
    ylabel(y_name,'FontSize', 28);
    xlim([10 100]);
    ylim([-30 30]);
    set(gca,'YTick',[-30:10:30]);
    set(gca,'FontSize', 24);
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
            legend_name = 'Perf., \Delta = 0.2';
        elseif DELTA_TABLE(delta) == 0.5
            legend_name = 'Perf., \Delta = 0.5';
        else
            legend_name = sprintf('Perf., Delta = %.1f', DELTA_TABLE(delta));
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
            legend_name = 'Energy, \Delta = 0.2';
        elseif DELTA_TABLE(delta) == 0.5
            legend_name = 'Energy, \Delta = 0.5';
        else
            legend_name = sprintf('Energy, Delta = %.1f', DELTA_TABLE(delta));
        end
        
		h(1 + size(DELTA_TABLE_PLOTS,2)) = plot(x, y,[h_color{1 + delta_index} handle{1 + size(DELTA_TABLE_PLOTS,2) + delta_index}], 'DisplayName',legend_name, 'MarkerFaceColor', h_color{1 + delta_index}, 'Linewidth', 2, 'MarkerSize',10);
		legend(gca, 'show', 'Location', 'Best');
		grid on	
    end
    
    legend(gca, 'FontSize', 22);
    
    h_legend=legend('Max Par','Perf., \Delta = 0.2','Perf., \Delta = 0.5','Energy, \Delta = 0.2','Energy, \Delta = 0.5');
    set(h_legend,'FontSize',18);
end