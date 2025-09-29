%时间（s）|位置（m）|速度（m/s）|牵引/制动力kn |功率kw |所在供电区间编号
%一车一行一个元素速度，元素对应在对应的同时刻下的运行时间
%% 基础参数设置
global P_auxi;
P_auxi=300.15; %单位kw）

%% 试运行模式 - 不读取Excel文件
fprintf('警告：运行在模拟数据模式下...\n');

%% 线路基本信息 - 使用默认值
global SupplySectionNum;
SupplySectionNum = 8;  % 默认供电区间数

%% 列车运行相关参数
%列车数 
global TrainNum;
TrainNum=20;           

%站台 - 使用默认站台位置
global Station;
Station = (0:1000:10000)';  % 11个站台，间距约1000米
global StationNum;%站台数
StationNum=length(Station);

% 第一个站台
global StartStation;
StartStation=Station(1,1);
%最后一个站台
global EndStation;
EndStation=Station(end,1);

%停站方案个数
global Num_StopPlan;
Num_StopPlan=10;

%列车运行方向不同的开行方案，不同的开行方案停靠站台，1表示停，0表示不停
global OperationScheme;
OperationScheme=zeros(Num_StopPlan,StationNum);
OperationScheme(1,[1,4,7,8,9,11])=1;
OperationScheme(2,[1,2,5,9,11])=1;
OperationScheme(3,[1,2,4,10,11])=1;
OperationScheme(4,[1,2,5,7,10,11])=1;
OperationScheme(5,[1,2,4,11])=1;
OperationScheme(6,[1,2,7,11])=1;
OperationScheme(7,[1,2,4,8,11])=1;
OperationScheme(8,[1,2,9,10,11])=1;
OperationScheme(9,[1,2,4,5,8,11])=1;
OperationScheme(10,[1,2,11])=1;

%所有班次停站次数
global TotalStopTimes;
TotalStopTimes=sum(sum(OperationScheme));
%所有班次区间数
global TotalSections;
TotalSections=sum(sum(OperationScheme))-Num_StopPlan;

%% 创建模拟优化数据
global OptimizationData;
OptimizationData=cell(StationNum,StationNum);

fprintf('创建模拟优化数据...\n');
for i=1:StationNum
    for j=1:StationNum
        if i ~= j
            % 创建模拟的优化数据
            % 每个数据集包含：时间、位置、速度、加速度、功率、区间
            distance = abs(i-j) * 1000; % 假设站间距离1000米
            max_speed = 80; % 最大速度80 km/h
            time_points = 100;
            
            % 创建5种不同的运行策略
            num_strategies = 5;
            DataforOneSection = cell(1, num_strategies);
            
            for strategy = 1:num_strategies
                % 生成时间序列
                base_time = 60 + strategy * 10; % 基础时间60-110秒
                time_series = linspace(0, base_time, time_points)';
                
                % 生成位置序列（从station i到station j）
                position_series = Station(i,1) + (Station(j,1) - Station(i,1)) * (time_series / base_time);
                
                % 生成速度序列（梯形速度曲线）
                velocity_series = zeros(time_points, 1);
                accel_time = base_time * 0.3;
                decel_time = base_time * 0.3;
                cruise_time = base_time - accel_time - decel_time;
                
                for t = 1:time_points
                    if time_series(t) <= accel_time
                        velocity_series(t) = max_speed * time_series(t) / accel_time;
                    elseif time_series(t) <= accel_time + cruise_time
                        velocity_series(t) = max_speed;
                    else
                        velocity_series(t) = max_speed * (base_time - time_series(t)) / decel_time;
                    end
                end
                
                % 生成加速度序列
                acceleration_series = [0; diff(velocity_series)];
                
                % 生成功率序列（基于速度和加速度）
                power_series = 100 + 50 * velocity_series + 200 * abs(acceleration_series) + 50 * randn(time_points, 1);
                
                % 生成区间序列
                section_series = ones(time_points, 1) * min(i,j);
                
                % 组合数据：[时间, 位置, 速度, 加速度, 功率, 区间]
                DataforOneSection{1,strategy} = [time_series, position_series, velocity_series, acceleration_series, power_series, section_series];
            end
            
            OptimizationData{i,j} = DataforOneSection;
        end
    end
