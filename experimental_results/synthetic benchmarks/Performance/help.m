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
    set(gca,'YTick',[0:20:100]);
	xlabel(x_name,'FontSize', 28);
	ylabel(y_name,'FontSize', 28);
    names{1,1} = 'Performance';
    names{1,2} = 'Energy';
	set(gca,'XtickLabel',names,'FontSize', 22);
    max_par = response_max_par(freq,1,util)/response_singlecore(util)*100;
    text(0.5,107,'Single-Core','FontSize', 21, 'Color', 'r');
    text(0.5, max_par+10,'Max-Par','FontSize', 21, 'Color', 'g');
    hold on
    plot(xlim,[100 100],'--r','Linewidth',2)
    plot(xlim,[max_par max_par],'--g','Linewidth',2)
    l{1} = '\Delta = 0.2';
    l{2} = '\Delta = 0.5';
    legend(yb, l);
end