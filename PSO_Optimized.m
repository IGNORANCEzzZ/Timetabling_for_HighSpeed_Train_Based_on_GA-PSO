clc;
try
    Global_Fixed;  % 使用修复的Global文件
    fprintf('Global variables loaded successfully!\n');
catch ME
    fprintf('Error loading Global variables: %s\n', ME.message);
    return;
end

global PSOPopSize;
global fitness_stop;
global Col_of_Individual;
global IterMaxPSO;

fprintf('开始PSO优化，种群大小：%d，最大迭代次数：%d\n', PSOPopSize, IterMaxPSO);

tic; % 开始计时
total_time = tic;

try
    [Population_PSO]=InitPopulationPSO();
    fprintf('种群初始化完成，耗时：%.2f秒\n', toc);
catch ME
    fprintf('Error initializing population: %s\n', ME.message);
    return;
end

IterationNum=1;
BestParticle_Individual=[];
BestFitness_Individual=zeros(1,PSOPopSize);

BestParticle_Global=zeros(1,Col_of_Individual);
BestFitness_Global=zeros(1,1);
BestFitness_Global(1,1)=1e16;

try
    [AllInitVelocity]=InitVelocityForTotalPopulation_PSO(Population_PSO);
    fprintf('速度初始化完成\n');
catch ME
    fprintf('Error initializing velocity: %s\n', ME.message);
    return;
end

% 记录每次迭代的时间和适应度
iteration_times = [];
best_fitness_history = [];

fprintf('\n开始PSO迭代优化...\n');
while 1
    iter_start = tic;
    
    fprintf('=== 第%d代 ===\n', IterationNum);
    
    try
        [Ranked_Fitness,RankedPop,AllFitness,Population]=AllFitnessCalandSort(Population_PSO);
        iter_time = toc(iter_start);
        iteration_times(end+1) = iter_time;
        
        fprintf('当前代最佳适应度 = %.2f\n', Ranked_Fitness(1,1));
        fprintf('当前代计算耗时：%.2f秒\n', iter_time);
        
    catch ME
        fprintf('Error in fitness calculation: %s\n', ME.message);
        break;
    end
    
    %每个粒子历史最佳更新
    if isempty(BestParticle_Individual)
        BestParticle_Individual=Population;
        BestFitness_Individual=AllFitness;
    else
        for j=1:1:PSOPopSize
            if AllFitness(1,j)<BestFitness_Individual(1,j)
                BestParticle_Individual(:,:,j)=Population(:,:,j);
                BestFitness_Individual(1,j)=AllFitness(1,j);
            end
        end
    end
    
    %群体历史最佳更新
    if Ranked_Fitness(1,1)<BestFitness_Global(1,1)
        improvement = BestFitness_Global(1,1) - Ranked_Fitness(1,1);
        BestFitness_Global(1,1)=Ranked_Fitness(1,1);
        BestParticle_Global=RankedPop(:,:,1);
        fprintf('*** 找到更好的解！改进：%.2f ***\n', improvement);
    end
    
    best_fitness_history(end+1) = BestFitness_Global(1,1);
    
    fprintf('历史最佳适应度：%.2f\n', BestFitness_Global(1,1));
    
    % 估算剩余时间
    if IterationNum > 1
        avg_time = mean(iteration_times);
        remaining_iters = min(IterMaxPSO - IterationNum, floor((fitness_stop - BestFitness_Global(1,1)) / 1000));
        estimated_time = avg_time * remaining_iters;
        fprintf('预估剩余时间：%.1f秒\n', estimated_time);
    end
    
    fprintf('\n');
    
    % 停止条件检查
    if BestFitness_Global(1,1)<fitness_stop
        fprintf('达到目标适应度，停止优化！\n');
        break;
    end
    
    if IterationNum>=IterMaxPSO
        fprintf('达到最大迭代次数，停止优化！\n');
        break;
    end
    
    % 早停条件：如果连续10代没有改进，停止
    if IterationNum > 10
        recent_best = best_fitness_history(end-9:end);
        if std(recent_best) < 1e-6  % 标准差很小，说明没有改进
            fprintf('连续10代无显著改进，提前停止！\n');
            break;
        end
    end
    
    try
        [Population_Moved,AllVelocity_After]=UpdatePositionOfPopulation(Population,AllInitVelocity,BestParticle_Individual,BestParticle_Global,IterationNum);
        Population_PSO=Population_Moved;
        AllInitVelocity=AllVelocity_After;
    catch ME
        fprintf('Error updating population: %s\n', ME.message);
        break;
    end
    
    IterationNum=IterationNum+1;
end

total_elapsed = toc(total_time);
fprintf('\n=== 优化完成 ===\n');
fprintf('总耗时：%.2f秒\n', total_elapsed);
fprintf('总迭代次数：%d\n', IterationNum-1);
fprintf('最终最佳适应度：%.2f\n', BestFitness_Global(1,1));
fprintf('平均每代耗时：%.2f秒\n', mean(iteration_times));

% 保存结果
try
    save('PSO_优化结果.mat', 'BestParticle_Global', 'BestFitness_Global', 'best_fitness_history', 'iteration_times');
    fprintf('结果已保存到 PSO_优化结果.mat\n');
    
    % 也尝试保存到Excel
    xlswrite('最终解3',BestParticle_Global,4);
    fprintf('Results saved to Excel file successfully!\n');
catch
    fprintf('Warning: 无法写入Excel文件，但mat文件已保存\n');
end

% 绘制收敛曲线
try
    figure;
    plot(1:length(best_fitness_history), best_fitness_history, 'b-', 'LineWidth', 2);
    xlabel('迭代次数');
    ylabel('最佳适应度');
    title('PSO算法收敛曲线');
    grid on;
    saveas(gcf, 'PSO收敛曲线.png');
    fprintf('收敛曲线已保存到 PSO收敛曲线.png\n');
catch
    fprintf('无法绘制收敛曲线（可能是无头模式）\n');
end

fprintf('\n优化任务全部完成！\n');