end

%% 约束  
%% 每条线路区间运行时间范围约束，实际运行的范围约束
%区间站台,站台相间的区间数
% (i,j)表示从i站行至到j站所需的运行时间范围约束
global MaxRunTime;
MaxRunTime=zeros(StationNum,StationNum);
global MinRunTime;
MinRunTime=zeros(StationNum,StationNum);

for i=1:1:StationNum
    for j=1:1:StationNum
        if ~isempty(OptimizationData{i,j})
            MaxRunTime(i,j)=length(OptimizationData{i,j});
            MinRunTime(i,j)=1;
        else
            MaxRunTime(i,j)=0;
            MinRunTime(i,j)=0;
        end
    end
end

%% 计算所有停站方案中的总区间运行时间范围（不包括停站时间）
global MaxTotalSectionTime;
%% 每个停站方案下行和上行分别的总区间运行时间（不包括停站时间）
global MaxTotalSectionTimeEachPlanDown;
MaxTotalSectionTimeEachPlanDown=zeros(1,Num_StopPlan);
global MinTotalSectionTimeEachPlanDown;
MinTotalSectionTimeEachPlanDown=zeros(1,Num_StopPlan);
global MaxTotalSectionTimeEachPlanUp;
MaxTotalSectionTimeEachPlanUp=zeros(1,Num_StopPlan);
global MinTotalSectionTimeEachPlanUp;
MinTotalSectionTimeEachPlanUp=zeros(1,Num_StopPlan);

%% 列车区间运行时间重新范围整理成,写成：1到TotalSections向量形式，以便于初始化种群时使用
global MaxRunTimeMat;
MaxRunTimeMat=ones(1,2*TotalSections);
global MinRunTimeMat;
MinRunTimeMat=ones(1,2*TotalSections);

