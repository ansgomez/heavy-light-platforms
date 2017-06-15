function ExecDSE(p_prefix, proc_type, f_prefix, proc_freq)
%     publish('run_no_sleep_p','outputDir', sprintf('%s_%s',p_prefix, f_prefix))
%     % save(sprintf('%s_%s_no_sleep',p_prefix, f_prefix));
%     close all
    publish('run_sleep_p','outputDir', sprintf('%s_%s',p_prefix, f_prefix))
%     save(sprintf('%s_%s_no_sleep',p_prefix, f_prefix));
%     close all


    publish('run_sys_half','outputDir', sprintf('%s_%s',p_prefix, f_prefix))
    % save(sprintf('%s_%s_no_sleep',p_prefix, f_prefix));
    close all

    publish('run_sys_tenth','outputDir', sprintf('%s_%s',p_prefix, f_prefix))
    % save(sprintf('%s_%s_no_sleep',p_prefix, f_prefix));
    close all
end