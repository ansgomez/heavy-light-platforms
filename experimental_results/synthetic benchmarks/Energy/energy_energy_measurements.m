function aux = energy_energy_measurements(file, total_iterations, util_measurements, delta_measurements, frequency_measurements)

	data = xlsread(file);
	V_LED_ON = 1;
	V_ACTIVE = 0.06;
	V_START = 0.1;
	Vdd = 3.3;
	R = 8.2;
	

	for k=1:frequency_measurements
		for j=1:delta_measurements
			for i=1:util_measurements
				aux(k,j,i) = 0;
				total_time(k,j,i) = 0;
			end
		end
	end
		
	for i=1:size(data,1)
		if data(i,1) > V_START
			k = i;
			break
		end
	end
	
	iteration = 1;
	util = 1;
	delta = 1;
	frequency = 1;
	active = 1;
	start = k;
	
	for i=k:size(data,1)
		if active == 1 && data(i,1) < V_ACTIVE
			active = 0;
			if iteration > 1
				aux(frequency, delta, util) = aux(frequency, delta, util) + data(i,1)*1000/R*(Vdd-data(i,1));
				total_time(frequency, delta, util) = total_time(frequency, delta, util) + 1;
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
					util = 1;
					delta = delta + 1; 
					if delta > delta_measurements
						frequency = frequency + 1;
						delta = 1;
						if frequency > frequency_measurements
							break
						end
					end
				end
			end
			if iteration > 1
				aux(frequency, delta, util) = aux(frequency, delta, util) + data(i,1)*1000/R*(Vdd-data(i,1));
				total_time(frequency, delta, util) = total_time(frequency, delta, util) + 1;
			end	
		else
			if iteration > 1
				aux(frequency, delta, util) = aux(frequency, delta, util) + data(i,1)*1000/R*(Vdd-data(i,1));
				total_time(frequency, delta, util) = total_time(frequency, delta, util) + 1;
			end
		end
	end
	
	for k=1:frequency_measurements
		for j=1:delta_measurements
			for i=1:util_measurements
				aux(k,j,i) = aux(k,j,i) / total_time(k,j,i);
			end
		end
	end
end