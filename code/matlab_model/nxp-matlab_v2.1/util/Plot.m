classdef Plot
    %PLOT Class of utility functions for plotting results
    %   Possible plots include XYRatio, for comparing the same metric under
    %   different conditions, and XY, for comparing different metrics.

        
    properties (Constant)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     CONSTANTS                       %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        h_color = {'g'; 'b'; 'r'; 'k'; 'm'; 'c'; 't'; 'b'};
        %handle = {'x' ; '^'; '.'; '^'; 'x'; '+'; 'v' ; '*'};
        handle = {'-^' ; '--s'; ':v'; '-.d'; ':x'; '-+'; '--o' ; ':*'};
        
        %Scatter plot radius
        Radius = 50;
    end
    
    methods (Static)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     METHODS                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %This function orders the X Y vectors in ascending order
        function [new_x,new_y] = sortXY(x,y)
            if size(x,1)==1
                x = x.';
            end
            if size(y,1) == 1
                y = y.';
            end
            mat = [x y];
            mat = sortrows(mat,1);
            new_x = mat(:,1);
            new_y = mat(:,2);
        end
        
        %This function orders the X Y Z vectors in ascending order
        function [new_x,new_y,new_z] = sortXYZ(x,y,z)
            if size(x,1)==1
                x = x.';
            end
            if size(y,1) == 1
                y = y.';
            end
            if size(z,1) == 1
                z = z.';
            end
            mat = [x y z];
            mat = sortrows(mat,1);
            new_x = mat(:,1);
            new_y = mat(:,2);
            new_z = mat(:,3);
        end
        
        %This function plots the comparison (ratio) between two vectors
        function XYRatio(x, y, labels)
            
            persistent x_name;
            persistent y_name;
            persistent title_name;
            
            x_name = labels{1};
            y_name = labels{2};
            title_name = labels{3};
           
            %%%%% PLOT %%%%%%
            figure
            hold on
            %shaded regions
            min_x = min(min(x));
            max_x = max(max(x));
            min_y = min(min(y));
            max_y = max(max(y));
            min_xy = min(min_x, min_y);
            max_xy = max(max(max(x),max(y)));
            fill([0 max_xy 0], [0 max_xy max_xy],'g', 'FaceAlpha', 0.05, 'EdgeColor', 'None')
            fill([0 max_xy max_xy], [0 0 max_xy],'r', 'FaceAlpha', 0.05, 'EdgeColor', 'None')
            %plot par vs seq
            plot(x, y,'r.','MarkerSize',5);
            xlabel(x_name);
            ylabel(y_name);
            title(title_name);
            xlim([min_xy max_x+1]);
            ylim([min_xy max_y+1]);
        end
        
        %This function plots two vectors, with some default options
        function XY(x, y, labels, index, color)
            if nargin < 5
                color = index;
            end
            x_name = labels{1};
            y_name = labels{2};
            title_name = labels{3};
            %%%%% PLOT %%%%%%
            figure
            
            [x,y]=Plot.sortXY(x,y);
            if(length(labels) > 3)
                legend_name = labels{4};
                plot(x, y,[Plot.h_color{color} Plot.handle{index}],'DisplayName',legend_name,'MarkerFaceColor',Plot.h_color{color});
                legend(gca, 'show', 'Location', 'Best');
            else
                plot(x, y,[Plot.h_color{color} Plot.handle{index}]);
            end
            xlabel(x_name);
            ylabel(y_name);
            title(title_name);
            grid on
        end 
        
        %This function plots two vectors, with some default options
        function addXY(x, y, name, index, color)
            if nargin < 5
                color = index;
            end
            hold on
            legend('-DynamicLegend', 'Location', 'Best');
            [x,y]=Plot.sortXY(x,y);                
            plot(x, y,[Plot.h_color{color} Plot.handle{index}],'DisplayName',name, 'MarkerSize', 8);
            legend(gca, 'show', 'Location', 'Best');
            grid on
        end 
        
        %This function plots two vectors, with some default options
        function scatterXYZ(x, y, z, labels, index, color)
            x_name = labels{1};
            y_name = labels{2};
            title_name = labels{3};
            if(length(labels) > 3)
                colorbar_name = labels{4};
            else
                colorbar_name = '% Deadline Misses';
            end
            
            handle = {'o'};
            
            %%%%% PLOT %%%%%%
            figure
            [x,y,z]=Plot.sortXYZ(x,y,z);
            if(length(labels) > 3)
                legend_name = labels{4};
                scatter(x,y,Plot.Radius,z,'filled','DisplayName',legend_name,'Marker',handle{index});
                legend(gca, 'show', 'Location', 'NorthWest');
                if(length(labels)>4)
                    colorbar_name = labels{5};
                end
            else
                scatter(x,y,Plot.Radius,z,'filled','Marker',{'o'});
            end
            cmap = pmkmp(length(x),'CubicL');
            colormap(cmap);
            xlabel(x_name);
            ylabel(y_name);
            title(title_name);
            cb = colorbar('peer',gca);
            set(get(cb,'ylabel'),'String', colorbar_name)
            grid on
        end 
        
        %This function plots two vectors, with some default options
        function addScatterXYZ(x, y, z, name, index, color)
            hold on
            legend(gca,'off')
            handle = {'o' ; '^'; 's'; '>'; 'x'; '+'; 'v' ; '*'};
            [x,y,z]=Plot.sortXYZ(x,y,z);
            scatter(x,y,Plot.Radius,z,'filled','DisplayName',name,'Marker',handle{index});
            grid on
            legend(gca, 'show', 'Location', 'NorthWest');
        end
        
        %This function transforms any vector according to the plot type
        function newData = transformType(plot_type,data,ref)
            %transform plot data as necessary
            if strcmp(plot_type,'abs') == 1
                newData = data;
                indeces = find(data<10e-10);
                newData(indeces) = 0;
            else
                newData = 100*(ref-data)./ref;
                indeces = find(abs(newData)<1e-9);
                if length(indeces) > 0, newData(indeces) = 0; end
            end
        end
        
        %This function plots histogram of offset between first vector and
        %the rest
        function HIST(vec, labels)
            %handle = {'gx'; 'gx'; 'g^' ; 'g^'; 'r^' ; 'b*'; 'rx'; 'b.'};
            handle = {'r^' ; 'b*'; 'rx'; 'b.'; 'gx'; 'gx'; 'g^' ; 'g^'};
            x_name = labels{1};
            y_name = labels{2};
            legend_name = labels{3};
            
            %xlim([min_xy max_x+1]);
            %ylim([min_xy max_y+1]);
            %title(title_name);
            
            for i=2:length(legend_name)
                figure
                hist(100*(vec{2}(:,1)-vec{2}(:,i))./vec{2}(:,1))
                xlabel(x_name);
                ylabel(y_name);
                aux = sprintf('%s - %s', legend_name{1}, legend_name{i});
                title(aux);
                grid
            end
        end 
        
        %This function plots histogram of offset between first vector and
        %the rest
        function HIST2(vec, labels)
            %handle = {'gx'; 'gx'; 'g^' ; 'g^'; 'r^' ; 'b*'; 'rx'; 'b.'};
            handle = {'r^' ; 'b*'; 'rx'; 'b.'; 'gx'; 'gx'; 'g^' ; 'g^'};
            x_name = labels{1};
            y_name = labels{2};
            legend_name = labels{3};
            %alloc_name = labels{4};
            
            %xlim([min_xy max_x+1]);
            %ylim([min_xy max_y+1]);
            %title(title_name);
            
            for i=2:length(legend_name)
                for k=1:21
                    figure
                    hist(100*(vec{1}{2}(:,2)-vec{2}{2}(:,k))./vec{1}{2}(:,2))
                    xlabel(x_name);
                    ylabel(y_name);
                    aux = sprintf('%s - %s', legend_name{1}, legend_name{i});
                    title(aux);
                end
            end
        end 
    end
end

