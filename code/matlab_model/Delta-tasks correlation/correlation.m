%%%Input Variables%%%
clear all
mode = 1; %mode of the heuristics, 0 for simple and 1 for 'decreasing'
n_mat = (2:20); %matrix indicating the number of indepedent tasks, columns of matrix mat
m_mat = round(10000./n_mat.^2); %number of tasksets for each n, rows of matrix mat
f_hc = 100;
f_lc_mat = [50 80 100];
delta = zeros(size(f_lc_mat,2),size(n_mat,2));
delta_opt = zeros(size(f_lc_mat,2),size(n_mat,2));
delta_diff = zeros(size(f_lc_mat,2),size(n_mat,2));
delta_opt_diff = zeros(size(f_lc_mat,2),size(n_mat,2));

h_color = {'g'; 'b'; 'r'; 'c'; 'm'; 'y'; 'b'; 'k'};
handle = {'-^' ; '--s'; ':v'; '-.d'; ':x'; '-+'; '--' ; ':*'};

%%%START%%%
for j = 1:size(f_lc_mat,2)
    f_lc = f_lc_mat(j);
    for i=1:size(n_mat,2)
        j
        n = n_mat(i)
        m = m_mat(i);
        mat = zeros(m,n);
        
        for l=1:m
            mat(l,:) = UUniFast(n, 1);
        end
        %mat = rand([m n]);
        %mat = -log(mat);
        %mat = spdiags(1./sum(mat,2),0,m,m)*mat;
        
        if mode == 1
            mat = sort(mat,2,'descend'); 
        end 
        
        [delta(j,i), delta_diff(j,i)] = mlpt_ext(f_hc, f_lc, mat, 3);
        [delta_opt(j,i), delta_opt_diff(j,i)] = mlpt_ext(f_hc, f_lc, mat, 20);
        
    end
end



%%%PLOT 3D%%%
% x_name = 'number of tasks';
% y_name = 'F_{LC}';
% z_name = '\Delta_{average}';
% x = repmat(n_mat, size(f_lc_mat, 2), 1);
% y = transpose(repmat(f_lc_mat, size(n_mat, 2), 1));
% z = delta;
% 
% figure
% surfc(x, y, z);
% xlabel(x_name,'FontSize', 18);
% ylabel(y_name,'FontSize', 18);
% zlabel(z_name,'FontSize', 18);
% set(gca,'FontSize', 18);
% set(gca,'ZTick',[0:0.2:1]);
% set(gca,'XTick',[2 4:4:n_mat(size(n_mat,2))]);
% set(gca,'YTick',[50:10:100]);
% zlim([0 1]);
% xlim([2 n_mat(size(n_mat,2))]);
% ylim([50 100]);
% grid on	

%hold on 
% delta = [ 0.333 0.25 0.176 0.111 0.0526 0];
% delta = transpose(repmat(delta, size(n_mat, 2), 1));
% surfc(x, y, z);




%%%PLOT 2D delta_avg%%%
x_name = 'number of tasks';
y_name = '\Delta_{avg}';
x = n_mat;

figure
grid on	

for i=1:size(f_lc_mat,2)
    f_lc = f_lc_mat(i);
    y = delta_opt(i,:);
    %legend_name = sprintf('F_{LC} = %d', f_lc);
    h(i) = plot(x, y, [h_color{i} handle{7}], 'Linewidth', 2);
    
    xlabel(x_name,'FontSize', 28);
    ylabel(y_name,'FontSize', 28);
    set(gca,'FontSize', 18);
    set(gca,'XTick',[2:2:n_mat(size(n_mat,2))]);
    %set(gca,'YTick',[0:0.2:1]);
    xlim([2 n_mat(size(n_mat,2))]);
    ylim([0 0.6]);
    %legend(gca, 'show', 'Location', 'Best');
    hold on
    grid on
    %legend('-DynamicLegend', 'Location', 'Best');
end

