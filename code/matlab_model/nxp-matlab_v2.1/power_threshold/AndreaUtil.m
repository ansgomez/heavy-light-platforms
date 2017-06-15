function [ u savings] = AndreaUtil( sys_f )
    global p_act_den p_act p_sleep sys_irc utot
    
    %system power data
    p_sys_act = p_act_den(1) * sys_f;
    p_sys_sleep = p_act_den(1) * sys_irc;
    
    %determine partition
    if ((p_sys_act-p_sys_sleep) > (p_act(1)-p_sleep(1)) - (p_act(2)-p_sleep(2)))
        u = [0.5 0.5];
    else
        u = [0 1];
    end
    %tot = (1-util(2))*p_act(1) + util(2)*(p_sys_act+p_act(2));
    
    %  ENERGIES
    %single core
    Esc = utot*p_act(1) + (1-utot)*p_sleep(1);
    %dual core
    Edc = u(1)*(p_act(1) + p_sleep(2)) + u(2)*(p_act(2) + p_sleep(1));

    %add system power
    Esc = Esc + utot*p_sys_act + (1-utot)*p_sys_sleep;
    Edc = Edc + max(u(1),u(2))*p_sys_act + (1-max(u(1),u(2)))*p_sys_sleep;

    %savings
    savings = 100*(Esc - Edc)/Esc;
end
