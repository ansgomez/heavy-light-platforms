function aux = single_core_response_measurements(file, total_iterations, util_measurements, sampling_rate, period_ms)
	data = xlsread(file);
	V_LED_ON = 1;
	V_START = 0.08;
    V_ACTIVE = 0.06;
    
	for i=1:size(data,1)
		if data(i,1) > V_START
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
	end

	for i=k:size(data,1)
		if active == 1 && data(i,1) < V_ACTIVE
			active = 0;
			stop = i;
		elseif active == 0 && data(i,1) > V_ACTIVE
			execution_time = stop - start;
			active = 1;
			start = i;
			if iteration > 1
				aux(util) = aux(util) + execution_time;
			end
				
			iteration = iteration + 1;
			if iteration > total_iterations
				iteration = 1;
				util = util + 1;
			end
		end
	end

	aux(10) = period_ms;
	for i=1:util_measurements-1
		aux(i) = aux(i) / (total_iterations - 1)*1000/sampling_rate;
	end

end