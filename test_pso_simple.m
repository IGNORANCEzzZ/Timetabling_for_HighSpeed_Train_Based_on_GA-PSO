%% PSO算法快速测试脚本 - 简化版本
% 修复参数传递问题的测试版本

clear all;
clc;

fprintf('=== PSO算法快速测试 ===\n');

% 记录开始时间
start_time = tic;

try
    % 加载全局参数
    Global;
    
    % 设置测试参数（小规模测试）
    global IterMaxPSO PSOPopSize;
    IterMaxPSO = 5;   % 只运行5代
    PSOPopSize = 10;  % 小种群测试
    
    fprintf('测试配置: 种群=%d, 迭代=%d\n', PSOPopSize, IterMaxPSO);
    
    %% 运行简化的PSO测试
    fprintf('\n正在运行PSO算法...\n');
    
    % 手动调用PSO的主要步骤，避免复杂的并行计算
    global Col_of_Individual fitness_stop;
    
    % 初始化种群
    fprintf('初始化种群...\n');
    Population_PSO = InitPopulationPSO();
    AllInitVelocity = InitVelocityForTotalPopulation_PSO(Population_PSO);
    
    % 运行几代测试
    BestFitness_Global = 1e16;
    BestParticle_Global = zeros(1, Col_of_Individual);
    
    for iter = 1:IterMaxPSO
        fprintf('第%d代: ', iter);
        iter_start = tic;
        
        try
            % 使用原始的适应度计算函数（不用并行版本）
            [Ranked_Fitness, RankedPop, AllFitness, Population] = AllFitnessCalandSort(Population_PSO);
            current_best = Ranked_Fitness(1);
            
            if current_best < BestFitness_Global
                BestFitness_Global = current_best;
                BestParticle_Global = RankedPop(:, :, 1);
                fprintf('新最优 %.2f', current_best);
            else
                fprintf('适应度 %.2f', current_best);
            end
            
            % 简化的位置更新
            if iter < IterMaxPSO
                [Population_PSO, AllInitVelocity] = UpdatePositionOfPopulation(...
                    Population, AllInitVelocity, Population, BestParticle_Global, iter);
            end
            
            iter_time = toc(iter_start);
            fprintf(' (%.2fs)\n', iter_time);
            
        catch ME
            fprintf('失败: %s\n', ME.message);
            break;
        end
    end
    
    total_time = toc(start_time);
    
    fprintf('\n=== 测试结果 ===\n');
    fprintf('总时间: %.2f秒\n', total_time);
    fprintf('最优适应度: %.6f\n', BestFitness_Global);
    
    if BestFitness_Global < 1e15
        fprintf('✓ 算法正常运行\n');
    else
        fprintf('△ 算法运行但适应度较高\n');
    end
    
    % 尝试保存结果
    try
        save('PSO_test_result.mat', 'BestParticle_Global', 'BestFitness_Global');
        fprintf('✓ 结果已保存\n');
    catch
        fprintf('△ 结果保存失败\n');
    end
    
    fprintf('=== 测试完成 ===\n');
    
catch ME
    fprintf('\n✗ 测试失败: %s\n', ME.message);
    if ~isempty(ME.stack)
        fprintf('错误位置: %s (第%d行)\n', ME.stack(1).file, ME.stack(1).line);
    end
end

%% 清理
clear start_time iter_start iter_time total_time iter current_best;
clear Population_PSO AllInitVelocity Population RankedPop AllFitness;