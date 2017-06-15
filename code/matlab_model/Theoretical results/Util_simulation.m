clear all;
%%%Input Varibles%%%
Period_ms = 100;
F_HC = 100;
P_A_HC = 22.061;
P_S_HC = 1.977;
P_A_LC = 11.7215;%11.7215 for F_LC = 80, 15.4875 for F_LC = 100
P_S_LC = 0.989;
P_A_SYS = 16.617;
P_S_SYS = 1.977;
DELTA_TABLE_THEORETICAL = [0:0.01:1];

%These variables are used for plotting the performance improvements - delta graph
UTIL_PER_CENT = [10:10:100]; %the utilizations for which we are going to plot the graph
FREQ_TABLE = [80]; %works only for one frequency as it is, needs modification to work for multiple
DELTA_TABLE_THEORETICAL_PLOTS = [0.2 0.5];
UTILIZATION_PER_CENT = 40;
h_color = {'g'; 'b'; 'r'; 'k'; 'm'; 'y'; 'b'; 'c'};
handle = {'-^' ; '-s'; '-v'; '-d'; '-x'; '-+'; '-o' ; ':*'};

%%%%START%%%%
P_D_HC = P_A_HC - P_S_HC;
P_D_LC = P_A_LC - P_S_LC;
P_D_SYS = P_A_SYS - P_S_SYS;
DELTA_MEASUREMENTS = size(DELTA_TABLE_THEORETICAL_PLOTS,2);
UTILIZATION_MEASUREMENTS = size(UTIL_PER_CENT,2);

%%%Single-Core%%%
for k=1:size(UTIL_PER_CENT,2)
    Utilization = UTIL_PER_CENT(k) / 100;
    A_HC = Period_ms * Utilization;
    makespan_single(k) = A_HC;
    energy_single(k) = P_A_HC * A_HC + P_S_HC * (Period_ms - A_HC) + P_A_SYS * A_HC + P_S_SYS * (Period_ms - A_HC);
end


%%%Max Parallelism%%%
for j=1:size(FREQ_TABLE,2)
    F_LC = FREQ_TABLE(j); 
    for k=1:size(UTIL_PER_CENT,2)
        Utilization = UTIL_PER_CENT(k) / 100;
        for i=1:size(DELTA_TABLE_THEORETICAL,2)
            D = DELTA_TABLE_THEORETICAL(i);
            A_HC = (Period_ms * Utilization)*F_HC/(F_HC+F_LC);
            A_LC = (Period_ms * Utilization)*F_HC/(F_HC+F_LC);
            makespan_maxpar(j,k,i) = max(A_HC, A_LC);
            energy_maxpar(j,k,i) = P_A_HC * A_HC + P_S_HC * (Period_ms - A_HC) + P_A_LC * A_LC + P_S_LC * (Period_ms - A_LC) + P_A_SYS * max(A_HC,A_LC) + P_S_SYS * (Period_ms - max(A_HC,A_LC));
        end
    end
end


%%%Performance-oriented%%%
for j=1:size(FREQ_TABLE,2)
    F_LC = FREQ_TABLE(j); 
    for k=1:size(UTIL_PER_CENT,2)
        Utilization = UTIL_PER_CENT(k) / 100;
        for i=1:size(DELTA_TABLE_THEORETICAL,2)
            D = DELTA_TABLE_THEORETICAL(i);
            A_HC = (Period_ms * Utilization)*(1+D)*0.5;
            A_LC = (Period_ms * Utilization)*(1-D)*0.5*F_HC/F_LC;
            makespan_perf(j,k,i) = max(A_HC, A_LC);
            energy_perf(j,k,i) = P_A_HC * A_HC + P_S_HC * (Period_ms - A_HC) + P_A_LC * A_LC + P_S_LC * (Period_ms - A_LC) + P_A_SYS * max(A_HC,A_LC) + P_S_SYS * (Period_ms - max(A_HC,A_LC));
        end
    end
end

