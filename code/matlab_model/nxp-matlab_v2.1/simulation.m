Total_load = 10;
Period = 100;
Delta = 0.1;
Freq_HC = 204;
Freq_SYS = 204;
Freq_IRQ = 12; 
Freq_SYS_IRQ = 12;
Lowest_Freq_LC = 102;
Highest_Freq_LC = 204;
P_HC_density = 0.8;
P_LC_density = 0.56;
P_Per_density = 0.8;

Large_in_HC = [];
Large_in_LC = [];
h_color = {'g'; 'b'; 'r'; 'k'; 'm'; 'c'; 't'; 'b'};
handle = {'-^' ; '--s'; ':v'; '-.d'; ':x'; '-+'; '--o' ; ':*'};

for Freq_LC=Lowest_Freq_LC:1:Highest_Freq_LC 
	Time_HC = Total_load/2*(1+Delta);
	aux = EnergyCalc(Total_load, Period, Freq_HC, Freq_SYS, Freq_LC, Freq_IRQ, Freq_SYS_IRQ, P_HC_density, P_LC_density, P_Per_density, Time_HC);
	Large_in_HC = [Large_in_HC aux];
end

for Freq_LC=Lowest_Freq_LC:1:Highest_Freq_LC 
	Time_HC = Total_load/2*(1-Delta);
	aux = EnergyCalc(Total_load, Period, Freq_HC, Freq_SYS, Freq_LC, Freq_IRQ, Freq_SYS_IRQ, P_HC_density, P_LC_density, P_Per_density, Time_HC);
	Large_in_LC = [Large_in_LC aux];
end

    x_name = 'LC Frequency (MHz)';
    y_name = 'Energy (mJ)';
	legend_name = 'Large Task in HC';
	x = [Lowest_Freq_LC:1:Highest_Freq_LC];
	y = Large_in_HC;
    title_name = sprintf('Delta = %.2f', Delta);
    %%%%% PLOT %%%%%%
    figure
	plot(x, y,h_color{1},'DisplayName',legend_name,'MarkerFaceColor',h_color{1});
    legend(gca, 'show', 'Location', 'Best');
    xlabel(x_name);
    ylabel(y_name);
    title(title_name);
    grid on	
	
	hold on
	legend('-DynamicLegend', 'Location', 'Best');
	y = Large_in_LC;
	legend_name = 'Large Task in LC';
	plot(x, y,h_color{2} ,'DisplayName',legend_name, 'MarkerSize', 8);
    legend(gca, 'show', 'Location', 'Best');
    grid on	

%The Freq_LC after which it is more energy efficient to allocate the large task to the LC
F_LC_Critical = (P_LC_density*Freq_IRQ*Delta*Freq_HC - (P_Per_density*Freq_SYS - P_Per_density*Freq_SYS_IRQ)*(1+Delta)*Freq_HC/2) / ((P_Per_density*Freq_SYS_IRQ - P_Per_density*Freq_SYS)*(1+Delta)/2 - (P_HC_density*Freq_HC - P_HC_density*Freq_IRQ - P_LC_density*Freq_HC)*Delta)
