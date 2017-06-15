function [deltas, diff, hc_loads] = bestfit(f_hc, f_lc, mat)

    diff = 0;
    deltas = [];
    hc_loads = [];
    
    hc_threshold = f_hc/(f_hc+f_lc);
    lc_threshold = f_lc/(f_hc+f_lc);
    mean_load = 0.5;
    D_opt = abs((hc_threshold - mean_load)/mean_load);

    mat = sort(mat,2,'descend');
    
    for j=1:size(mat,1)
        hc_load = 0;
        lc_load = 0;
        hc_budget = hc_threshold;
        lc_budget = lc_threshold;
        
        for i=1:size(mat,2)
            
			if hc_budget >= mat(j,i) && lc_budget >= mat(j,i) %If it fits in both of them choose the one with the lowest budget
				if hc_budget < lc_budget
                   hc_load = hc_load + mat(j,i);
                   hc_budget = hc_budget - mat(j,i);
                else
                   lc_load = lc_load + mat(j,i);
                   lc_budget = lc_budget - mat(j,i);
                end
            elseif hc_budget >= mat(j,i) && lc_budget < mat(j,i)     %if it fits only to HC
                hc_load = hc_load + mat(j,i);
                hc_budget = hc_budget - mat(j,i);
            elseif hc_budget < mat(j,i) && lc_budget >= mat(j,i)    %if it fits only to LC
                lc_load = lc_load + mat(j,i);
                lc_budget = lc_budget - mat(j,i);
            else                                                                        %if it fits nowhere, choose the one 
                if hc_load + mat(j,i) < (lc_load + mat(j,i))*  f_hc/f_lc    %in order to minimize the makespan
                   hc_load = hc_load + mat(j,i);
                   hc_budget = hc_budget - mat(j,i);
                else
                   lc_load = lc_load + mat(j,i);
                   lc_budget = lc_budget - mat(j,i);
                end
            end            
            
% 			if hc_load + mat(j,i) <= hc_threshold && lc_load + mat(j,i) <= lc_threshold
% 				if hc_threshold - hc_load < lc_threshold - lc_load
%                    hc_load = hc_load + mat(j,i);
%                 else
%                    lc_load = lc_load + mat(j,i);
%                 end
%             elseif hc_load + mat(j,i) <= hc_threshold && lc_load + mat(j,i) >= lc_threshold
%                 hc_load = hc_load + mat(j,i);
%             elseif lc_load + mat(j,i) <= lc_threshold && hc_load + mat(j,i) >= hc_threshold
%                 lc_load = lc_load + mat(j,i);
%             else
%                 if hc_threshold - hc_load < lc_threshold - lc_load
%                    hc_load = hc_load + mat(j,i);
%                 else
%                    lc_load = lc_load + mat(j,i);
%                 end
%             end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             if lc_budget <= hc_budget && lc_budget <= mat(j,i)
%                 lc_load = lc_load + mat(j,i);
%                 lc_budget = lc_budget - mat(j,i);
%             elseif hc_budget < lc_budget && hc_budget <= mat(j,i)
%                 hc_load = hc_load + mat(j,i);
%                 hc_budget = hc_budget - mat(j,i);
%             else
%                 lc_load = lc_load + mat(j,i);
%                 lc_budget = lc_budget - mat(j,i);
%             end
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
            if hc_load >= hc_threshold
                D = abs((hc_load - mean_load)/mean_load);
                lc_load = 1 - hc_load;
                break
            elseif lc_load >= lc_threshold
                D = abs((lc_load - mean_load)/mean_load);
                hc_load = 1 - lc_load;
                break
            end
        end  
        diff = diff + abs(D-D_opt);
        deltas = [deltas D];
        hc_loads = [hc_loads hc_load];
    end
    
    diff = diff/size(mat,1);
end
 