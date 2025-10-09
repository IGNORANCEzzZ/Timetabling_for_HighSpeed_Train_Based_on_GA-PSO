%% 测试修复的代码
fprintf('测试开始...\n');

try
    % 清除可能的残余变量
    clear global;
    
    % 初始化全局变量
    fprintf('初始化全局变量...\n');
    Global_Fixed;
    
    % 读取测试数据
    fprintf('读取测试数据...\n');
    BestIndividual = xlsread('电费最低最终解GA+PSO_手动修改上下行',1);
    BadIndividual = xlsread('各个变电站电费最低次优解6_23',1);
    
    % 检查解码函数
    fprintf('开始解码...\n');
    [Headway,Dwell_Down,Dwell_Up,Runtime_Down,Runtime_Up,RealTime_Down,RealTime_Up] = DeCoder(BestIndividual);
    
    % 测试GAFitnessCalc函数
    fprintf('测试GAFitnessCalc函数...\n');
    [GLB_Time_NoSortb,Fitnessb,Costb,C_gridb,C_demb,C_totalb,Cost_gridb,Cost_demb,Power_Time_EachSubStaionNum_AfterRegb,Power_Time_EachSubStaionNum_TracAfterRegb,Power_Time_EachSubStation_BrakAfterRegb]= GAFitnessCalc(BadIndividual);
    
    fprintf('测试成功完成!\n');
    fprintf('头间距大小: %s\n', mat2str(size(Headway)));
    fprintf('停站时间大小: %s\n', mat2str(size(Dwell_Down)));
    fprintf('适应度值: %.2f\n', Fitnessb);
    
catch ME
    fprintf('错误: %s\n', ME.message);
    for i=1:length(ME.stack)
        fprintf('  在 %s (第 %d 行)\n', ME.stack(i).name, ME.stack(i).line);
    end
end