for i=1:size(f_lc_mat,2)
    f_lc = f_lc_mat(i);
    y = delta(i,:);
    %legend_name = sprintf('F_{LC} = %d', f_lc);
    h(i+size(f_lc_mat,2)) = plot(x, y, [h_color{i} ], 'Linewidth', 2);
    
    xlabel(x_name,'FontSize', 28);
    ylabel(y_name,'FontSize', 28);
    set(gca,'FontSize', 18);
    set(gca,'XTick',[2:2:n_mat(size(n_mat,2))]);
    %set(gca,'YTick',[0:0.2:1]);
    xlim([2 n_mat(size(n_mat,2))]);
    ylim([0 0.6]);
    %legend(gca, 'show', 'Location', 'Best');
    hold on
    grid on
    %legend('-DynamicLegend', 'Location', 'Best');
end

% Plotting 3 legend blocks:

% Block 1
% Axes handle 1 (this is the visible axes)
ah1 = gca;
% Legend at axes 1
legend(ah1,h(1:3),'F_{LC} = 50','F_{LC} = 80', 'F_{LC} = 100',1)

% Block 2
% Axes handle 2 (unvisible, only for place the second legend)
ah2=axes('position',get(gca,'position'), 'FontSize', 18, 'visible','off');
% Legend at axes 2
legend(ah2,h(4:6),'F_{LC} = 50','F_{LC} = 80', 'F_{LC} = 100',2)



%%%PLOT 2D delta_diff%%%
x_name = 'number of tasks';
y_name = '|\Delta - \Delta_{opt}|';
x = n_mat;

figure
grid on	

for i=1:size(f_lc_mat,2)
    f_lc = f_lc_mat(i);
    y = delta_opt_diff(i,:);
    %legend_name = sprintf('F_{LC} = %d', f_lc);
    h(i) = plot(x, y, [h_color{i} handle{7}], 'Linewidth', 2);
    
    xlabel(x_name,'FontSize', 28);
    ylabel(y_name,'FontSize', 30);
    set(gca,'FontSize', 22);
    set(gca,'XTick',[2:2:n_mat(size(n_mat,2))]);
    set(gca,'YTick',[0:0.1:0.5]);
    xlim([2 n_mat(size(n_mat,2))]);
    ylim([0 0.5]);
    %legend(gca, 'show', 'Location', 'Best');
    hold on
    grid on
    %legend('-DynamicLegend', 'Location', 'Best');
end

for i=1:size(f_lc_mat,2)
    f_lc = f_lc_mat(i);
    y = delta_diff(i,:);
    %legend_name = sprintf('F_{LC} = %d', f_lc);
    h(i+size(f_lc_mat,2)) = plot(x, y, [h_color{i} ], 'Linewidth', 2);
    
    xlabel(x_name,'FontSize', 28);
    ylabel(y_name,'FontSize', 30);
    set(gca,'FontSize', 22);
    set(gca,'XTick',[2:2:n_mat(size(n_mat,2))]);
    set(gca,'YTick',[0:0.1:0.5]);
    xlim([2 n_mat(size(n_mat,2))]);
    ylim([0 0.5]);
    %legend(gca, 'show', 'Location', 'Best');
    hold on
    grid on
    %legend('-DynamicLegend', 'Location', 'Best');
end

% Plotting 3 legend blocks:

% Block 1
% Axes handle 1 (this is the visible axes)
ah1 = gca;
% Legend at axes 1
legend1 = legend(ah1,h(1:3),'F_{LC} = 50','F_{LC} = 80', 'F_{LC} = 100',1);
legend1_title = get(legend1,'title');
set(legend1_title,'string','Optimal','FontSize', 22,'fontweight','bold');

% Block 2
% Axes handle 2 (unvisible, only for place the second legend)
ah2=axes('position',get(gca,'position'), 'FontSize', 22, 'visible','off');
% Legend at axes 2
legend2 = legend(ah2,h(4:6),'F_{LC} = 50','F_{LC} = 80', 'F_{LC} = 100',2);
legend2_title = get(legend2,'title');
set(legend2_title,'string','MLPT','FontSize', 22, 'fontweight','bold');

