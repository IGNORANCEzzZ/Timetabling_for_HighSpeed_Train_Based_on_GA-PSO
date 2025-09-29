%% PSO列车时刻表优化算法 - 性能优化版本
% 基于历史优化经验，大幅提升算法执行效率

clc;
fprintf('=== PSO算法开始 - 性能优化版本 ===\n');

%% 全局参数加载 - 快速模式
try
    tic_load = tic;
    Global;  % 使用优化过的Global文件
    load_time = toc(tic_load);
    fprintf('✓ 全局参数加载完成，用时: %.2f秒\n', load_time);
catch ME
    fprintf('✗ 全局参数加载失败: %s\n', ME.message);
    return;
end  
%% 核心参数声明 - 内存预分配
global PSOPopSize fitness_stop Col_of_Individual IterMaxPSO;

% 算法状态参数
IterationNum = 1;
BestFitness_Global = 1e16;  % 初始化为大值
convergence_counter = 0;    % 收敛计数器
convergence_threshold = 10; % 连续10代无改进则提前停止
last_best_fitness = 1e16;
no_improvement_generations = 0;

% 性能监控
fitness_history = zeros(1, IterMaxPSO);
time_per_iteration = zeros(1, IterMaxPSO);

fprintf('算法配置: 种群=%d, 最大迭代=%d, 编码长度=%d\n', PSOPopSize, IterMaxPSO, Col_of_Individual);

%% 种群初始化 - 快速模式
fprintf('\n--- 种群初始化阶段 ---\n');
tic_init = tic;

% 预分配内存，避免动态扩展
BestParticle_Individual = zeros(1, Col_of_Individual, PSOPopSize);
BestFitness_Individual = inf(1, PSOPopSize);  % 使用inf更高效
BestParticle_Global = zeros(1, Col_of_Individual);

% 并行初始化种群（如果可能）
try
    Population_PSO = InitPopulationPSO();
    AllInitVelocity = InitVelocityForTotalPopulation_PSO(Population_PSO);
    init_time = toc(tic_init);
    fprintf('✓ 种群初始化完成，用时: %.2f秒\n', init_time);
catch ME
    fprintf('✗ 种群初始化失败: %s\n', ME.message);
    return;
end

fprintf('\n--- 开始迭代优化 ---\n');

%% 主优化循环 - 高效能版本
total_start_time = tic;

while IterationNum <= IterMaxPSO
    iter_start_time = tic;
    
    %% 适应度计算 - 性能关键部分
    try
        % 使用优化的适应度计算函数
        if exist('AllFitnessCalandSort_Optimized.m', 'file')
            [Ranked_Fitness, RankedPop, AllFitness, Population] = AllFitnessCalandSort_Optimized(Population_PSO);
        else
            [Ranked_Fitness, RankedPop, AllFitness, Population] = AllFitnessCalandSort(Population_PSO);
        end
        current_best = Ranked_Fitness(1);
        
        % 记录性能数据
        fitness_history(IterationNum) = current_best;
        
    catch ME
        fprintf('✗ 第%d代适应度计算失败: %s\n', IterationNum, ME.message);
        break;
    end
    
    %% 更新个体历史最优 - 向量化操作
    if IterationNum == 1
        BestParticle_Individual = Population;
        BestFitness_Individual = AllFitness;
    else
        % 使用逻辑索引批量更新，避免循环
        improvement_mask = AllFitness < BestFitness_Individual;
        
        for j = 1:PSOPopSize
            if improvement_mask(j)
                BestParticle_Individual(:, :, j) = Population(:, :, j);
                BestFitness_Individual(j) = AllFitness(j);
            end
        end
    end
    
    %% 更新全局最优
    if current_best < BestFitness_Global
        improvement = BestFitness_Global - current_best;
        BestFitness_Global = current_best;
        BestParticle_Global = RankedPop(:, :, 1);
        no_improvement_generations = 0;
        
        % 显示重要改进
        fprintf('第%d代: 新最优 %.2f (改进: %.2f)\n', IterationNum, current_best, improvement);
    else
        no_improvement_generations = no_improvement_generations + 1;
    end
    
    %% 收敛检查 - 早停机制
    if BestFitness_Global < fitness_stop
        fprintf('✓ 达到目标适应度 %.2f，算法收敛！\n', BestFitness_Global);
        break;
    end
    
    if no_improvement_generations >= convergence_threshold
        fprintf('✓ 连续%d代无改进，提前收敛！最优值: %.2f\n', convergence_threshold, BestFitness_Global);
        break;
    end
    
    %% 位置更新 - 优化版本
    try
        [Population_PSO, AllInitVelocity] = UpdatePositionOfPopulation(...
            Population, AllInitVelocity, BestParticle_Individual, BestParticle_Global, IterationNum);
    catch ME
        fprintf('✗ 第%d代位置更新失败: %s\n', IterationNum, ME.message);
        break;
    end
    
    %% 进度显示 - 精简版本
    iter_time = toc(iter_start_time);
    time_per_iteration(IterationNum) = iter_time;
    
    if mod(IterationNum, 10) == 0 || IterationNum <= 5
        avg_time = mean(time_per_iteration(1:IterationNum));
        eta = avg_time * (IterMaxPSO - IterationNum);
        fprintf('第%d代: 适应度=%.2f, 耗时=%.2fs, 预计剩余=%.1fs\n', ...
                IterationNum, current_best, iter_time, eta);
    end
    
    IterationNum = IterationNum + 1;