%%%Energy-efficient%%%
for j=1:size(FREQ_TABLE,2)
    F_LC = FREQ_TABLE(j);  
    for k=1:size(UTIL_PER_CENT,2)
        Utilization = UTIL_PER_CENT(k) / 100;
        for i=1:size(DELTA_TABLE_THEORETICAL,2)
            D = DELTA_TABLE_THEORETICAL(i);
            if D <=(F_HC-F_LC)/(F_HC+F_LC) || (D >=(F_HC-F_LC)/(F_HC+F_LC) && F_LC <= (P_D_LC*D + P_D_SYS*(1+D)*0.5)/(P_D_HC*D + P_D_SYS*(1+D)*0.5)*F_HC)
                A_HC = (Period_ms * Utilization)*(1+D)*0.5;
                A_LC = (Period_ms * Utilization)*(1-D)*0.5*F_HC/F_LC;
            elseif D >=(F_HC-F_LC)/(F_HC+F_LC) && F_LC >= (P_D_LC*D + P_D_SYS*(1+D)*0.5)/(P_D_HC*D + P_D_SYS*(1+D)*0.5)*F_HC
                A_HC = (Period_ms * Utilization)*(1-D)*0.5;
                A_LC = (Period_ms * Utilization)*(1+D)*0.5*F_HC/F_LC;    
            end
            makespan_energ(j,k,i) = max(A_HC, A_LC);
            energy_energ(j,k,i) = P_A_HC * A_HC + P_S_HC * (Period_ms - A_HC) + P_A_LC * A_LC + P_S_LC * (Period_ms - A_LC) + P_A_SYS * max(A_HC,A_LC) + P_S_SYS * (Period_ms - max(A_HC,A_LC));
        end
    end
end

%%%Plot Makespan%%%
util = UTILIZATION_PER_CENT/10;
for freq_index=1:size(FREQ_TABLE,2)
	x_name = 'Allocation Algorithms';
	y_name = 'Makespan (%)';
	
	%Plot max_par
% 	y(1) = makespan_single(util);
% 	names{1,1} = 'Single Core';
% 	y(2) = makespan_maxpar(freq_index,util,1);
% 	names{1,2} = 'Max Par';

	for delta_index=1:size(DELTA_TABLE_THEORETICAL_PLOTS,2)
        for w=1:size(DELTA_TABLE_THEORETICAL,2)
            if DELTA_TABLE_THEORETICAL(w) == DELTA_TABLE_THEORETICAL_PLOTS(delta_index)j;
                delta = w;
                break;
            end
        end
% 		y(1,delta_index) = makespan_perf(freq_index,util,delta)/makespan_single(util)*100;
% 		names{1,delta_index} = sprintf('   = %.1f', DELTA_TABLE_THEORETICAL(delta));
        y(1,delta_index) = makespan_perf(freq_index,util,delta)/makespan_single(util)*100;
	end
	
	for delta_index=1:size(DELTA_TABLE_THEORETICAL_PLOTS,2)
        for w=1:size(DELTA_TABLE_THEORETICAL,2)
            if DELTA_TABLE_THEORETICAL(w) == DELTA_TABLE_THEORETICAL_PLOTS(delta_index);
                delta = w;
                break;
            end
        end
% 		y(2,delta_index) = makespan_energ(freq_index,util,delta)/makespan_single(util)*100;
% 		names{2,delta_index} = sprintf('   = %.1f',DELTA_TABLE_THEORETICAL(delta));
        y(2,delta_index) = makespan_energ(freq_index,util,delta)/makespan_single(util)*100;
    end
	
    
	figure
	yb = bar(y);
    ylimit = (util+2)*10;
	ylim([0 120]);
	xlabel(x_name,'FontSize', 28);
	ylabel(y_name,'FontSize', 28);
    names{1,1} = 'Perfomance';
    names{1,2} = 'Energy';
	set(gca,'XtickLabel',names,'FontSize', 22);
    max_par = makespan_maxpar(freq_index,util,1)/makespan_single(util)*100;
    text(0.5,107,'Single-Core','FontSize', 21);
    text(0.5,max_par+7,'Max-Par','FontSize', 21);
    hold on
    plot(xlim,[100 100], '--r','Linewidth',6)
    plot(xlim,[max_par max_par], '--g','Linewidth',6)
    l{1} = '\Delta = 0.2';
    l{2} = '\Delta = 0.5';
    legend(yb, l);
    

