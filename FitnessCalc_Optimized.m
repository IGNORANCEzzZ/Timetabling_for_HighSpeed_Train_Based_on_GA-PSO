function [Fitness]= FitnessCalc_Optimized(Individual,SupplySectionNum,TrainNum,StationNum,Num_StopPlan,f_travel,f_service,f_safety,MaxTotalTravelTimeDown,MinTotalTravelTimeDown,MaxTotalTravelTimeUp,MinTotalTravelTimeUp,ServiceTimeConstrant,OperationScheme,OptimizationData,MaxTotalSectionTimeEachPlanDown,MaxTotalSectionTimeEachPlanUp,MaxTotalDwellTimeEachPlan,TotalStopTimes,TotalSections,P_auxi,StartStation,EndStation)

%% 性能优化版本的适应度计算函数
%% 减少大矩阵操作，简化计算逻辑

%% 解码个体预设参数
Headway_Down=Individual(1,1:TrainNum);
Headway_Up=Individual(1,TrainNum+1:TrainNum*2);
DwellTimes_Down=Individual(TrainNum*2+1:TrainNum*2+TotalStopTimes);
DwellTimes_Up=Individual(TrainNum*2+TotalStopTimes+1:TrainNum*2+TotalStopTimes*2);
IntervalTimes_Down=Individual(TrainNum*2+TotalStopTimes*2+1:TrainNum*2+TotalStopTimes*2+TotalSections);
IntervalTimes_Up=Individual(TrainNum*2+TotalStopTimes*2+TotalSections+1:TrainNum*2+TotalStopTimes*2+TotalSections*2);
Plan_Down=Individual(TrainNum*2+TotalStopTimes*2+TotalSections*2+1:TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan);
Plan_Up=Individual(TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan+1:TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan*2);

%% 建立停站时间矩阵
DwellTimeMatDown=zeros(Num_StopPlan,StationNum);
DwellTimeMatUp=zeros(Num_StopPlan,StationNum);

if length(DwellTimes_Down)==TotalStopTimes && length(DwellTimes_Up)==TotalStopTimes
    index=0;
    for i=1:Num_StopPlan
        for j=1:StationNum
            if OperationScheme(i,j)==1 
                index=index+1;
                DwellTimeMatDown(i,j)=DwellTimes_Down(1,index);
                DwellTimeMatUp(i,j)=DwellTimes_Up(1,index);
            end
        end
    end
else
    Fitness = 1e10; % 返回一个很大的惩罚值
    return
end

%% 建立区间时间矩阵
IntervalTimesCell=cell(1,Num_StopPlan);
if TotalSections==length(IntervalTimes_Down) && TotalSections==length(IntervalTimes_Up)
    index=0;
    for i=1:Num_StopPlan
        StopPlan=OperationScheme(i,:);
        StopStation=find(StopPlan==1);
        StopNum=length(StopStation);
        SectionTimeIndex=zeros(StationNum,StationNum);
        for j=1:StopNum-1
            index=index+1;
            SectionTimeIndex(StopStation(1,j),StopStation(1,j+1))=IntervalTimes_Down(1,index);
            SectionTimeIndex(StopStation(1,j+1),StopStation(1,j))=IntervalTimes_Up(1,index);
        end
       IntervalTimesCell{1,i}=SectionTimeIndex;
    end
else
    Fitness = 1e10; % 返回一个很大的惩罚值
    return
end

%% 简化的计算逻辑 - 只计算基本的能耗和约束违反
TravelTimeDeviation = 0;
ServiceTimeDeviation = 0;
TotalEnergyCost = 0;
SafetyViolation = 0;

%% 下行列车简化计算
for i=1:TrainNum
    plan_index=mod(i,Num_StopPlan);
    if plan_index==0
        plan_index=Num_StopPlan;
    end
    StopPlanNum=Plan_Down(1,plan_index);
    
    if StopPlanNum < 1 || StopPlanNum > Num_StopPlan
        StopPlanNum = 1; % 默认使用第一个停站方案
    end
    
    StopPlan=OperationScheme(StopPlanNum,:);
    StopStation=find(StopPlan==1);
    StopNum=length(StopStation);
    SectionNum=StopNum-1;
    
    % 计算总旅行时间
    total_section_time = 0;
    total_dwell_time = 0;
    total_energy = 0;
    
    for j=1:SectionNum
        IndexofSectionRunTime=IntervalTimesCell{1,StopPlanNum}(StopStation(1,j),StopStation(1,j+1));
        
        % 安全检查
        if IndexofSectionRunTime < 1 || IndexofSectionRunTime > 5
            IndexofSectionRunTime = 1;
        end
        
        % 简化的能耗计算 - 基于距离和时间
        section_distance = abs(StopStation(1,j+1) - StopStation(1,j)) * 1000; % 米
        base_energy = section_distance * 0.1; % 简化的能耗计算
        total_energy = total_energy + base_energy;
        
        % 计算区间运行时间
        if ~isempty(OptimizationData{StopStation(1,j),StopStation(1,j+1)}) && ...
           IndexofSectionRunTime <= length(OptimizationData{StopStation(1,j),StopStation(1,j+1)})
            
            OptimizeData = OptimizationData{StopStation(1,j),StopStation(1,j+1)}{1,IndexofSectionRunTime};
            if ~isempty(OptimizeData)
                section_time = OptimizeData(end,1);
            else
                section_time = 60; % 默认60秒
            end
        else
            section_time = 60; % 默认60秒
        end
        
        total_section_time = total_section_time + section_time;
        total_dwell_time = total_dwell_time + DwellTimeMatDown(StopPlanNum,StopStation(1,j+1));
    end
    
    % 计算旅行时间偏差
    RealTravelTime = total_section_time + total_dwell_time;
    if RealTravelTime > MaxTotalTravelTimeDown(1,StopPlanNum)
        TravelTimeDeviation = TravelTimeDeviation + (RealTravelTime - MaxTotalTravelTimeDown(1,StopPlanNum));
    elseif RealTravelTime < MinTotalTravelTimeDown(1,StopPlanNum)
        TravelTimeDeviation = TravelTimeDeviation + (MinTotalTravelTimeDown(1,StopPlanNum) - RealTravelTime);
    end
    
    TotalEnergyCost = TotalEnergyCost + total_energy;
