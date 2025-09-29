function [Ranked_Fitness,RankedPopulation,Allfitness,Pop]=AllFitnessCalandSort_Optimized(Population)
%% 高性能适应度计算和排序函数
% 优化版本：减少重复变量声明，提高计算效率，支持并行计算

%% 获取全局参数 - 一次性读取
global SupplySectionNum TrainNum StationNum Num_StopPlan;
global f_travel f_service f_safety;
global MaxTotalTravelTimeDown MinTotalTravelTimeDown MaxTotalTravelTimeUp MinTotalTravelTimeUp;
global ServiceTimeConstrant OperationScheme OptimizationData;
global MaxTotalSectionTimeEachPlanDown MaxTotalSectionTimeEachPlanUp MaxTotalDwellTimeEachPlan;
global TotalStopTimes TotalSections P_auxi StartStation EndStation;

%% 快速参数复制 - 避免重复访问全局变量
% 按照FitnessCalc_Optimized的参数顺序准备参数
params = {SupplySectionNum, TrainNum, StationNum, Num_StopPlan, f_travel, f_service, f_safety, ...
          MaxTotalTravelTimeDown, MinTotalTravelTimeDown, MaxTotalTravelTimeUp, MinTotalTravelTimeUp, ...
          ServiceTimeConstrant, OperationScheme, OptimizationData, ...
          MaxTotalSectionTimeEachPlanDown, MaxTotalSectionTimeEachPlanUp, MaxTotalDwellTimeEachPlan, ...
          TotalStopTimes, TotalSections, P_auxi, StartStation, EndStation};

%% 高效适应度计算 - 并行化优化
population_size = size(Population, 3);
Allfitness = zeros(1, population_size);

% 检查是否可以使用并行计算
use_parallel = false;
try
    % 尝试检查并行计算工具箱
    if license('test', 'Distrib_Computing_Toolbox') && exist('parpool', 'file')
        current_pool = gcp('nocreate');
        if isempty(current_pool)
            % 只在大种群时启用并行计算
            if population_size >= 50
                try
                    parpool('local', min(4, feature('numcores'))); % 最多4个核
                    use_parallel = true;
                catch
                    % 并行计算启动失败，使用串行
                    use_parallel = false;
                end
            end
        else
            use_parallel = population_size >= 50; % 大种群才使用并行
        end
    end
catch
    use_parallel = false;
end

%% 适应度计算 - 智能并行/串行切换
if use_parallel && population_size >= 50
    % 并行计算模式
    fprintf('使用并行计算模式 (%d个个体)\n', population_size);
    try
        parfor i = 1:population_size
            Allfitness(i) = FitnessCalc_Optimized_Safe(Population(:,:,i), params{:});
        end
    catch ME
        fprintf('并行计算失败，切换到串行模式: %s\n', ME.message);
        % 备选方案：串行计算
        for i = 1:population_size
            Allfitness(i) = FitnessCalc_Optimized_Safe(Population(:,:,i), params{:});
        end
    end
else
    % 串行计算模式（默认）
    for i = 1:population_size
        Allfitness(i) = FitnessCalc_Optimized_Safe(Population(:,:,i), params{:});
    end
end

%% 高效排序 - 向量化操作
[Ranked_Fitness, sort_indices] = sort(Allfitness);
RankedPopulation = Population(:, :, sort_indices);
Pop = Population;

end

%% 安全的适应度计算函数
function fitness = FitnessCalc_Optimized_Safe(Individual, varargin)
    % 简化版的适应度计算，专为高效计算设计
    try
        fitness = FitnessCalc_Optimized(Individual, varargin{:});
    catch ME
        % 如果计算失败，返回大的惩罚值
        fprintf('个体适应度计算失败: %s\n', ME.message);
        fitness = 1e10;
    end
end