index_RunTimeMat=0;
for i=1:1:Num_StopPlan
    StopPlan=OperationScheme(i,:);%该趟车的停站方案
    StopStation=find(StopPlan==1);%停站的站台
    StopNum=length(StopStation);%停站个数
    maxTotalSectionTimeDown=0;
    minTotalSectionTimeDown=0;
    maxTotalSectionTimeUp=0;
    minTotalSectionTimeUp=0;
    MaxTotalSectionTime=0;
    
    for j=1:1:StopNum-1
        index_RunTimeMat=index_RunTimeMat+1;
        
        % 安全检查：确保数据存在
        if ~isempty(OptimizationData{StopStation(1,j),StopStation(1,j+1)}) && ...
           ~isempty(OptimizationData{StopStation(1,j+1),StopStation(1,j)})
            
            downData = OptimizationData{StopStation(1,j),StopStation(1,j+1)};
            upData = OptimizationData{StopStation(1,j+1),StopStation(1,j)};
            
            if ~isempty(downData{1,end}) && ~isempty(downData{1,1}) && ...
               ~isempty(upData{1,end}) && ~isempty(upData{1,1})
                
                maxTotalSectionTimeDown=maxTotalSectionTimeDown+downData{1,end}(end,1);
                maxTotalSectionTimeUp=maxTotalSectionTimeUp+upData{1,end}(end,1);      
                minTotalSectionTimeDown=minTotalSectionTimeDown+downData{1,1}(end,1);
                minTotalSectionTimeUp=minTotalSectionTimeUp+upData{1,1}(end,1);
                
                MaxRunTimeMat(1,index_RunTimeMat)=MaxRunTime(StopStation(1,j),StopStation(1,j+1));
                MaxRunTimeMat(1,TotalSections+index_RunTimeMat)=MaxRunTime(StopStation(1,j+1),StopStation(1,j));
            else
                % 如果数据为空，使用默认值
                default_time = 60; % 60秒默认区间时间
                maxTotalSectionTimeDown = maxTotalSectionTimeDown + default_time;
                maxTotalSectionTimeUp = maxTotalSectionTimeUp + default_time;
                minTotalSectionTimeDown = minTotalSectionTimeDown + default_time;
                minTotalSectionTimeUp = minTotalSectionTimeUp + default_time;
                
                MaxRunTimeMat(1,index_RunTimeMat) = 5; % 默认5种策略
                MaxRunTimeMat(1,TotalSections+index_RunTimeMat) = 5;
            end
        else
            % 如果数据为空，使用默认值
            default_time = 60; % 60秒默认区间时间
            maxTotalSectionTimeDown = maxTotalSectionTimeDown + default_time;
            maxTotalSectionTimeUp = maxTotalSectionTimeUp + default_time;
            minTotalSectionTimeDown = minTotalSectionTimeDown + default_time;
            minTotalSectionTimeUp = minTotalSectionTimeUp + default_time;
            
            MaxRunTimeMat(1,index_RunTimeMat) = 5; % 默认5种策略
            MaxRunTimeMat(1,TotalSections+index_RunTimeMat) = 5;
        end
    end
    
    if maxTotalSectionTimeDown>MaxTotalSectionTime
        MaxTotalSectionTime=maxTotalSectionTimeDown;
    end
    if maxTotalSectionTimeUp>MaxTotalSectionTime
        MaxTotalSectionTime=maxTotalSectionTimeUp;
    end
    MaxTotalSectionTimeEachPlanDown(1,i)=maxTotalSectionTimeDown;
    MinTotalSectionTimeEachPlanDown(1,i)=minTotalSectionTimeDown;
    MaxTotalSectionTimeEachPlanUp(1,i)=maxTotalSectionTimeUp;
    MinTotalSectionTimeEachPlanUp(1,i)=minTotalSectionTimeUp;
end  

%% 车站停站时间范围约束，实际的范围约束
%第i行表示第i个车站的停站范围，每个车站使用同一个约束
global MaxDwellTime
MaxDwellTime=1200*ones(1,StationNum);
MaxDwellTime(1,1)=0;
MaxDwellTime(1,end)=0;

global MinDwellTime;
MinDwellTime=120*ones(1,StationNum);
MinDwellTime(1,1)=0;
MinDwellTime(1,end)=0;

%% 每个停站方案总共的停站时间上下界总停站时间
global MaxTotalDwellTimeEachPlan;
MaxTotalDwellTimeEachPlan=zeros(1,Num_StopPlan);
global MinTotalDwellTimeEachPlan;
MinTotalDwellTimeEachPlan=zeros(1,Num_StopPlan);

%% 站停站时间范围约束，实际的范围约束写成：1到TotalStopTimes向量形式，以便于初始化种群时使用
global MaxDwellTimeMat;
MaxDwellTimeMat=zeros(1,TotalStopTimes);
global MinDwellTimeMat;
MinDwellTimeMat=zeros(1,TotalStopTimes);

index_DwellTimeMat=0;
for i=1:1:Num_StopPlan
    maxDwellTime=0;
    minDwellTime=0;
    for j=1:1:StationNum
        if OperationScheme(i,j)==1
            index_DwellTimeMat=index_DwellTimeMat+1;
            MaxDwellTimeMat(1,index_DwellTimeMat)=MaxDwellTime(1,j);           
            MinDwellTimeMat(1,index_DwellTimeMat)=MinDwellTime(1,j);
            maxDwellTime=maxDwellTime+MaxDwellTime(1,j);
            minDwellTime=minDwellTime+MinDwellTime(1,j);
        end
    end
    MaxTotalDwellTimeEachPlan(1,i)=maxDwellTime;
    MinTotalDwellTimeEachPlan(1,i)=minDwellTime;
