%%%Input Variables%%%
clear all
n = 2;
m = 10000; %number of tasksets for each n, rows of matrix mat
occur = zeros(1,101);

h_color = {'g'; 'b'; 'r'; 'k'; 'm'; 'y'; 'b'; 'c'};
handle = {'-^' ; '--s'; ':v'; '-.d'; ':x'; '-+'; '--o' ; ':*'};

%%%START%%%
for i=1:m
    mat = rand([m n]);
    mat = -log(mat);
    mat = round(spdiags(1./sum(mat,2),0,m,m)*mat*100)/100;
end

for i=1:m
    for j=1:n
        occur(round(mat(i,j)/0.01) + 1) = occur(round(mat(i,j)/0.01) + 1) + 1;
    end
end

mean = 0;
for i=1:101
    mean = mean + (i-1)*occur(i);
end

mean = mean/(n*m)

%%%PLOT 2D%%%

x = [0:0.01:1];
y = occur;

figure
plot(x,y);
grid on	

