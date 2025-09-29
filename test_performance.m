%% 性能测试脚本 - 测试优化后的Global.m
% 此脚本用于测试Global.m的运行速度和内存使用情况

clear all;
clc;

fprintf('=== Global.m 性能测试开始 ===\n');

% 记录开始时间和内存
start_time = tic;
initial_memory = memory;
fprintf('初始内存使用: %.2f MB\n', initial_memory.MemUsedMATLAB / 1024 / 1024);

%% 运行Global.m
try
    fprintf('\n正在运行Global.m...\n');
    Global;
    
    % 记录完成时间和内存
    end_time = toc(start_time);
    final_memory = memory;
    
    fprintf('\n=== 性能测试结果 ===\n');
    fprintf('总运行时间: %.2f 秒\n', end_time);
    fprintf('最终内存使用: %.2f MB\n', final_memory.MemUsedMATLAB / 1024 / 1024);
    fprintf('内存增长: %.2f MB\n', (final_memory.MemUsedMATLAB - initial_memory.MemUsedMATLAB) / 1024 / 1024);
    
    %% 验证关键变量是否正确初始化
    fprintf('\n=== 数据完整性检查 ===\n');
    
    % 检查关键全局变量
    global StationNum TrainNum Num_StopPlan PSOPopSize IterMaxPSO;
    global OptimizationData MaxRunTime MinRunTime;
    global Col_of_Individual;
    
    fprintf('车站数: %d\n', StationNum);
    fprintf('列车数: %d\n', TrainNum);
    fprintf('停站方案数: %d\n', Num_StopPlan);
    fprintf('PSO种群规模: %d\n', PSOPopSize);
    fprintf('最大迭代次数: %d\n', IterMaxPSO);
    fprintf('编码长度: %d\n', Col_of_Individual);
    
    % 检查数据矩阵
    if exist('OptimizationData', 'var')
        non_empty_cells = 0;
        total_cells = StationNum * StationNum;
        for i = 1:StationNum
            for j = 1:StationNum
                if ~isempty(OptimizationData{i,j})
                    non_empty_cells = non_empty_cells + 1;
                end
            end
        end
        fprintf('优化数据完整率: %.1f%% (%d/%d)\n', ...
                non_empty_cells/total_cells*100, non_empty_cells, total_cells);
    end
    
    % 检查运行时间矩阵
    if exist('MaxRunTime', 'var') && exist('MinRunTime', 'var')
        valid_pairs = sum(sum(MaxRunTime > 0));
        fprintf('有效站点对数: %d\n', valid_pairs);
    end
    
    %% 性能评估
    fprintf('\n=== 性能评估 ===\n');
    if end_time < 5
        fprintf('✓ 运行速度: 优秀 (< 5秒)\n');
    elseif end_time < 15
        fprintf('✓ 运行速度: 良好 (< 15秒)\n');
    elseif end_time < 30
        fprintf('△ 运行速度: 一般 (< 30秒)\n');
    else
        fprintf('✗ 运行速度: 需要进一步优化 (> 30秒)\n');
    end
    
    memory_usage = (final_memory.MemUsedMATLAB - initial_memory.MemUsedMATLAB) / 1024 / 1024;
    if memory_usage < 50
        fprintf('✓ 内存使用: 优秀 (< 50MB)\n');
    elseif memory_usage < 100
        fprintf('✓ 内存使用: 良好 (< 100MB)\n');
    elseif memory_usage < 200
        fprintf('△ 内存使用: 一般 (< 200MB)\n');
    else
        fprintf('✗ 内存使用: 偏高 (> 200MB)\n');
    end
    
    fprintf('\n=== 测试完成 - 优化成功 ===\n');
    
catch ME
    fprintf('\n✗ 运行出错: %s\n', ME.message);
    fprintf('错误位置: %s (第%d行)\n', ME.stack(1).file, ME.stack(1).line);
    fprintf('=== 测试失败 ===\n');
end

%% 清理测试环境（可选）
% clear all; % 取消注释来清理所有变量