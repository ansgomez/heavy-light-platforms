function aux = mlpt(f_hc, f_lc, mat)

    hc_threshold = f_hc/(f_hc+f_lc);
    lc_threshold = f_lc/(f_hc+f_lc);
    mean_load = 0.5;
    aux = 0;
    mat = sort(mat,2,'descend');

    for j=1:size(mat,1)
        hc_load = 0;
        lc_load = 0;
        
        if size(mat,2) <=2
            D = abs((mat(j,1) - mean_load)/mean_load);
        else   
            hc_load_possib = zeros(1,6);
            hc_load_possib(1) = mat(j,1);
            hc_load_possib(2) = mat(j,2);
            hc_load_possib(3) = mat(j,3);
            hc_load_possib(4) = mat(j,1) + mat(j,2);
            hc_load_possib(5) = mat(j,1) + mat(j,3);
            hc_load_possib(6) = mat(j,2) + mat(j,3);
            %hc_load_possib
            sum_of_first_3 = mat(j,1) + mat(j,2) + mat(j,3);
            hc_threshold_opt = f_hc/(f_hc+f_lc)*sum_of_first_3;
            hc_load_possib_diff = abs(hc_load_possib - hc_threshold_opt);
            [M, index] = min(hc_load_possib_diff);
            hc_load = hc_load_possib(index);
            lc_load = sum_of_first_3 - hc_load;
            
            if hc_load >= hc_threshold
                D = abs((hc_load - mean_load)/mean_load);
            elseif lc_load >= lc_threshold
                D = abs((lc_load - mean_load)/mean_load);
            end
            
            if hc_load < hc_threshold && lc_load < lc_threshold
                for i=4:size(mat,2)
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
        aux = aux + D
    end
    
    aux = aux/size(mat,1);
end
 