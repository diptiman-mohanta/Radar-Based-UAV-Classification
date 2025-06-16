function monitor = performance_monitor()
    % PERFORMANCE_MONITOR - Monitor system performance during processing
    
    monitor.start_time = tic;
    monitor.memory_start = memory;
    
    fprintf('Performance monitoring started...\n');
    fprintf('Initial memory usage: %.2f MB\n', monitor.memory_start.MemUsedMATLAB / 1024^2);
end

function report_performance(monitor, stage_name)
    % REPORT_PERFORMANCE - Report current performance metrics
    
    elapsed_time = toc(monitor.start_time);
    current_memory = memory;
    
    fprintf('\n--- %s Performance Report ---\n', stage_name);
    fprintf('Elapsed time: %.2f seconds\n', elapsed_time);
    fprintf('Current memory usage: %.2f MB\n', current_memory.MemUsedMATLAB / 1024^2);
    fprintf('Memory change: %.2f MB\n', ...
            (current_memory.MemUsedMATLAB - monitor.memory_start.MemUsedMATLAB) / 1024^2);
    fprintf('-----------------------------------\n\n');
end
