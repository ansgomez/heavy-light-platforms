function aux = bestfit(f_hc, f_lc, mat)

    hc_threshold = f_hc/(f_hc+f_lc);
    lc_threshold = f_lc/(f_hc+f_lc);
    mean_load = 0.5;
    aux = 0;
    
    for j=1:size(mat,1)
        hc_load = 0;
        lc_load = 0;
        
        for i=1:size(mat,2)
			if hc_load + mat(j,i) <= hc_threshold && lc_load + mat(j,i) <= lc_threshold
				if abs(hc_threshold - hc_load) >= abs(lc_threshold - lc_load)
                   hc_load = hc_load + mat(j,i);
                else
                   lc_load = lc_load + mat(j,i);
                end
            elseif hc_load + mat(j,i) <= hc_threshold && lc_load + mat(j,i) >= lc_threshold
                hc_load = hc_load + mat(j,i);
            elseif lc_load + mat(j,i) <= lc_threshold && hc_load + mat(j,i) >= hc_threshold
                lc_load = lc_load + mat(j,i);
            else
                if hc_threshold - hc_load >= lc_threshold - lc_load
                   hc_load = hc_load + mat(j,i);
                else
                   lc_load = lc_load + mat(j,i);
                end
            end
            
            if hc_load >= hc_threshold
                D = abs((hc_load - mean_load)/mean_load);
                break
            elseif lc_load >= lc_threshold
                D = abs((lc_load - mean_load)/mean_load);
                break
            end
        end  
        aux = aux + D;
    end
    
    aux = aux/size(mat,1);
end
 