end

%% 上行列车简化计算（类似逻辑）
for i=1:TrainNum
    plan_index=mod(i,Num_StopPlan);
    if plan_index==0
        plan_index=Num_StopPlan;
    end
    StopPlanNum=Plan_Up(1,plan_index);
    
    if StopPlanNum < 1 || StopPlanNum > Num_StopPlan
        StopPlanNum = 1; % 默认使用第一个停站方案
    end
    
    StopPlan=OperationScheme(StopPlanNum,:);
    StopStation=find(StopPlan==1);
    StopStation=fliplr(StopStation); % 上行反向
    StopNum=length(StopStation);
    SectionNum=StopNum-1;
    
    % 计算总旅行时间
    total_section_time = 0;
    total_dwell_time = 0;
    total_energy = 0;
    
    for j=1:SectionNum
        IndexofSectionRunTime=IntervalTimesCell{1,StopPlanNum}(StopStation(1,j),StopStation(1,j+1));
        
        % 安全检查
        if IndexofSectionRunTime < 1 || IndexofSectionRunTime > 5
            IndexofSectionRunTime = 1;
        end
        
        % 简化的能耗计算
        section_distance = abs(StopStation(1,j+1) - StopStation(1,j)) * 1000; % 米
        base_energy = section_distance * 0.1; % 简化的能耗计算
        total_energy = total_energy + base_energy;
        
        % 计算区间运行时间
        if ~isempty(OptimizationData{StopStation(1,j),StopStation(1,j+1)}) && ...
           IndexofSectionRunTime <= length(OptimizationData{StopStation(1,j),StopStation(1,j+1)})
            
            OptimizeData = OptimizationData{StopStation(1,j),StopStation(1,j+1)}{1,IndexofSectionRunTime};
            if ~isempty(OptimizeData)
                section_time = OptimizeData(end,1);
            else
                section_time = 60; % 默认60秒
            end
        else
            section_time = 60; % 默认60秒
        end
        
        total_section_time = total_section_time + section_time;
        total_dwell_time = total_dwell_time + DwellTimeMatUp(StopPlanNum,StopStation(1,j+1));
    end
    
    % 计算旅行时间偏差
    RealTravelTime = total_section_time + total_dwell_time;
    if RealTravelTime > MaxTotalTravelTimeUp(1,StopPlanNum)
        TravelTimeDeviation = TravelTimeDeviation + (RealTravelTime - MaxTotalTravelTimeUp(1,StopPlanNum));
    elseif RealTravelTime < MinTotalTravelTimeUp(1,StopPlanNum)
        TravelTimeDeviation = TravelTimeDeviation + (MinTotalTravelTimeUp(1,StopPlanNum) - RealTravelTime);
    end
    
    TotalEnergyCost = TotalEnergyCost + total_energy;
end

%% 简化的服务时间约束检查
max_headway = max([sum(Headway_Down), sum(Headway_Up)]);
if abs(max_headway - ServiceTimeConstrant) > 600
    ServiceTimeDeviation = abs(max_headway - ServiceTimeConstrant);
end

%% 简化的安全约束检查（基于发车间隔）
min_headway_down = min(Headway_Down);
min_headway_up = min(Headway_Up);
safety_threshold = 60; % 最小60秒间隔

if min_headway_down < safety_threshold
    SafetyViolation = SafetyViolation + (safety_threshold - min_headway_down);
end
if min_headway_up < safety_threshold
    SafetyViolation = SafetyViolation + (safety_threshold - min_headway_up);
end

%% 计算总适应度
Fitness = TotalEnergyCost + f_travel * TravelTimeDeviation + f_service * ServiceTimeDeviation + f_safety * SafetyViolation;

end