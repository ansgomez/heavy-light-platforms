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
DELTA_TABLE = [0:0.01:1];

%These variables are used for plotting the performance improvements - delta graph
UTIL_PER_CENT = [50]; %the utilizations for which we are going to plot the graph
FREQ_TABLE = [80]; %works only for one frequency as it is, needs modification to work for multiple
h_color = {'g'; 'b'; 'r'; 'k'; 'm'; 'y'; 'b'; 'c'};
handle = {'-^' ; '--s'; ':v'; '-.d'; ':x'; '-+'; '--o' ; ':*'};


%%%%START%%%%

P_D_HC = P_A_HC - P_S_HC;
P_D_LC = P_A_LC - P_S_LC;
P_D_SYS = P_A_SYS - P_S_SYS;
DELTA_MEASUREMENTS = size(DELTA_TABLE,2);

%%%Single-Core%%%
for k=1:size(UTIL_PER_CENT,2)
    Utilization = UTIL_PER_CENT(k) / 100;
    A_HC = Period_ms * Utilization;
    makespan_single(k) = A_HC;
    energy_single(k) = P_A_HC * A_HC + P_S_HC * (Period_ms - A_HC) + P_A_SYS * A_HC + P_S_SYS * (Period_ms - A_HC);
end

%%%Performance-oriented%%%
for j=1:size(FREQ_TABLE,2)
    F_LC = FREQ_TABLE(j); 
    for k=1:size(UTIL_PER_CENT,2)
        Utilization = UTIL_PER_CENT(k) / 100;
        for i=1:size(DELTA_TABLE,2)
            D = DELTA_TABLE(i);
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
        for i=1:size(DELTA_TABLE,2)
            D = DELTA_TABLE(i);            
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
for j=1:size(UTIL_PER_CENT,2)
	x_name = '\Delta';
	y_name = 'Makespan Imprv. (%)';
	x = DELTA_TABLE;
    
	for k=1:size(FREQ_TABLE,2)
 		freq = FREQ_TABLE(k);
		freq_index = k;
		y = [];
		
        if k ==1
            figure
            %plot(x, y,[h_color{1} handle{1}],'DisplayName',legend_name,'MarkerFaceColor',h_color{1});
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
			y(d) = (makespan_single(j) - makespan_perf(freq_index,j,d)) / makespan_single(j) * 100;
		end
		legend_name = sprintf('DTM-M');
		plot(x, y,[h_color{(k -1)*3 + 2} ],'DisplayName',legend_name, 'MarkerFaceColor', h_color{(k -1)*3 + 2},'LineWidth',2);
		legend(gca, 'show', 'Location', 'Best');
		grid on	

		
		%Plot energy
		hold on
		legend('-DynamicLegend', 'Location', 'Best');
		for d=1:DELTA_MEASUREMENTS
			y(d) = (makespan_single(j) - makespan_energ(freq_index,j,d)) / makespan_single(j) * 100;
		end
		legend_name = sprintf('DTM-E');
		plot(x, y,[h_color{(k-1)*3 + 3} ],'DisplayName',legend_name, 'MarkerFaceColor', h_color{(k-1)*3 + 3},'LineWidth',2);
		legend(gca, 'show', 'Location', 'Best');
		grid on	
	end
end


%%%Plot Energy%%%
for j=1:size(UTIL_PER_CENT,2)
	x_name = '\Delta';
	y_name = 'Energy Savings (%)';
	x = DELTA_TABLE;
    
	for k=1:size(FREQ_TABLE,2)
 		freq = FREQ_TABLE(k);
		freq_index = k;
		y = [];
		
        if k ==1
            figure
            %plot(x, y,[h_color{1} handle{1}],'DisplayName',legend_name,'MarkerFaceColor',h_color{1});
            legend(gca, 'show', 'Location', 'Best');
            xlabel(x_name,'FontSize', 30);
            ylabel(y_name,'FontSize', 28);
            set(gca,'FontSize', 22);
            set(gca,'YTick',[-10:5:20]);
            set(gca,'XTick',[0:0.2:1]);
            ylim([-10 20]);

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
			y(d) = (energy_single(j) - energy_perf(freq_index,j,d)) / energy_single(j) * 100;
		end
		legend_name = sprintf('DTM-M');
		plot(x, y,[h_color{(k -1)*3 + 2} ],'DisplayName',legend_name, 'MarkerFaceColor', h_color{(k -1)*3 + 2},'LineWidth',2);
		legend(gca, 'show', 'Location', 'Best');
		grid on	

		
		%Plot energy
		hold on
		legend('-DynamicLegend', 'Location', 'Best');
		for d=1:DELTA_MEASUREMENTS
			y(d) = (energy_single(j) - energy_energ(freq_index,j,d)) / energy_single(j) * 100;
		end
		legend_name = sprintf('DTM-E');
		plot(x, y,[h_color{(k-1)*3 + 3} ],'DisplayName',legend_name, 'MarkerFaceColor', h_color{(k-1)*3 + 3},'LineWidth',2);
		legend(gca, 'show', 'Location', 'Best');
		grid on	
	end
end
