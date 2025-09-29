%% PSO算法性能测试脚本
% 测试优化后的PSO.m运行效果

clear all;
clc;

fprintf('=== PSO算法性能测试开始 ===\n');

% 记录开始时间和内存
start_time = tic;
initial_memory = memory;
fprintf('初始内存使用: %.2f MB\n', initial_memory.MemUsedMATLAB / 1024 / 1024);

%% 设置测试参数
% 临时修改迭代次数，避免测试时间过长
original_settings = struct();

try
    % 加载全局参数
    Global;
    
    % 备份原始设置
    global IterMaxPSO PSOPopSize;
    original_settings.IterMaxPSO = IterMaxPSO;
    original_settings.PSOPopSize = PSOPopSize;
    
    % 设置测试参数（较小的规模）
    IterMaxPSO = 20;  % 测试用，只运行20代
    PSOPopSize = 50;  % 测试用，较小种群
    
    fprintf('\n测试参数设置:\n');
    fprintf('种群规模: %d (原始: %d)\n', PSOPopSize, original_settings.PSOPopSize);
    fprintf('最大迭代: %d (原始: %d)\n', IterMaxPSO, original_settings.IterMaxPSO);
    
    %% 运行PSO算法
    fprintf('\n正在运行PSO算法...\n');
    PSO;
    
    % 记录完成时间和内存
    end_time = toc(start_time);
    final_memory = memory;
    
    fprintf('\n=== 性能测试结果 ===\n');
    fprintf('总运行时间: %.2f 秒\n', end_time);
    fprintf('最终内存使用: %.2f MB\n', final_memory.MemUsedMATLAB / 1024 / 1024);
    fprintf('内存增长: %.2f MB\n', (final_memory.MemUsedMATLAB - initial_memory.MemUsedMATLAB) / 1024 / 1024);
    
    %% 性能评估
    fprintf('\n=== 性能评估 ===\n');
    
    % 运行时间评估
    if end_time < 30
        fprintf('✓ 运行速度: 优秀 (< 30秒)\n');
    elseif end_time < 60
        fprintf('✓ 运行速度: 良好 (< 1分钟)\n');
    elseif end_time < 180
        fprintf('△ 运行速度: 一般 (< 3分钟)\n');
    else
        fprintf('✗ 运行速度: 需要进一步优化 (> 3分钟)\n');
    end
    
    % 内存使用评估
    memory_usage = (final_memory.MemUsedMATLAB - initial_memory.MemUsedMATLAB) / 1024 / 1024;
    if memory_usage < 100
        fprintf('✓ 内存使用: 优秀 (< 100MB)\n');
    elseif memory_usage < 300
        fprintf('✓ 内存使用: 良好 (< 300MB)\n');
    elseif memory_usage < 500
        fprintf('△ 内存使用: 一般 (< 500MB)\n');
    else
        fprintf('✗ 内存使用: 偏高 (> 500MB)\n');
    end
    
    % 计算每代平均时间
    avg_time_per_iter = end_time / min(IterMaxPSO, 20);
    fprintf('平均每代时间: %.3f 秒\n', avg_time_per_iter);
    
    if avg_time_per_iter < 0.5
        fprintf('✓ 迭代效率: 极佳 (< 0.5s/代)\n');
    elseif avg_time_per_iter < 1.0
        fprintf('✓ 迭代效率: 优秀 (< 1s/代)\n');
    elseif avg_time_per_iter < 3.0
        fprintf('✓ 迭代效率: 良好 (< 3s/代)\n');
    else
        fprintf('△ 迭代效率: 需要优化 (> 3s/代)\n');
    end
    
    %% 检查结果质量
    global BestFitness_Global;
    if exist('BestFitness_Global', 'var') && ~isempty(BestFitness_Global)
        fprintf('\n=== 优化结果 ===\n');
        fprintf('最优适应度: %.6f\n', BestFitness_Global);
        
        if BestFitness_Global < 1e6
            fprintf('✓ 解的质量: 优秀\n');
        elseif BestFitness_Global < 1e8
            fprintf('✓ 解的质量: 良好\n');
        else
            fprintf('△ 解的质量: 一般\n');
        end
    end
    
    %% 扩展性评估
    fprintf('\n=== 扩展性预测 ===\n');
    
    % 估算满规模运行时间
    full_scale_time = avg_time_per_iter * original_settings.IterMaxPSO * ...
                     (original_settings.PSOPopSize / PSOPopSize);
    
    fprintf('预计满规模运行时间: %.1f 分钟\n', full_scale_time / 60);
    
    if full_scale_time < 1800  % 30分钟
        fprintf('✓ 满规模性能: 可接受 (< 30分钟)\n');
    elseif full_scale_time < 3600  % 1小时
        fprintf('△ 满规模性能: 较慢 (< 1小时)\n');
    else
        fprintf('✗ 满规模性能: 过慢 (> 1小时)\n');
    end
    
    %% 恢复原始设置
    IterMaxPSO = original_settings.IterMaxPSO;
    PSOPopSize = original_settings.PSOPopSize;
    
    fprintf('\n=== 测试完成 - 优化成功 ===\n');
    
catch ME
    fprintf('\n✗ 测试运行出错: %s\n', ME.message);
    fprintf('错误位置: %s (第%d行)\n', ME.stack(1).file, ME.stack(1).line);
    
    % 尝试恢复原始设置
    if ~isempty(fieldnames(original_settings))
        try
            IterMaxPSO = original_settings.IterMaxPSO;
            PSOPopSize = original_settings.PSOPopSize;
        catch
            % 忽略恢复错误
        end
    end
    
    fprintf('=== 测试失败 ===\n');
end

%% 生成优化建议
fprintf('\n=== 优化建议 ===\n');
fprintf('1. 建议种群规模: 100-200 (平衡效果与速度)\n');
fprintf('2. 建议最大迭代: 200-500 (根据收敛情况调整)\n');
fprintf('3. 推荐启用并行计算 (种群 >= 50时)\n');
fprintf('4. 建议使用早停机制 (连续10代无改进)\n');

%% 清理测试环境
clear avg_time_per_iter full_scale_time memory_usage;
clear start_time end_time initial_memory final_memory original_settings;