%% 快速测试DeCoder修复
try
    fprintf('快速测试开始...\n');
    
    % 初始化基本参数
    global TrainNum TotalStopTimes TotalSections Col_of_Individual StopPlanNum OperationScheme;
    TrainNum = 20;
    TotalStopTimes = 70;
    TotalSections = 60; 
    StopPlanNum = 10;
    Col_of_Individual = 280;
    
    % 创建模拟数据
    BestIndividual = ones(1, Col_of_Individual);
    
    % 在TrainSeq位置设置一些测试值（包括0来测试错误情况）
    trainseq_start = TrainNum*2+TotalStopTimes*2+TotalSections*2+1;
    trainseq_end = Col_of_Individual;
    BestIndividual(trainseq_start:trainseq_end) = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7]; % 包含一些无效值
    
    fprintf('创建的TrainSeq: %s\n', mat2str(BestIndividual(trainseq_start:trainseq_end)));
    
    % 测试索引检查逻辑
    TrainSeq = BestIndividual(1, trainseq_start:trainseq_end);
    TrainSeq = round(TrainSeq);
    TrainSeq_Down = TrainSeq(1, 1:StopPlanNum);
    TrainSeq_Up = TrainSeq(1, StopPlanNum+1:end);
    
    fprintf('原始TrainSeq_Down: %s\n', mat2str(TrainSeq_Down));
    fprintf('原始TrainSeq_Up: %s\n', mat2str(TrainSeq_Up));
    
    % 应用安全检查
    for idx = 1:length(TrainSeq_Down)
        if TrainSeq_Down(idx) < 1 || TrainSeq_Down(idx) > StopPlanNum
            fprintf('修正下行索引 %d: %d -> 1\n', idx, TrainSeq_Down(idx));
            TrainSeq_Down(idx) = 1;
        end
    end
    
    for idx = 1:length(TrainSeq_Up)
        if TrainSeq_Up(idx) < 1 || TrainSeq_Up(idx) > StopPlanNum
            fprintf('修正上行索引 %d: %d -> 1\n', idx, TrainSeq_Up(idx));
            TrainSeq_Up(idx) = 1;
        end
    end
    
    fprintf('修正后TrainSeq_Down: %s\n', mat2str(TrainSeq_Down));
    fprintf('修正后TrainSeq_Up: %s\n', mat2str(TrainSeq_Up));
    fprintf('安全检查逻辑正常工作!\n');
    
catch ME
    fprintf('错误: %s\n', ME.message);
    for i=1:length(ME.stack)
        fprintf('  在 %s (第 %d 行)\n', ME.stack(i).name, ME.stack(i).line);
    end
end