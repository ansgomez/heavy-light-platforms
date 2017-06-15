function aux = EnergyCalc(Total_load, Period, Freq_HC, Freq_SYS, Freq_LC, Freq_IRQ, Freq_SYS_IRQ, P_HC_density, P_LC_density, P_Per_density, Time_HC)
	Time_LC = (Total_load - Time_HC) * Freq_HC / Freq_LC;
	Total_ms = max(Time_HC, Time_LC);

	P_HC_act = P_HC_density * Freq_HC;
	P_LC_act = P_LC_density * Freq_LC;
	P_HC_sleep = P_HC_density * Freq_IRQ;
	P_LC_sleep = P_LC_density * Freq_IRQ;
	P_Per_act = P_Per_density*Freq_SYS;
	P_Per_sleep = P_Per_density*Freq_SYS_IRQ;

	Energy_HC = P_HC_act*Time_HC + P_HC_sleep*(Period - Time_HC);
	Energy_LC = P_LC_act*Time_LC + P_LC_sleep*(Period - Time_LC);
	Energy_Per = Total_ms*P_Per_act + P_Per_sleep*(Period - Total_ms);
	Energy = Energy_HC + Energy_LC + Energy_Per;
	aux = Energy;
end