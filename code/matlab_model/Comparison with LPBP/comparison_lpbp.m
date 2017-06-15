%%%Input Variables%%%
clear all
Period_ms = 100;
F_HC = 100;
P_A_HC = 22.061;
P_S_HC = 1.977;
P_A_LC = 11.7215;
P_S_LC = 0.989;
P_A_SYS = 16.617;
P_S_SYS = 1.977;
UTIL_PER_CENT = [100]; %the utilizations for which we are going to plot the graph
f_lc_mat = [80];
f_hc = 100;


uniform = 1; %1 for uniform, 2 for bimodal
%Input variables for umgrn, which creates the distributions
mean1 = 0.95;
mean2 = 0.95;
var1 = 0.1;
var2 = 0.1;

n_mat = (2:16); %matrix indicating the number of indepedent tasks, columns of matrix mat
%m_mat = round(10000./n_mat.^2); %number of tasksets for each n, rows of matrix mat
for i=1:size(n_mat,2)
    m_mat(i) = 10000;
end

delta_diff = zeros(size(f_lc_mat,2),size(n_mat,2));
delta_bfd_diff = zeros(size(f_lc_mat,2),size(n_mat,2));


P_D_HC = P_A_HC - P_S_HC;
P_D_LC = P_A_LC - P_S_LC;
P_D_SYS = P_A_SYS - P_S_SYS;

h_color = {'r'; 'b'; 'r'; 'c'; 'm'; 'y'; 'b'; 'k'};
handle = {'-' ; '-v'; '-.'; '-^'; ':x'; '-+'; '--' ; ':*'};

%%%START%%%
[bimodal_dist, dist_function] = umgrn([ mean1 mean2],[ var1 var2],10000, 'limit', [0 1], 'with_plot', 0);

for j = 1:size(f_lc_mat,2)
    f_lc = f_lc_mat(j);
    
    hc_loads = zeros(size(f_lc_mat,2),size(n_mat,2));
    delta = zeros(size(f_lc_mat,2),size(n_mat,2));
    delta_bfd = zeros(size(f_lc_mat,2),size(n_mat,2));

    for i=1:size(n_mat,2)
        j
        n = n_mat(i)
        m = m_mat(i);
        mat = zeros(m,n);
        
        
    
        for l=1:m
            if uniform == 2
                random_matrix = bimodal_dist(randperm(numel(bimodal_dist),n-1));
                mat(l,:) = UUniFast2(n, UTIL_PER_CENT/100, random_matrix); %bimodal distribution
            elseif uniform == 1
                mat(l,:) = UUniFast(n, UTIL_PER_CENT/100); %uniform distribution
            end
        end
        
     
        [delta, delta_diff(j,i)] = mlpt_ext(f_hc, f_lc, mat, 3);
        %[delta, delta_diff(j,i), bill] = bestfit(f_hc, f_lc, mat);
        %[delta_bfd, delta_bfd_diff(j,i)] = mlpt_ext(f_hc, f_lc, mat, 3);  
        [delta_bfd, delta_bfd_diff(j,i), hc_loads] = bestfit(f_hc, f_lc, mat);   
      

    %%%Energy-efficient%%%
        F_LC = f_lc_mat(j);  
        for k=1:size(UTIL_PER_CENT,2)
            Utilization = UTIL_PER_CENT(k) / 100;
            makespan_energ(i,:) = zeros(1,size(delta,2));
            energy_energ(i,:) = zeros(1,size(delta,2));
            
            for l=1:size(delta,2)
                D = delta(l);            
                if D <=(F_HC-F_LC)/(F_HC+F_LC) || (D >=(F_HC-F_LC)/(F_HC+F_LC) && F_LC <= (P_D_LC*D + P_D_SYS*(1+D)*0.5)/(P_D_HC*D + P_D_SYS*(1+D)*0.5)*F_HC)
                    A_HC = (Period_ms * Utilization)*(1+D)*0.5;
                    A_LC = (Period_ms * Utilization)*(1-D)*0.5*F_HC/F_LC;
                elseif D >=(F_HC-F_LC)/(F_HC+F_LC) && F_LC >= (P_D_LC*D + P_D_SYS*(1+D)*0.5)/(P_D_HC*D + P_D_SYS*(1+D)*0.5)*F_HC
                    A_HC = (Period_ms * Utilization)*(1-D)*0.5;
                    A_LC = (Period_ms * Utilization)*(1+D)*0.5*F_HC/F_LC;    
                end

                makespan_energ(i,l) = max(A_HC, A_LC);
                energy_energ(i,l) = P_A_HC * A_HC + P_S_HC * (Period_ms - A_HC) + P_A_LC * A_LC + P_S_LC * (Period_ms - A_LC) + P_A_SYS * max(A_HC,A_LC) + P_S_SYS * (Period_ms - max(A_HC,A_LC));
                

            end
            mean_energy_energ(j,i) = mean(energy_energ(i,:));
            max_energy_energ(j,i) = min(energy_energ(i,:));
            min_energy_energ(j,i) = max(energy_energ(i,:));
        end
    
    
    %%%Performance-oriented%%%
        F_LC = f_lc_mat(j); 
        for k=1:size(UTIL_PER_CENT,2)
            Utilization = UTIL_PER_CENT(k) / 100;
            makespan_perf(i,:) = zeros(1,size(delta,2));
            energy_perf(i,:) = zeros(1,size(delta,2));
            
            for l=1:size(hc_loads,2)
                
                A_HC = Period_ms * hc_loads(l);
                A_LC = Period_ms * Utilization * (1-hc_loads(l))*F_HC/F_LC;
                makespan_perf(i,l) = max(A_HC, A_LC);
                energy_perf(i,l) = P_A_HC * A_HC + P_S_HC * (Period_ms - A_HC) + P_A_LC * A_LC + P_S_LC * (Period_ms - A_LC) + P_A_SYS * max(A_HC,A_LC) + P_S_SYS * (Period_ms - max(A_HC,A_LC));
            end
            mean_energy_perf(j,i) = mean(energy_perf(i,:));
            max_energy_perf(j,i) = min(energy_perf(i,:));
            min_energy_perf(j,i) = max(energy_perf(i,:));
        end
    
    
    end
    
    %%%Single-Core%%%
    for k=1:size(UTIL_PER_CENT,2)
        Utilization = UTIL_PER_CENT(k) / 100;
        A_HC = Period_ms * Utilization;
        energy_single(k) = P_A_HC * A_HC + P_S_HC * (Period_ms - A_HC) + P_A_SYS * A_HC + P_S_SYS * (Period_ms - A_HC);
    end	
    
