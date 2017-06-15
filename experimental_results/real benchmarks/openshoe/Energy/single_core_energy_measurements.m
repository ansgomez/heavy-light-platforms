function aux = single_core_energy_measurements(file, total_iterations, util_measurements)
	data = xlsread(file);
	V_LED_ON = 1;
	V_ACTIVE = 0.05;
	Vdd = 3.3;
	R = 8.2;
	V_START = 0.08;
	I_S_M0 = 0.3;
	
	for i=1:size(data,1)
		if data(i,1)>V_START
			k = i;
			break
		end
	end

	iteration = 1;
	util = 1;
	active = 1;
	start = k;

	for i=1:util_measurements
		aux(i) = 0;
		total_time(i) = 0;
	end

	for i=k:size(data,1)
		if active == 1 && data(i,1) < V_ACTIVE
			active = 0;
			if iteration > 1
				aux(util) = aux(util) + (data(i,1)*1000/R - I_S_M0)*(Vdd-data(i,1));
				total_time(util) = total_time(util) + 1;
			end
		elseif active == 0 && data(i,1) > V_ACTIVE
			stop = i;
			active = 1;
			start = stop;
			
			iteration = iteration + 1;
			if iteration > total_iterations
				iteration = 1;
				util = util + 1;
				if util > util_measurements
					break
				end
			end
			if iteration > 1
				aux(util) = aux(util) + (data(i,1)*1000/R - I_S_M0)*(Vdd-data(i,1));
				total_time(util) = total_time(util) + 1;
			end			
		else
			if iteration > 1
				aux(util) = aux(util) + (data(i,1)*1000/R - I_S_M0)*(Vdd-data(i,1));
				total_time(util) = total_time(util) + 1;
			end
		end
	end

	for i=1:util_measurements
		aux(i) = aux(i) / total_time(i);
	end

end