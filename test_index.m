%% 测试索引问题
try
    fprintf('开始测试索引问题...\n');
    
    % 初始化
    Global_Fixed;
    
    % 读取数据
    BestIndividual = xlsread('电费最低最终解GA+PSO_手动修改上下行',1);
    
    % 获取全局变量
    global TrainNum TotalStopTimes TotalSections Col_of_Individual StopPlanNum;
    
    fprintf('TrainNum: %d\n', TrainNum);
    fprintf('TotalStopTimes: %d\n', TotalStopTimes);
    fprintf('TotalSections: %d\n', TotalSections);
    fprintf('Col_of_Individual: %d\n', Col_of_Individual);
    fprintf('StopPlanNum: %d\n', StopPlanNum);
    
    % 计算TrainSeq的索引范围
    start_idx = TrainNum*2+TotalStopTimes*2+TotalSections*2+1;
    end_idx = Col_of_Individual;
    
    fprintf('TrainSeq索引范围: %d到%d\n', start_idx, end_idx);
    fprintf('BestIndividual长度: %d\n', length(BestIndividual));
    
    if start_idx <= length(BestIndividual) && end_idx <= length(BestIndividual)
        TrainSeq = BestIndividual(1, start_idx:end_idx);
        fprintf('TrainSeq长度: %d\n', length(TrainSeq));
        fprintf('TrainSeq前10个值: %s\n', mat2str(TrainSeq(1:min(10,length(TrainSeq)))));
        
        % 检查是否有无效索引
        invalid_indices = find(TrainSeq < 1 | TrainSeq > StopPlanNum);
        if ~isempty(invalid_indices)
            fprintf('发现无效索引: %s\n', mat2str(invalid_indices));
            fprintf('无效索引的值: %s\n', mat2str(TrainSeq(invalid_indices)));
        else
            fprintf('所有索引都有效\n');
        end
    else
        fprintf('索引范围超出BestIndividual长度\n');
    end
    
    % 测试DeCoder
    fprintf('测试DeCoder...\n');
    [Headway,Dwell_Down,Dwell_Up,Runtime_Down,Runtime_Up,RealTime_Down,RealTime_Up]=DeCoder(BestIndividual);
    fprintf('DeCoder运行成功!\n');
    
catch ME
    fprintf('错误: %s\n', ME.message);
    for i=1:length(ME.stack)
        fprintf('  在 %s (第 %d 行)\n', ME.stack(i).name, ME.stack(i).line);
    end
end