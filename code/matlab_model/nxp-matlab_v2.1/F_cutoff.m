%Cutoff Frequency of the simulation
Freq_HC = 204;
Freq_SYS = 204;
Freq_IRQ = 12; 
Freq_SYS_IRQ = 12;
P_HC_density = 0.8;
P_LC_density = 0.56;
P_Per_density = 0.8;
F_Sim_cutoff = [];

for Delta=0:0.01:1
	aux = (P_LC_density*Freq_IRQ*Delta*Freq_HC - (P_Per_density*Freq_SYS - P_Per_density*Freq_SYS_IRQ)*(1+Delta)*Freq_HC/2) / ((P_Per_density*Freq_SYS_IRQ - P_Per_density*Freq_SYS)*(1+Delta)/2 - (P_HC_density*Freq_HC - P_HC_density*Freq_IRQ - P_LC_density*Freq_HC)*Delta);
	F_Sim_cutoff = [F_Sim_cutoff aux];
end

x_name = 'Delta';
y_name = 'F_{cutoff} (MHz)';
x = [0:0.01:1];
y = F_Sim_cutoff;
title_name = 'F_{cutoff}  -  Delta';
%%%%% PLOT %%%%%%
figure
plot(x,y);
xlabel(x_name);
ylabel(y_name);
title(title_name);
grid on	



%Cutoff Frequency of LPCXpresso54102
Freq_HC = 100;
P_HC_act = 26.4;
P_LC_act = 13.86;
P_Per_act = 12.54;
P_HC_sleep = 4.95;
P_LC_sleep = 3.96;
P_Per_sleep = 10.89;
F_LPC_cutoff = [];

for Delta=0:0.01:1
	aux = ((P_LC_sleep - P_LC_act)*Delta*Freq_HC + (P_Per_sleep - P_Per_act)*(1+Delta)/2*Freq_HC) / ((P_HC_sleep - P_HC_act)*Delta + (P_Per_sleep - P_Per_act)*(1+Delta)/2);
	F_LPC_cutoff = [F_LPC_cutoff aux];
end

x_name = 'Delta';
y_name = 'F_{cutoff} (MHz)';
x = [0:0.01:1];
y = F_LPC_cutoff;
title_name = 'F_{cutoff}  -  Delta';
%%%%% PLOT %%%%%%
figure
plot(x,y);
xlabel(x_name);
ylabel(y_name);
title(title_name);
grid on	