end

%% 发车时间范围约束，实际的范围约束
%第i行表示第i趟车
global MaxHeadwayTime;
MaxHeadwayTime=1200*ones(1,TrainNum);
global MinHeadwayTime;
MinHeadwayTime=120*ones(1,TrainNum);

%% 列车总旅行时间范围约束
%旅行时间=区间运行总时间+中间车站的停站时间
global MaxTotalTravelTimeDown;
MaxTotalTravelTimeDown=zeros(1,Num_StopPlan);
MaxTotalTravelTimeDown(1,1:Num_StopPlan)=(MaxTotalSectionTimeEachPlanDown+MaxTotalDwellTimeEachPlan+MinTotalSectionTimeEachPlanDown+MinTotalDwellTimeEachPlan)/2+300;

global MinTotalTravelTimeDown;
MinTotalTravelTimeDown=zeros(1,Num_StopPlan);
MinTotalTravelTimeDown(1,1:Num_StopPlan)=(MaxTotalSectionTimeEachPlanDown+MaxTotalDwellTimeEachPlan+MinTotalSectionTimeEachPlanDown+MinTotalDwellTimeEachPlan)/2-300;

global MaxTotalTravelTimeUp;
MaxTotalTravelTimeUp=zeros(1,Num_StopPlan);
MaxTotalTravelTimeUp(1,1:Num_StopPlan)=(MaxTotalSectionTimeEachPlanUp+MaxTotalDwellTimeEachPlan+MinTotalSectionTimeEachPlanUp+MinTotalDwellTimeEachPlan)/2+240;

global MinTotalTravelTimeUp;
MinTotalTravelTimeUp=zeros(1,Num_StopPlan);
MinTotalTravelTimeUp(1,1:Num_StopPlan)=(MaxTotalSectionTimeEachPlanUp+MaxTotalDwellTimeEachPlan+MinTotalSectionTimeEachPlanUp+MinTotalDwellTimeEachPlan)/2-240;

%% 线路服务时间约束
global ServiceTimeConstrant;
ServiceTimeConstrant=(sum(MaxHeadwayTime,2)+sum(MinHeadwayTime,2))/2+(MaxTotalTravelTimeDown(1,1)+MinTotalTravelTimeDown(1,1)+MaxTotalTravelTimeUp(1,1)+MinTotalTravelTimeUp(1,1))/4;

%% 安全距离约束；

%% 惩罚系数
% 列车总旅行时间违反惩罚系数
global f_travel;
f_travel=1000000;

global f_service;
f_service=1000000;

global f_safety;
f_safety=1000000;

%% 长度
global Col_of_Individual;%一个个体的染色体长度=列车趟数*2+列车运行中的停站次数*2+列车运行中的区间数*2+停站方案数*2
Col_of_Individual=TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan*2;

%% 遗传算法参数设置
global GAPopSize;
GAPopSize=500;

%% 标准PSO相关参数
global Omega;%惯性权重
Omega=0.4;

%固定学习因子
global c1;
c1=2;
global c2;
c2=2;

global IterMaxPSO;
IterMaxPSO=50;  % 减少最大迭代次数以加快测试
global PSOPopSize;
PSOPopSize=20;  % 减小种群规模以加快计算

%时变学习因子
global c1_i;
c1_i=2.5;
global c1_f;
c1_f=0.5;
global c2_i;
c2_i=0.5;
global c2_f;
c2_f=2.5;

%停止准则
global fitness_stop;
fitness_stop=60000;

%% 多种群多样性种群算法相关参数
global Num_Parts;
Num_Parts=5;
global fai;
fai=0.1;

%% 混合算法相关参数
global Swarm1Size;
global Swarm2Size;
Swarm1Size=PSOPopSize/10;
Swarm2Size=PSOPopSize-Swarm1Size;

global T_tabu;
T_tabu=10;
global T_free;
T_free=15;

fprintf('Global variables initialized successfully!\n');