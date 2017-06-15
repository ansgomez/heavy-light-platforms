clear all;
%close all;

%%%%%% INITIAL VARIABLES %%%%%
data_points = 20;

f_l = 204;
f_b = 204;

p_i_l_den = 0.14;
p_a_l_den = 0.56;
p_i_b_den = 0.2;
p_a_b_den = 0.8;

%Little core power numbers
p_idle_l = linspace(f_l*p_i_l_den,f_l*p_i_l_den,data_points);     %mW
p_act_l = linspace(f_l*p_a_l_den,f_l*p_a_l_den,data_points);%+p_idle_l; %mW

%Big core power numbers
p_idle_b = linspace(f_b*p_i_b_den,f_b*p_i_b_den,data_points);     %mW
p_act_b = linspace(f_b*p_a_b_den, f_b*p_a_b_den,data_points);%+p_idle_b; %mW

%Execution time numbers
exe_l = linspace(50,(50*f_b/f_l)+20,data_points);          %ms
exe_b = linspace(50,50,data_points);          %ms

%%%%% THRESHOLD CALCULATIONS %%%%%

speedup = exe_l ./ exe_b;

p_tot_l = p_idle_b + p_act_l;
p_tot_b = p_idle_l + p_act_b;
p_ratio = p_tot_l ./ p_tot_b;

e_tot_l = exe_l .* p_tot_l;
e_tot_b = exe_b .* p_tot_b;
e_ratio = e_tot_l ./ e_tot_b;

% figure
% plot(speedup, p_ratio,'b-','LineWidth',2)
% ylabel('Power Ratio');
% xlabel('Speedup');

figure
hold on
min_x = 0.5;%min(min(speedup),0.5);
max_x = 2.5;%max(max(speedup),1.5);
min_y = 0.5;%min(min(e_ratio),0.5);
max_y = 1.5;%max(max(e_ratio),1.2);

%Colored regions
fill([0 max_x max_x 0], [0 0 1 1],'g', 'FaceAlpha', 0.1, 'EdgeColor', 'None')
fill([0 max_x max_x 0], [1 1 max_y max_y],'r', 'FaceAlpha', 0.1, 'EdgeColor', 'None')
plot(speedup, e_ratio,'k-','LineWidth',2);

xlim([min_x max_x]);
ylim([min_y max_y]);
ylabel('Energy Ratio');
xlabel('Speedup');
title_str = sprintf('F_{WC}=%d F_{TYP}=%d',f_b,f_l);
title(title_str);