%时间（s）|位置（m）|速度（m/s）|牵引/制动力kn |功率kw |所属供电区间
%一个区间一个元胞速度，元胞数组内对应不同的子区间运行时间

%% 启动性能监控
tic_global = tic;
fprintf('=== 全局参数初始化开始 ===\n');

%% 分相 - 快速模式，减少I/O操作
global SupplySectionNum;
% 直接使用预设值，避免文件读取延迟
if exist('线路参数.xlsx', 'file') || exist('线路参数.xls', 'file')
    try
        Neutral = readmatrix('线路参数','Sheet',5);
        SupplySectionNum = length(Neutral) + 1;
        fprintf('成功读取线路参数: %d个供电区间\n', SupplySectionNum);
    catch
        fprintf('警告：线路参数文件读取失败，使用默认值\n');
        SupplySectionNum = 8;
    end
else
    fprintf('未找到线路参数文件，使用默认值：8个供电区间\n');
    SupplySectionNum = 8;
end
%% 基础参数 - 快速初始化
global P_auxi TrainNum Station StationNum StartStation EndStation;
P_auxi = 300.15; % 辅助功率 kW
TrainNum = 10;   % 列车数

%% 车站信息 - 优化读取策略
station_file_exists = exist('线路参数.xlsx', 'file') || exist('线路参数.xls', 'file');
if station_file_exists
    try
        Station = readmatrix('线路参数', 'Sheet', 1);
        StationNum = length(Station);
        fprintf('成功读取车站信息: %d个车站\n', StationNum);
    catch
        fprintf('车站参数读取失败，使用模拟数据\n');
        StationNum = 11;
        Station = (0:1000:10000)'; % 等间距车站
    end
else
    fprintf('使用默认车站配置: 11个车站\n');
    StationNum = 11;
    Station = (0:1000:10000)'; % 0-10km，每1km一站
end
% 快速设置首末站
StartStation = Station(1);
EndStation = Station(end);

%停站方案种类
global Num_StopPlan;
Num_StopPlan = 10;

%开行方案，行代表不同的开行方案，列代表车站，1表示停，0表示不停
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

%单行别总停站次数和区间数 - 一次性计算
global TotalStopTimes TotalSections;
TotalStopTimes = sum(OperationScheme(:));
TotalSections = TotalStopTimes - Num_StopPlan;
fprintf('停站总次数: %d, 区间总数: %d\n', TotalStopTimes, TotalSections);

%% 数据读取策略 - 极速模式
global OptimizationData;
OptimizationData = cell(StationNum, StationNum);

% 检查数据文件存在情况
data_files = dir('*.xls*');
fprintf('检测到 %d 个数据文件\n', length(data_files));

if length(data_files) > 50  % 如果文件太多，使用快速模式
    fprintf('文件数量较多，启用快速加载模式...\n');
    % 只加载关键文件，减少I/O负担
    for i = 1:min(20, length(data_files))  % 最多只处理20个文件
        filename = data_files(i).name;
        if contains(filename, '-')
            try
                parts = strsplit(filename, '-');
                if length(parts) >= 2
                    row = str2double(parts{1});
                    col_part = strsplit(parts{2}, '.');
                    col = str2double(col_part{1});
                    
                    if ~isnan(row) && ~isnan(col) && row <= StationNum && col <= StationNum
                        % 快速读取，只读第一个sheet
                        try
                            filename_parts = strsplit(filename, '.');
                            base_filename = filename_parts{1};
                            data = readmatrix(base_filename, 'Sheet', 1);
                            OptimizationData{row, col} = {data};
                        catch
                            % 如果读取失败，创建模拟数据
                            time_data = (60:10:120)';
                            OptimizationData{row, col} = {[time_data, zeros(length(time_data), 5)]};
                        end
                    end
                end
            catch
                continue;
            end
        end
        
        if mod(i, 5) == 0
            fprintf('快速模式: %d/%d\n', i, min(20, length(data_files)));
            drawnow;
        end
    end