end



%%%Plot Energy%%%
for freq_index=1:size(FREQ_TABLE,2)
	x_name = 'Single-Core Utilization (%)';
	y_name = 'Energy Savings (%)';
	legend_name = 'Max Parallelism';
	x = UTIL_PER_CENT;
	y=[];
	%Plot max_par
	for util=1:UTILIZATION_MEASUREMENTS
		y(util) = (energy_single(util) - energy_maxpar(freq_index,util,1)) / energy_single(util) * 100;
	end

	
	figure
	plot(x, y,[h_color{1} handle{1}],'DisplayName',legend_name,'MarkerFaceColor',h_color{1}, 'LineWidth', 2);
	legend(gca, 'show', 'Location', 'Best');
    xlabel(x_name,'FontSize', 28);
    ylabel(y_name,'FontSize', 28);
    xlim([10 100]);
    set(gca,'FontSize', 18);
    ylim([-20 30]);

	%title(title_name);
	grid on	
	
	
	%Plot performance-oriented
	for delta_index=1:size(DELTA_TABLE_THEORETICAL_PLOTS,2)
        for w=1:size(DELTA_TABLE_THEORETICAL,2)
            if DELTA_TABLE_THEORETICAL(w) == DELTA_TABLE_THEORETICAL_PLOTS(delta_index)
                delta = w;
                break;
            end
        end
		hold on
		legend('-DynamicLegend', 'Location', 'Best');
		for util=1:UTILIZATION_MEASUREMENTS
			y(util) = (energy_single(util) - energy_perf(freq_index,util,delta)) / energy_single(util) * 100;
        end	
        if DELTA_TABLE_THEORETICAL_PLOTS(delta_index) == 0.2
            legend_name = 'Performance, \Delta = 0.2';
        elseif DELTA_TABLE_THEORETICAL_PLOTS(delta_index) == 0.5
            legend_name = 'Performance, \Delta = 0.5';
        else
            legend_name = sprintf('Performance, Delta = %.1f', DELTA_TABLE_THEORETICAL(delta));
        end
		
		
		plot(x, y,[h_color{1+delta_index} handle{1+delta_index}],'DisplayName',legend_name, 'MarkerFaceColor', h_color{1+delta_index}, 'LineWidth', 2);
		legend(gca, 'show', 'Location', 'Best');
		grid on	
	end
	
	%Plot energy-efficient
	for delta_index=1:size(DELTA_TABLE_THEORETICAL_PLOTS,2)
        for w=1:size(DELTA_TABLE_THEORETICAL,2)
            if DELTA_TABLE_THEORETICAL(w) == DELTA_TABLE_THEORETICAL_PLOTS(delta_index)
                delta = w;
                break;
            end
        end
		hold on
		legend('-DynamicLegend', 'Location', 'Best');
		for util=1:UTILIZATION_MEASUREMENTS
			y(util) = (energy_single(util) - energy_energ(freq_index,util,delta)) / energy_single(util) * 100;
        end	
        
        if DELTA_TABLE_THEORETICAL_PLOTS(delta_index) == 0.2
            legend_name = 'Energy, \Delta = 0.2';
        elseif DELTA_TABLE_THEORETICAL_PLOTS(delta_index) == 0.5
            legend_name = 'Energy, \Delta = 0.5';
        else
            legend_name = sprintf('Energy, Delta = %.1f', DELTA_TABLE_THEORETICAL(delta));
        end
        
		plot(x, y,[h_color{1 + size(DELTA_TABLE_THEORETICAL_PLOTS,2) + delta_index} handle{1 + size(DELTA_TABLE_THEORETICAL_PLOTS,2) + delta_index}],'DisplayName',legend_name, 'MarkerFaceColor', h_color{1 + size(DELTA_TABLE_THEORETICAL_PLOTS,2) + delta_index}, 'LineWidth', 2);
		legend(gca, 'show', 'Location', 'Best');
		grid on	
	end
end