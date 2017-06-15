function aux = energy_response_measurements_delta(file, total_iterations, util_measurements, delta_measurements, frequency_measurements, sampling_rate, f_min)

	data = xlsread(file);
	V_LED_ON = 1;
	V_START = 0.11;
	V_ACTIVE = 0.06;
	
	for k=1:frequency_measurements
		for j=1:delta_measurements
			for i=1:util_measurements
				aux(k,j,i) = 0;
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
		if f_min == 50 && frequency == 1 && util == 10 && delta == 1
			if active == 1 && data(i,2) < V_LED_ON
				active = 0;
			elseif active == 0 && data(i,2) > V_LED_ON 
				execution_time = i - start;
				active = 1;
				start = i;
				if iteration > 1
					aux(frequency, delta, util) = aux(frequency, delta, util) + execution_time;
				end
					
				iteration = iteration + 1;
				if iteration > total_iterations
					iteration = 1;
					util = util + 1;
					if util > util_measurements
						util = 1;
						delta = delta + 1;
						if delta > delta_measurements
							delta = 1;
							frequency = frequency + 1;
							if frequency > frequency_measurements
								break
							end
						end
					end
				end
			end			
		else
			if active == 1 && data(i,1) < V_ACTIVE
				active = 0;
				stop = i;
			elseif active == 0 && data(i,1) > V_ACTIVE 
				execution_time = stop - start;
				active = 1;
				start = i;
				if iteration > 1
					aux(frequency, delta, util) = aux(frequency, delta, util) + execution_time;
				end
					
				iteration = iteration + 1;
				if iteration > total_iterations
					iteration = 1;
					util = util + 1;
					if util > util_measurements
						util = 1;
						delta = delta + 1;
						if delta > delta_measurements
							delta = 1;
							frequency = frequency + 1;
							if frequency > frequency_measurements
								break
							end
						end
					end
				end
			end
		end
	end

	for k=1:frequency_measurements
		for j=1:delta_measurements
			for i=1:util_measurements
				aux(k,j,i) = aux(k,j,i) / (total_iterations - 1)*1000/sampling_rate;
			end
		end
	end

end