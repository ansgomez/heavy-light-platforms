            figure
            boxplot_energ = transpose( (energy_single(j) - energy_energ)/ energy_single(1) * 100 );
         
            h1 = boxplot(boxplot_energ,  'colors', 'r', 'whisker', 100 );
            %legend('-DynamicLegend', 'Location', 'Best');
            set(gca,'XTickLabel',[2:20])
            %h = findobj('Tag','Box');
            set(h1,{'linew'},{2})
            set(gca,'XTickLabel',{''})
            set(gca,'Fontsize',22)
            set(gca,'XTickLabel',[2:20])
            xlabel(x_name,'FontSize', 28);
            ylabel(y_name,'FontSize', 28);
            xlim([0 20]);
            ylim([-5 25]);
            
            figure
            hold on
            grid on
            boxplot_energ = transpose( (energy_single(j) - energy_perf)/ energy_single(1) * 100 );
            h2 = boxplot(boxplot_energ,  'colors', 'b', 'whisker', 100);
            set(h2,{'linew'},{2})
            %legend(findobj(gca,'Tag','Box'),'LP+BP')
            set(gca,'XTickLabel',{''})
            set(gca,'Fontsize',22)
            set(gca,'XTickLabel',[2:20])
            xlabel(x_name,'FontSize', 28);
            ylabel(y_name,'FontSize', 28);
            xlim([0 20]);
            ylim([-5 25]);
            
            hLegend = legend(findall(gca,'Tag','Box'), {'Energy-efficient','LP+BP'});
            % Among the children of the legend, find the line elements
            hChildren = findall(get(hLegend,'Children'), 'Type','Line');
            % Set the horizontal lines to the right colors
            set(hChildren(4),'Color','r')
            set(hChildren(2),'Color','b')
            

