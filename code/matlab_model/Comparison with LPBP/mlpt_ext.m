function [deltas, diff] = mlpt_ext(f_hc, f_lc, mat, opt)

    optimality = opt;
    diff = 0;
    deltas = [];
    
    if optimality > size(mat,2)
        optimality = size(mat,2);
    end
    
    hc_threshold = f_hc/(f_hc+f_lc);
    lc_threshold = f_lc/(f_hc+f_lc);
    mean_load = 0.5;
    D_opt = abs((hc_threshold - mean_load)/mean_load);

    mat = sort(mat,2,'descend');

    for j=1:size(mat,1)
        hc_load = 0;
        lc_load = 0;
        
        if size(mat,2) <=2
            D = abs((mat(j,1) - mean_load)/mean_load);
        else   
            num_partitions = 2^optimality-2;
            hc_load_opt = 1;
            sum_of_first_opt = sum(mat(j,1:optimality));
            hc_threshold_opt = f_hc/(f_hc+f_lc)*sum_of_first_opt;
            
            for k=1:num_partitions
                divider = 2^(optimality-1);
                remainder = k;
                hc_load = 0;
                for l=optimality:-1:1
                    if fix(remainder/divider) == 1
                        hc_load = hc_load + mat(j,l);
                        remainder = mod(remainder, divider);
                    end
                    divider = 2^(l-2);
                end
                if abs(hc_load - hc_threshold_opt) < abs(hc_load_opt - hc_threshold_opt)
                    hc_load_opt = hc_load;
                end
            end
                 
            hc_load = hc_load_opt;
            lc_load = sum_of_first_opt - hc_load;
            
            if hc_load >= hc_threshold
                D = abs((hc_load - mean_load)/mean_load);
            elseif lc_load >= lc_threshold
                D = abs((lc_load - mean_load)/mean_load);
            end
            
            if hc_load < hc_threshold && lc_load < lc_threshold
                for i=optimality+1:size(mat,2)
                    if hc_load  <= lc_load*f_hc/f_lc
                        hc_load = hc_load + mat(j,i);
                    else
                        lc_load = lc_load + mat(j,i);
                    end

                    if hc_load >= hc_threshold
                        D = abs((hc_load - mean_load)/mean_load);
                        break
                    elseif lc_load >= lc_threshold
                        D = abs((lc_load - mean_load)/mean_load);
                        break
                    end
                end 
            end
        end
        diff = diff + abs(D-D_opt);
        deltas = [deltas D];

    end
    
    diff = diff/size(mat,1);
end
 