clear all
global p_act_den p_act p_sleep sys_irc utot

% CONSTANTS
% 1- WC  2-TYP
p_act_den = [0.8 0.56];
n_samples = 15;
sys_f = linspace(0,204,n_samples);
UMAX = 0.70;
utot = 1;
    
%proc data
f = [204 204];
irc = 12;
p_act = p_act_den .* f;
p_sleep = p_act_den .* irc;

%sys data
%sys_f = 204;
sys_irc = 12;

for i=1:n_samples
   [e_aux u_aux] = PowerSavings3D(sys_f(i), UMAX, n_samples);
 
   X(i) = sys_f(i);
   for j=1:length(e_aux)
    Y(j) = u_aux(j);
    data(j,i) = e_aux(j);
   end
   
   [aux_util,aux_savings] = OptimalUtil(sys_f(i));
   opt_util(i) = aux_util(1)/aux_util(2);
   opt_savings(i) = aux_savings;
   
   [aux_util,aux_savings] = AndreaUtil(sys_f(i));
   andrea_util(i) = aux_util(1)/aux_util(2);
   andrea_savings(i) = aux_savings;
end

figure
hold on
%surf(p_act_den(1)*X,Y,data);
mesh(p_act_den(1)*X,Y,data);
%colormap(flipud(gray))
%colormap(gray)
xlabel('System Power(mW)');
ylabel('Util Ratio');
zlabel('Energy Savings(%)');
%xlim([0 204]);
ylim([0 2]);
%plot3(p_act_den(1)*sys_f,opt_util,opt_savings,'g*','LineWidth',2);
plot3(p_act_den(1)*sys_f,andrea_util,andrea_savings,'r+','LineWidth',3);

