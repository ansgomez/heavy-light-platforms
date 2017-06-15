            figure
            boxplot_energ = transpose( (energy_single(j) - energy_energ)/ energy_single(1) * 100 );
         
            h1 = boxplot(boxplot_energ,  'colors', 'r', 'whisker', 100);
            %h = findobj('Tag','Box');
            set(h1,{'linew'},{2})
            set(gca,'Fontsize',22)
            xlabel(x_name,'FontSize', 28);
            ylabel(y_name,'FontSize', 28);
            xlim([0 20]);
            ylim([-5 25]);
            set(gca,'XTickLabel',{''})
            grid on
            
            figure
            boxplot_energ = transpose( (energy_single(j) - energy_perf)/ energy_single(1) * 100 );
            h2 = boxplot(boxplot_energ,  'colors', 'b', 'whisker', 100);
            set(h2,{'linew'},{2})
            %legend(findobj(gca,'Tag','Box'),'LP+BP')
            set(gca,'Fontsize',22)
            xlabel(x_name,'FontSize', 28);
            ylabel(y_name,'FontSize', 28);
            xlim([0 20]);
            ylim([-5 25]);
            set(gca,'XTickLabel',{''})
            grid on

            