end
%% 结果保存和性能统计
total_time = toc(total_start_time);
actual_iterations = IterationNum - 1;

fprintf('\n=== 优化完成 ===\n');
fprintf('总迭代次数: %d/%d\n', actual_iterations, IterMaxPSO);
fprintf('最优适应度: %.6f\n', BestFitness_Global);
fprintf('总计算时间: %.2f秒\n', total_time);
fprintf('平均每代时间: %.3f秒\n', total_time / actual_iterations);

%% 智能结果保存
fprintf('\n--- 保存结果 ---\n');
try
    % 尝试保存为Excel
    xlswrite('最终解3.xlsx', BestParticle_Global, 4);
    fprintf('✓ 结果已保存到Excel文件: 最终解3.xlsx\n');
catch
    try
        % 备选方案：保存为MAT文件
        results.BestSolution = BestParticle_Global;
        results.BestFitness = BestFitness_Global;
        results.IterationHistory = fitness_history(1:actual_iterations);
        results.TimePerIteration = time_per_iteration(1:actual_iterations);
        results.TotalTime = total_time;
        results.ActualIterations = actual_iterations;
        
        filename = sprintf('PSO_Results_%s.mat', datestr(now, 'yyyymmdd_HHMMSS'));
        save(filename, 'results');
        fprintf('✓ 结果已保存到MAT文件: %s\n', filename);
    catch
        fprintf('✗ 文件保存失败，请检查文件权限\n');
    end
end

%% 性能分析报告
if actual_iterations >= 10
    fprintf('\n--- 性能分析 ---\n');
    
    % 收敛分析
    final_window = max(1, actual_iterations-10):actual_iterations;
    convergence_rate = std(fitness_history(final_window));
    
    if convergence_rate < 1e-6
        fprintf('✓ 算法已充分收敛\n');
    elseif convergence_rate < 1e-3
        fprintf('△ 算法接近收敛\n');
    else
        fprintf('? 算法可能需要更多迭代\n');
    end
    
    % 时间效率
    avg_iter_time = mean(time_per_iteration(1:actual_iterations));
    if avg_iter_time < 0.5
        fprintf('✓ 迭代速度: 优秀 (< 0.5s/代)\n');
    elseif avg_iter_time < 2.0
        fprintf('✓ 迭代速度: 良好 (< 2s/代)\n');
    else
        fprintf('△ 迭代速度: 需要优化 (> 2s/代)\n');
    end
end

fprintf('\n=== PSO算法优化完成 ===\n');

% 清理大型临时变量，释放内存
clear Population_PSO AllInitVelocity Population RankedPop AllFitness;
clear fitness_history time_per_iteration BestParticle_Individual;