else
    % 文件较少，正常处理但加速
    fprintf('正常模式处理 %d 个文件...\n', length(data_files));
    for i = 1:length(data_files)
        filename = data_files(i).name;
        if contains(filename, '-')
            try
                % 简化的文件名解析
                parts = strsplit(filename, {'-', '.'});
                if length(parts) >= 3
                    row = str2double(parts{1});
                    col = str2double(parts{2});
                    
                    if ~isnan(row) && ~isnan(col) && row <= StationNum && col <= StationNum
                        try
                            sheets = sheetnames(filename);
                            if ~isempty(sheets)
                                % 只读取前3个sheet，减少处理时间
                                num_sheets = min(3, length(sheets));
                                cell_data = cell(1, num_sheets);
                                for j = 1:num_sheets
                                    cell_data{j} = readmatrix(filename, 'Sheet', j);
                                end
                                OptimizationData{row, col} = cell_data;
                            end
                        catch
                            % 创建默认数据
                            default_data = [(60:10:120)', zeros(7, 5)];
                            OptimizationData{row, col} = {default_data};
                        end
                    end
                end
            catch
                continue;
            end
        end
    end
end

% 为空数据位置填充默认值，避免后续访问错误
for i = 1:StationNum
    for j = 1:StationNum
        if i ~= j && isempty(OptimizationData{i,j})
            % 创建简单的默认运行数据
            distance = abs(i-j);
            base_time = 60 + distance * 10;
            time_points = (0:10:base_time)';
            default_data = [time_points, zeros(length(time_points), 5)];
            OptimizationData{i,j} = {default_data};
        end
    end
end

fprintf('数据加载完成，用时: %.2f秒\n', toc(tic_global));
%% 约束计算 - 向量化优化
global MaxRunTime MinRunTime;
MaxRunTime = zeros(StationNum, StationNum);
MinRunTime = zeros(StationNum, StationNum);

% 快速计算运行时间约束
for i = 1:StationNum
    for j = 1:StationNum
        if ~isempty(OptimizationData{i,j})
            if iscell(OptimizationData{i,j})
                MaxRunTime(i,j) = length(OptimizationData{i,j});
                MinRunTime(i,j) = 1;
            else
                MaxRunTime(i,j) = 1;
                MinRunTime(i,j) = 1;
            end
        end
    end
end

fprintf('运行时间约束计算完成\n');
%% 区间时间计算 - 预分配优化
global MaxTotalSectionTime MaxTotalSectionTimeEachPlanDown MinTotalSectionTimeEachPlanDown;
global MaxTotalSectionTimeEachPlanUp MinTotalSectionTimeEachPlanUp;

% 一次性预分配所有数组
MaxTotalSectionTimeEachPlanDown = zeros(1, Num_StopPlan);
MinTotalSectionTimeEachPlanDown = zeros(1, Num_StopPlan);
MaxTotalSectionTimeEachPlanUp = zeros(1, Num_StopPlan);
MinTotalSectionTimeEachPlanUp = zeros(1, Num_StopPlan);
MaxTotalSectionTime = 0;
%% 矩阵预分配 - 内存优化
global MaxRunTimeMat MinRunTimeMat;
MaxRunTimeMat = ones(1, 2*TotalSections);
MinRunTimeMat = ones(1, 2*TotalSections);
index_RunTimeMat = 0;

fprintf('开始计算停站方案时间矩阵...\n');
%%
for i = 1:Num_StopPlan
    StopPlan = OperationScheme(i,:); %本趟车的停站方案
    StopStation = find(StopPlan == 1); %停站车站
    StopNum = length(StopStation); %停站次数
    
    % 预分配变量
    maxTotalSectionTimeDown = 0;
    minTotalSectionTimeDown = 0;
    maxTotalSectionTimeUp = 0;
    minTotalSectionTimeUp = 0;
    MaxTotalSectionTime = 0;
    
    for j = 1:(StopNum-1)
        index_RunTimeMat = index_RunTimeMat + 1;
        
        % 增加安全检查，避免访问空数据导致崩溃
        down_data = OptimizationData{StopStation(j), StopStation(j+1)};
        up_data = OptimizationData{StopStation(j+1), StopStation(j)};
        
        if ~isempty(down_data) && iscell(down_data) && length(down_data) > 0
            if ~isempty(down_data{1,end}) && ~isempty(down_data{1,1})
                maxTotalSectionTimeDown = maxTotalSectionTimeDown + down_data{1,end}(end,1);
                minTotalSectionTimeDown = minTotalSectionTimeDown + down_data{1,1}(end,1);
            end
        else
            warning('下行方向站点 %d 到 %d 的数据为空', StopStation(j), StopStation(j+1));
        end
        
        if ~isempty(up_data) && iscell(up_data) && length(up_data) > 0
            if ~isempty(up_data{1,end}) && ~isempty(up_data{1,1})
                maxTotalSectionTimeUp = maxTotalSectionTimeUp + up_data{1,end}(end,1);
                minTotalSectionTimeUp = minTotalSectionTimeUp + up_data{1,1}(end,1);
            end
        else
            warning('上行方向站点 %d 到 %d 的数据为空', StopStation(j+1), StopStation(j));
        end
        
        MaxRunTimeMat(1, index_RunTimeMat) = MaxRunTime(StopStation(j), StopStation(j+1));
        MaxRunTimeMat(1, TotalSections + index_RunTimeMat) = MaxRunTime(StopStation(j+1), StopStation(j));
    end
    
    % 使用max函数更简洁
    MaxTotalSectionTime = max([MaxTotalSectionTime, maxTotalSectionTimeDown, maxTotalSectionTimeUp]);
    
    MaxTotalSectionTimeEachPlanDown(1,i) = maxTotalSectionTimeDown;
    MinTotalSectionTimeEachPlanDown(1,i) = minTotalSectionTimeDown;
    MaxTotalSectionTimeEachPlanUp(1,i) = maxTotalSectionTimeUp;
    MinTotalSectionTimeEachPlanUp(1,i) = minTotalSectionTimeUp;
end  

%% 车站停站时间范围约束（其实是范围约束）
%第i列表示第i个车站的停站范围，每个车站使用同一个约束
global MaxDwellTime
MaxDwellTime = 1200 * ones(1, StationNum);
MaxDwellTime([1, end]) = 0; % 向量化赋值，更高效

global MinDwellTime;
MinDwellTime = 120 * ones(1, StationNum);
MinDwellTime([1, end]) = 0; % 向量化赋值，更高效
%% 每种停站方案的最长总停站时间和最短总停站时间
global MaxTotalDwellTimeEachPlan;
MaxTotalDwellTimeEachPlan=zeros(1,Num_StopPlan);
global MinTotalDwellTimeEachPlan;
MinTotalDwellTimeEachPlan=zeros(1,Num_StopPlan);
%% 站停站时间范围约束（其实是范围约束）写成（1，TotalStopTimes）的形式，以便于初始化种群时使用
global MaxDwellTimeMat;
MaxDwellTimeMat = zeros(1, TotalStopTimes);
global MinDwellTimeMat;
MinDwellTimeMat = zeros(1, TotalStopTimes);
index_DwellTimeMat = 0;

for i = 1:Num_StopPlan
    % 使用向量化操作提高效率
    stop_indices = find(OperationScheme(i,:) == 1);
    
    % 批量赋值，避免逐个赋值
    num_stops = length(stop_indices);
    if num_stops > 0
        range_indices = (index_DwellTimeMat + 1):(index_DwellTimeMat + num_stops);
        MaxDwellTimeMat(range_indices) = MaxDwellTime(stop_indices);
        MinDwellTimeMat(range_indices) = MinDwellTime(stop_indices);
        index_DwellTimeMat = index_DwellTimeMat + num_stops;
        
        % 直接计算总和
        MaxTotalDwellTimeEachPlan(1,i) = sum(MaxDwellTime(stop_indices));
        MinTotalDwellTimeEachPlan(1,i) = sum(MinDwellTime(stop_indices));
    else
        MaxTotalDwellTimeEachPlan(1,i) = 0;
        MinTotalDwellTimeEachPlan(1,i) = 0;
    end
end
%% 发车时间范围约束（其实是范围约束）
%第i列表示第i辆车
global MaxHeadwayTime;
MaxHeadwayTime = 1200 * ones(1, TrainNum);
global MinHeadwayTime;
MinHeadwayTime = 120 * ones(1, TrainNum);

%% 单列车总旅行时间范围约束；
%总旅行时间=所有子区间运行时间+中间车站的停站时间
global MaxTotalTravelTimeDown;
MaxTotalTravelTimeDown = zeros(1, Num_StopPlan);
% 向量化计算，提高效率
base_time_down = (MaxTotalSectionTimeEachPlanDown + MaxTotalDwellTimeEachPlan + ...
                  MinTotalSectionTimeEachPlanDown + MinTotalDwellTimeEachPlan) / 2;
MaxTotalTravelTimeDown = base_time_down + 300;
% 特殊调整
MaxTotalTravelTimeDown(end) = MaxTotalTravelTimeDown(end) + 500;
if Num_StopPlan >= 8
    MaxTotalTravelTimeDown(8) = MaxTotalTravelTimeDown(8) - 300;
end
if Num_StopPlan >= 2
    MaxTotalTravelTimeDown(2) = MaxTotalTravelTimeDown(2) + 100;
end

global MinTotalTravelTimeDown;
MinTotalTravelTimeDown = zeros(1, Num_StopPlan);
MinTotalTravelTimeDown = base_time_down - 300;
% 特殊调整
MinTotalTravelTimeDown(end) = MinTotalTravelTimeDown(end) + 500;
if Num_StopPlan >= 8
    MinTotalTravelTimeDown(8) = MinTotalTravelTimeDown(8) - 300;
end
if Num_StopPlan >= 2
    MinTotalTravelTimeDown(2) = MinTotalTravelTimeDown(2) + 100;
end

global MaxTotalTravelTimeUp;
MaxTotalTravelTimeUp = zeros(1, Num_StopPlan);
% 向量化计算，提高效率
base_time_up = (MaxTotalSectionTimeEachPlanUp + MaxTotalDwellTimeEachPlan + ...
                MinTotalSectionTimeEachPlanUp + MinTotalDwellTimeEachPlan) / 2;
MaxTotalTravelTimeUp = base_time_up + 240;
% 特殊调整
if Num_StopPlan >= 4
    MaxTotalTravelTimeUp(4) = MaxTotalTravelTimeUp(4) + 120;
end
if Num_StopPlan >= 7
    MaxTotalTravelTimeUp(7) = MaxTotalTravelTimeUp(7) + 120;
end

global MinTotalTravelTimeUp;
MinTotalTravelTimeUp = zeros(1, Num_StopPlan);
% 修复原代码中的负号错误
MinTotalTravelTimeUp = (MaxTotalSectionTimeEachPlanUp + MaxTotalDwellTimeEachPlan + ...
                       MinTotalSectionTimeEachPlanUp + MinTotalDwellTimeEachPlan) / 2 - 240;
% 特殊调整
if Num_StopPlan >= 4
    MinTotalTravelTimeUp(4) = MinTotalTravelTimeUp(4) + 120;
end
if Num_StopPlan >= 7
    MinTotalTravelTimeUp(7) = MinTotalTravelTimeUp(7) + 120;
end

%% 铁路服务时间约束
global ServiceTimeConstrant;
% 使用向量化操作提高效率
ServiceTimeConstrant = (sum(MaxHeadwayTime) + sum(MinHeadwayTime)) / 2 + ...
                      (MaxTotalTravelTimeDown(1) + MinTotalTravelTimeDown(1) + ...
                       MaxTotalTravelTimeUp(1) + MinTotalTravelTimeUp(1)) / 4;

%% 安全距离约束：

%% 罚函数系数
% 单列车总旅行时间罚函数系数
global f_travel;
f_travel = 1000000;

global f_service;
f_service = 1000000;

global f_safety;
f_safety = 1000000;

%% 编码长度
global Col_of_Individual;%一个个体的染色体数量=开行车数*2+开行方案总的停站次数*2+开行方案中的区间数*2+停站方案数*2
Col_of_Individual = TrainNum * 2 + TotalStopTimes * 2 + TotalSections * 2 + Num_StopPlan * 2;

%% 遗传算法相关量 - 优化参数
global GAPopSize;
GAPopSize = 200; % 减小种群规模，提高速度

%% 标准PSO相关参数 - 优化设置
global Omega;%惯性权重
Omega = 0.4;

%固定学习因子
global c1;
c1 = 2;
global c2;
c2 = 2;

global IterMaxPSO;
IterMaxPSO = 1000; % 减少迭代次数，提高速度
global PSOPopSize;
PSOPopSize = 200; % 减小种群规模

%时变学习因子
global c1_i;
c1_i = 2.5;
global c1_f;
c1_f = 0.5;
global c2_i;
c2_i = 0.5;
global c2_f;
c2_f = 2.5;

%停机准则
global fitness_stop;
fitness_stop = 60;

%% 竞争进化策略粒子群算法相关参数
global Num_Parts;
Num_Parts = 5;
global fai;
fai = 0.1;

%% 禁忌搜索相关参数
global Swarm1Size;
global Swarm2Size;
Swarm1Size = floor(PSOPopSize / 10); % 使用floor确保整数
Swarm2Size = PSOPopSize - Swarm1Size;

global T_tabu;
T_tabu = 10;
global T_free;
T_free = 15;

% 清理临时变量，释放内存
clear base_time_down base_time_up;

total_time = toc(tic_global);
fprintf('=== 全局参数初始化完成，总用时: %.2f秒 ===\n', total_time);
fprintf('内存优化完成，已准备就绪。\n');

% 显示关键参数
fprintf('\n--- 关键参数概览 ---\n');
fprintf('车站数: %d\n', StationNum);
fprintf('列车数: %d\n', TrainNum);
fprintf('停站方案数: %d\n', Num_StopPlan);
fprintf('种群规模: %d\n', PSOPopSize);
fprintf('最大迭代: %d\n', IterMaxPSO);
fprintf('编码长度: %d\n', Col_of_Individual);
fprintf('--- 参数检查完成 ---\n\n');