end




%%%PLOT 2D delta_diff%%%
% x_name = 'number of tasks';
% y_name = '|\Delta - \Delta_{opt}|_{avg}';
% x = n_mat;
% 
% figure
% grid on	
% 
% for i=1:size(f_lc_mat,2)
%     f_lc = f_lc_mat(i);
%     y = delta_bfd_diff(i,:);
%     %legend_name = sprintf('F_{LC} = %d', f_lc);
%     h(i) = plot(x, y, [h_color{i} handle{7}], 'Linewidth', 2);
%     
%     xlabel(x_name,'FontSize', 28);
%     ylabel(y_name,'FontSize', 30);
%     set(gca,'FontSize', 22);
%     set(gca,'XTick',[2:2:n_mat(size(n_mat,2))]);
%     set(gca,'YTick',[0:0.1:0.5]);
%     xlim([2 n_mat(size(n_mat,2))]);
%     ylim([0 0.5]);
%     %legend(gca, 'show', 'Location', 'Best');
%     hold on
%     grid on
%     %legend('-DynamicLegend', 'Location', 'Best');
% end
% 
% for i=1:size(f_lc_mat,2)
%     f_lc = f_lc_mat(i);
%     y = delta_diff(i,:);
%     %legend_name = sprintf('F_{LC} = %d', f_lc);
%     h(i+size(f_lc_mat,2)) = plot(x, y, [h_color{i} ], 'Linewidth', 2);
%     
%     xlabel(x_name,'FontSize', 28);
%     ylabel(y_name,'FontSize', 30);
%     set(gca,'FontSize', 22);
%     set(gca,'XTick',[2:2:n_mat(size(n_mat,2))]);
%     set(gca,'YTick',[0:0.1:0.5]);
%     xlim([2 n_mat(size(n_mat,2))]);
%     ylim([0 0.5]);
%     %legend(gca, 'show', 'Location', 'Best');
%     hold on
%     grid on
%     %legend('-DynamicLegend', 'Location', 'Best');
% end
% 
% % Plotting 3 legend blocks:
% 
% % Block 1
% % Axes handle 1 (this is the visible axes)
% ah1 = gca;
% % Legend at axes 1
% legend1 = legend(ah1,h(1),'F_{LC} = 80',1);
% legend1_title = get(legend1,'title');
% set(legend1_title,'string','BFD','FontSize', 22,'fontweight','bold');
% 
% % Block 2
% % Axes handle 2 (unvisible, only for place the second legend)
% ah2=axes('position',get(gca,'position'), 'FontSize', 22, 'visible','off');
% % Legend at axes 2
% legend2 = legend(ah2,h(2),'F_{LC} = 80',2);
% legend2_title = get(legend2,'title');
% set(legend2_title,'string','MLPT','FontSize', 22, 'fontweight','bold');



