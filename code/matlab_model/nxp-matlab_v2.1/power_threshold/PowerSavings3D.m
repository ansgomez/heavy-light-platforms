function [Esavings,Uratio] = PowerSavings3D(sys_f, UMAX, n_samples)
    global p_act_den p_act p_sleep sys_irc utot
    
    %system power data
    p_sys_act = p_act_den(1) * sys_f;
    p_sys_sleep = p_act_den(1) * sys_irc;

    %generate utilization partitions
    %n_samples = 20;
    u1 = linspace(0,UMAX,n_samples);
    u2 = utot-u1;
    
    %  ENERGIES
    %single core
    Esc = utot*p_act(1) + (1-utot)*p_sleep(1);
    %dual core
    Edc = u1*(p_act(1) + p_sleep(2)) + u2*(p_act(2) + p_sleep(1));

    %add system power
    Esc = Esc + utot*p_sys_act + (1-utot)*p_sys_sleep;
    Edc = Edc + max(u1,u2)*p_sys_act + (1-max(u1,u2))*p_sys_sleep;

    %savings
    Esavings = 100*(Esc - Edc)/Esc;
    Uratio = u1./u2;
end