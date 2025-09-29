% 简化测试版本
clc;
fprintf('开始简化测试...\n');

% 测试Global_Fixed文件
try
    Global_Fixed;
    fprintf('Global文件加载成功\n');
    
    % 显示关键参数
    global PSOPopSize IterMaxPSO TrainNum StationNum;
    fprintf('种群大小: %d\n', PSOPopSize);
    fprintf('最大迭代: %d\n', IterMaxPSO);
    fprintf('列车数量: %d\n', TrainNum);
    fprintf('站台数量: %d\n', StationNum);
    
catch ME
    fprintf('Global文件加载失败: %s\n', ME.message);
    return;
end

% 测试种群初始化
try
    fprintf('开始种群初始化...\n');
    [Population_PSO]=InitPopulationPSO();
    fprintf('种群初始化成功，维度: %s\n', mat2str(size(Population_PSO)));
    
catch ME
    fprintf('种群初始化失败: %s\n', ME.message);
    return;
end

% 测试单个个体适应度计算
try
    fprintf('开始单个体适应度计算测试...\n');
    
    global SupplySectionNum TrainNum StationNum Num_StopPlan f_travel f_service f_safety;
    global MaxTotalTravelTimeDown MinTotalTravelTimeDown MaxTotalTravelTimeUp MinTotalTravelTimeUp;
    global ServiceTimeConstrant OperationScheme OptimizationData;
    global MaxTotalSectionTimeEachPlanDown MaxTotalSectionTimeEachPlanUp MaxTotalDwellTimeEachPlan;
    global TotalStopTimes TotalSections P_auxi StartStation EndStation;
    
    % 获取第一个个体
    test_individual = Population_PSO(:,:,1);
    
    tic;
    fitness = FitnessCalc_Optimized(test_individual,SupplySectionNum,TrainNum,StationNum,Num_StopPlan,f_travel,f_service,f_safety,MaxTotalTravelTimeDown,MinTotalTravelTimeDown,MaxTotalTravelTimeUp,MinTotalTravelTimeUp,ServiceTimeConstrant,OperationScheme,OptimizationData,MaxTotalSectionTimeEachPlanDown,MaxTotalSectionTimeEachPlanUp,MaxTotalDwellTimeEachPlan,TotalStopTimes,TotalSections,P_auxi,StartStation,EndStation);
    calc_time = toc;
    
    fprintf('单个体适应度计算成功，适应度: %.2f，耗时: %.4f秒\n', fitness, calc_time);
    
catch ME
    fprintf('适应度计算失败: %s\n', ME.message);
    return;
end

% 测试小规模种群计算
try
    fprintf('开始小规模种群计算测试（前3个个体）...\n');
    
    tic;
    for i = 1:min(3, size(Population_PSO, 3))
        test_individual = Population_PSO(:,:,i);
        fitness = FitnessCalc_Optimized(test_individual,SupplySectionNum,TrainNum,StationNum,Num_StopPlan,f_travel,f_service,f_safety,MaxTotalTravelTimeDown,MinTotalTravelTimeDown,MaxTotalTravelTimeUp,MinTotalTravelTimeUp,ServiceTimeConstrant,OperationScheme,OptimizationData,MaxTotalSectionTimeEachPlanDown,MaxTotalSectionTimeEachPlanUp,MaxTotalDwellTimeEachPlan,TotalStopTimes,TotalSections,P_auxi,StartStation,EndStation);
        fprintf('个体%d适应度: %.2f\n', i, fitness);
    end
    total_time = toc;
    
    fprintf('3个个体计算完成，总耗时: %.4f秒，平均: %.4f秒/个体\n', total_time, total_time/3);
    
    % 估算全种群时间
    estimated_time = (total_time/3) * PSOPopSize;
    fprintf('预估全种群(%d个体)计算时间: %.2f秒\n', PSOPopSize, estimated_time);
    
catch ME
    fprintf('小规模种群计算失败: %s\n', ME.message);
    return;
end

fprintf('\n所有测试完成！系统运行正常。\n');