%%Plot Energy Savings%%%
for j=1:size(UTIL_PER_CENT,2)
    x_name = 'number of tasks';
	y_name = 'Energy Savings (%)';
    x = n_mat;
    
	for k=1:size(f_lc_mat,2)
 		freq = f_lc_mat(k);
		freq_index = k;
		y = [];
		
        if k ==1
            figure
            %plot(x, y,[h_color{1} handle{1}],'DisplayName',legend_name,'MarkerFaceColor',h_color{1});
            legend(gca, 'show', 'Location', 'Best');
            xlabel(x_name,'FontSize', 30);
            ylabel(y_name,'FontSize', 28);
            set(gca,'FontSize', 22);
            %set(gca,'YTick',[-10:5:20]);
            set(gca,'XTick',[2:2:n_mat(size(n_mat,2))]);
            xlim([2 n_mat(size(n_mat,2))]);
            %ylim([-10 20]);

            %title(title_name);
            grid on	
        else
            hold on
            legend('-DynamicLegend', 'Location', 'Best');
            %plot(x, y,[h_color{(k-1)*3 + 1} handle{3}],'DisplayName',legend_name, 'MarkerFaceColor', h_color{(k-1)*3 + 1});
            legend(gca, 'show', 'Location', 'Best');
            grid on	
        end
		
        %Plot energy
		hold on
		legend('-DynamicLegend', 'Location', 'Best');
		for d=1:size(n_mat,2)
			y(d) = (energy_single(j) - mean_energy_energ(freq_index,d)) / energy_single(j) * 100;
		end
		legend_name = sprintf('Energy-efficient');
		h(1) = plot(x, y,[h_color{1} handle{1}],'DisplayName',legend_name, 'MarkerFaceColor', h_color{1},'LineWidth',2);
		legend(gca, 'show', 'Location', 'Best');
		grid on	
        
        hold on
		legend('-DynamicLegend', 'Location', 'Best');
		for d=1:size(n_mat,2)
			y(d) = (energy_single(j) - max_energy_energ(freq_index,d)) / energy_single(j) * 100;
		end
		legend_name = sprintf('Max Energy-efficient');
		h(2) = plot(x, y,[h_color{1} handle{2} ],'DisplayName',legend_name, 'MarkerFaceColor', h_color{1},'LineWidth',2);
		legend(gca, 'show', 'Location', 'Best');
		grid on	
        
        hold on
		legend('-DynamicLegend', 'Location', 'Best');
		for d=1:size(n_mat,2)
			y(d) = (energy_single(j) - min_energy_energ(freq_index,d)) / energy_single(j) * 100;
		end
		legend_name = sprintf('Min Energy-efficient');
		h(3) = plot(x, y,[h_color{1} handle{3} ],'DisplayName',legend_name, 'MarkerFaceColor', h_color{1},'LineWidth',2);
		legend(gca, 'show', 'Location', 'Best');
		grid on	
        

		%Plot performance
		hold on
		legend('-DynamicLegend', 'Location', 'Best');
		for d=1:size(n_mat,2)
			y(d) = (energy_single(j) - mean_energy_perf(freq_index,d)) / energy_single(j) * 100;
		end
		legend_name = sprintf('LP+BP');
		h(4) = plot(x, y,[h_color{2} handle{1} ],'DisplayName',legend_name, 'MarkerFaceColor', h_color{2},'LineWidth',2);
		legend(gca, 'show', 'Location', 'Best');
		grid on	

        		%Plot performance
		hold on
		legend('-DynamicLegend', 'Location', 'Best');
		for d=1:size(n_mat,2)
			y(d) = (energy_single(j) - max_energy_perf(freq_index,d)) / energy_single(j) * 100;
		end
		legend_name = sprintf('Max LP+BP');
		h(5) = plot(x, y,[h_color{2} handle{4} ],'DisplayName',legend_name, 'MarkerFaceColor', h_color{2},'LineWidth',2);
		legend(gca, 'show', 'Location', 'Best');
		grid on	
        
        		%Plot performance
		hold on
		legend('-DynamicLegend', 'Location', 'Best');
		for d=1:size(n_mat,2)
			y(d) = (energy_single(j) - min_energy_perf(freq_index,d)) / energy_single(j) * 100;
		end
		legend_name = sprintf('Min LP+BP');
		h(6) = plot(x, y,[h_color{2} handle{3} ],'DisplayName',legend_name, 'MarkerFaceColor', h_color{2},'LineWidth',2);
		legend(gca, 'show', 'Location', 'Best');
		grid on	
        
	end
end


% % Block 1
% % Axes handle 1 (this is the visible axes)
% ah1 = gca;
% % Legend at axes 1
% legend1 = legend(ah1,h(1:3),'Average', 'Max', 'Min', 1);
% legend1_title = get(legend1,'title');
% set(legend1_title,'string','Energy-efficient','FontSize', 22,'fontweight','bold');
% 
% % Block 2
% % Axes handle 2 (unvisible, only for place the second legend)
% ah2=axes('position',get(gca,'position'), 'FontSize', 22, 'visible','off');
% % Legend at axes 2
% legend2 = legend(ah2,h(4:6),'Average', 'Max', 'Min',2);
% legend2_title = get(legend2,'title');
% set(legend2_title,'string','LP+BP','FontSize', 22, 'fontweight','bold');

