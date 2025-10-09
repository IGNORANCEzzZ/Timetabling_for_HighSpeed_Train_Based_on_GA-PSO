  function [Fitness]= FitnessCalc(Individual,SupplySectionNum,TrainNum,StationNum,Num_StopPlan,f_travel,f_service,f_safety,MaxTotalTravelTimeDown,MinTotalTravelTimeDown,MaxTotalTravelTimeUp,MinTotalTravelTimeUp,ServiceTimeConstrant,OperationScheme,OptimizationData,MaxTotalSectionTimeEachPlanDown,MaxTotalSectionTimeEachPlanUp,MaxTotalDwellTimeEachPlan,TotalStopTimes,TotalSections,P_auxi,StartStation,EndStation)
%FitnessCalc(Individual,SupplySectionNum,TrainNum,StationNum,Num_StopPlan,f_travel,f_service,f_safety,MaxTotalTravelTimeDown,MinTotalTravelTimeDown,MaxTotalTravelTimeUp,MinTotalTravelTimeUp,ServiceTimeConstrant,OperationScheme,OptimizationData,MaxTotalSectionTimeEachPlanDown,MaxTotalSectionTimeEachPlanUp,MaxTotalDwellTimeEachPlan,TotalStopTimes,TotalSections)
%% 输入
%Individual,一个个体
%一个个体的染色体数量=开行车数*2+开行方案种的停站次数*2+开行方案中的区间数*2
%Individual=TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan*2;
%% 输出
%TotalTracEnergyAfterReg:整个牵引网真正要用的电能（网侧牵引能耗-被利用的再生制动能量），单位，kj
%TotalBrakEnergyAfterReg:整个牵引网仍会被浪费的再生制动能量，单位，kj
%TotalTracE_NoReg:一点再生制动能量不被利用的情况下的整个牵引网需要用的电能，单位，kj
%TotalTracE_NoReg：没有被利用的整个牵引网的再生制动能量，单位，kj
%Power_Time_Trac_sum：不考虑再生制动功率被利用情况下的整个牵引网的牵引功率-时间分部矩阵，单位，kw
%Power_Time_Brak_sum：不考虑再生制动功率被利用情况下的整个牵引网的再生制动功率-时间分部矩阵，单位，kw
%Power_Time_TracAfterReg：考虑再生制动功率被利用后的整个牵引网的牵引功率-时间分部矩阵，单位，kw
%Power_Time_BrakAfterRegL:考虑再生制动功率被利用后的整个牵引网的剩余未被利用再生制动功率-时间分部矩阵，单位，kw
%Fitness:适应度=能耗+f_travel*|RealTravelTime-SetTravelTime|+f_service*|RealServiceTime-SetServiceTime|
%%
% global SupplySectionNum;%分相数
% global TrainNum;%列车数
% global StationNum;%车站数
% global Num_StopPlan;%停站方案种类
% global f_travel;
% global f_service;
% global f_safety;
% %上下行列车最短运行时间约束
% global MaxTotalTravelTimeDown;
% global MinTotalTravelTimeDown;
% global MaxTotalTravelTimeUp;
% global MinTotalTravelTimeUp;
% 
% global ServiceTimeConstrant;%铁路服务时间
% global OperationScheme;%开行方案，行代表不同的开行方案，列代表车站，1表示停，0表示不停
% global OptimizationData;%单车优化数据库
% global MaxTotalSectionTimeEachPlanDown%下行每种停站方案理论可达到的最长区间运行时间（不包括停站时间）
% global MaxTotalSectionTimeEachPlanUp%上行每种停站方案理论可达到的最长区间运行时间（不包括停站时间）
% global MaxTotalDwellTimeEachPlan%每种停站方案理论可达到的最长停站时间
% global TotalStopTimes;%单行别总停站次数
% global TotalSections;%单行别总区间数
% global P_auxi;
% global StartStation;
% global EndStation;
%% 输入参数预处理
Headway_Down=Individual(1,1:TrainNum);
Headway_Up=Individual(1,TrainNum+1:TrainNum*2);
DwellTimes_Down=Individual(TrainNum*2+1:TrainNum*2+TotalStopTimes);
DwellTimes_Up=Individual(TrainNum*2+TotalStopTimes+1:TrainNum*2+TotalStopTimes*2);
IntervalTimes_Down=Individual(TrainNum*2+TotalStopTimes*2+1:TrainNum*2+TotalStopTimes*2+TotalSections);
IntervalTimes_Up=Individual(TrainNum*2+TotalStopTimes*2+TotalSections+1:TrainNum*2+TotalStopTimes*2+TotalSections*2);
Plan_Down=Individual(TrainNum*2+TotalStopTimes*2+TotalSections*2+1:TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan);
Plan_Up=Individual(TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan+1:TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan*2);

%% 控制变量预处理
%% 停站时间
%停站时间矩阵，行代表每个停站方案，列代表每个车站
DwellTimeMatDown=zeros(Num_StopPlan,StationNum);
DwellTimeMatUp=zeros(Num_StopPlan,StationNum);

 if length(DwellTimes_Down)==TotalStopTimes & length(DwellTimes_Up)==TotalStopTimes
    index=0;
    for i=1:1:Num_StopPlan
        for j=1:1:StationNum
            if OperationScheme(i,j)==1 
                index=index+1;
                DwellTimeMatDown(i,j)=DwellTimes_Down(1,index);
                DwellTimeMatUp(i,j)=DwellTimes_Up(1,index);
            end
        end
    end
else
    disp('代表停站时间的基因数量错误')
    return
end

%% 区间运行时间
%区间运行时间元胞数组{1，i}表示第i种停站方案{1，i}(x,y)表示第i种方案，从第x站到第y站的运行时间索引

IntervalTimesCell=cell(1,Num_StopPlan);
 if TotalSections==length(IntervalTimes_Down) & TotalSections==length(IntervalTimes_Up)
    index=0;
    for i=1:1:Num_StopPlan
        StopPlan=OperationScheme(i,:);%本趟车的停站方案
        StopStation=find(StopPlan==1);%停站车站
        StopNum=length(StopStation);%停站次数
        SectionTimeIndex=zeros(StationNum,StationNum);
        for j=1:1:StopNum-1
            index=index+1;
            SectionTimeIndex(StopStation(1,j),StopStation(1,j+1))=IntervalTimes_Down(1,index);
            SectionTimeIndex(StopStation(1,j+1),StopStation(1,j))=IntervalTimes_Up(1,index);
        end
       IntervalTimesCell{1,i}=SectionTimeIndex;
    end
else
  disp('代表区间运行时间的基因数量错误')
  return
end
%% 功率-时间-车次矩阵、公里标-时间-车次矩阵生成
%% 初始化
% 矩阵的最大可能维度
TimeLength=max(sum(Individual(1,1:TrainNum)),sum(Individual(1,TrainNum+1:TrainNum*2)))+max(max(MaxTotalSectionTimeEachPlanDown+MaxTotalDwellTimeEachPlan),max(MaxTotalSectionTimeEachPlanUp+MaxTotalDwellTimeEachPlan));  
TimeLength=ceil(TimeLength/1000)*1000;

Power_Time=zeros(TrainNum*2,TimeLength);
Section_Time=zeros(TrainNum*2,TimeLength);
Velocity_Time=zeros(TrainNum*2,TimeLength);
GLB_Time=zeros(TrainNum*2,TimeLength);
%旅行时间偏差矩阵
TravelTimeDeviation=zeros(1,TrainNum*2);
ServerTimeDeviation=zeros(1,2);%(1,1)是下行，（1，2）是上行
% 所有列车总运行时间
TotalOperationTime=0;
%% 下行
for i=1:1:TrainNum
    plan=Plan_Down;
    Headway=Headway_Down;
    DwellTimeMat=DwellTimeMatDown;
    
    plan_index=mod(i,Num_StopPlan);
    if plan_index==0
        plan_index=Num_StopPlan;
    end
    StopPlanNum=plan(1,plan_index);%第几种停站方案
    
    StopPlan=OperationScheme(StopPlanNum,:);%本趟车的停站方案矩阵
    StopStation=find(StopPlan==1);%停站车站号，第1个车站和最后一个车站也包括在内
    StopNum=length(StopStation);%停站次数
    SectionNum=StopNum-1;%区间数
    headway=sum(Headway(1,1:i));%本趟车的发车时间,Headway中第一辆车的发车间隔也加了
 
    d=headway;
    for j=1:1:SectionNum 
        IndexofSectionRunTime=IntervalTimesCell{1,StopPlanNum}(StopStation(1,j),StopStation(1,j+1));    
        OptimizeData=OptimizationData{StopStation(1,j),StopStation(1,j+1)}{1,IndexofSectionRunTime};
        Time=OptimizeData(:,1)';
        GLB=OptimizeData(:,2)';
        Velocity=(OptimizeData(:,3)'<0).*(0)+(OptimizeData(:,3)'>=0).*(OptimizeData(:,3)');
        Power=OptimizeData(:,5)';
        Section=OptimizeData(:,6)';
        TimeMat=Time+round(d);%相对时间+出发时刻=真实时间矩阵
        
        % 安全检查：确保数组长度匹配
        expected_length = TimeMat(1,end) - TimeMat(1,1) + 1;
        actual_length = length(Power);
        
        if actual_length ~= expected_length
            % 如果长度不匹配，调整数据长度
            if actual_length > expected_length
                % 截取数据
                Power = Power(1:expected_length);
                Velocity = Velocity(1:expected_length);
                GLB = GLB(1:expected_length);
                Section = Section(1:expected_length);
            else
                % 扩展数据（重复最后一个值）
                Power = [Power, repmat(Power(end), 1, expected_length - actual_length)];
                Velocity = [Velocity, repmat(Velocity(end), 1, expected_length - actual_length)];
                GLB = [GLB, repmat(GLB(end), 1, expected_length - actual_length)];
                Section = [Section, repmat(Section(end), 1, expected_length - actual_length)];
            end
        end
%         disp(' ')
%         disp(round(d))
%         disp(Time(1,1)+1)
%         disp(TimeMat(1,1)+1)
%         disp(TimeMat(1,end)+1)
%         disp(' ')
        Power_Time(i,TimeMat(1,1)+1:TimeMat(1,end)+1)=Power;
        Velocity_Time(i,TimeMat(1,1)+1:TimeMat(1,end)+1)=Velocity;
        GLB_Time(i,TimeMat(1,1)+1:TimeMat(1,end)+1)=GLB;
        Section_Time(i,TimeMat(1,1)+1:TimeMat(1,end)+1)=Section;
        d=TimeMat(1,end)+DwellTimeMat(StopPlanNum,StopStation(1,j+1));
 
        % 列车速度为0的时候其公里标与刚停车的时候的公里标一致，需要对其赋值
        GLB_Time(i,TimeMat(1,end)+2:round(d))=round(GLB_Time(i,TimeMat(1,end)+1));
        Section_Time(i,TimeMat(1,end)+2:round(d))=Section_Time(i,TimeMat(1,end)+1);
        if j==1
            TravelStartTime=TimeMat(1,1);
             GLB_Time(i,1:TimeMat(1,1))=round(GLB_Time(i,TimeMat(1,1)+1));
        end
        if j==SectionNum
           GLB_Time(i,TimeMat(1,end)+2:end)=round(GLB_Time(i,TimeMat(1,end)+1)); 
           TravelEndTime=TimeMat(1,end);
        end
    end
    %单辆列车的旅行时间偏差
    RealTravelTime=abs(TravelEndTime-TravelStartTime);
    if RealTravelTime>MaxTotalTravelTimeDown(1,StopPlanNum)
        TravelTimeDeviation(1,i)=RealTravelTime-MaxTotalTravelTimeDown(1,StopPlanNum);
    elseif RealTravelTime<MinTotalTravelTimeDown(1,StopPlanNum)
        TravelTimeDeviation(1,i)=MinTotalTravelTimeDown(1,StopPlanNum)-RealTravelTime;
    else
        TravelTimeDeviation(1,i)=0;
    end
    % 铁路总服务时间
    endTime=0;
    if TravelEndTime>endTime
        endTime=TravelEndTime;
    end
    if abs(endTime-ServiceTimeConstrant)>600
        ServerTimeDeviation(1,1)=abs(endTime-ServiceTimeConstrant);
    else
        ServerTimeDeviation(1,1)=0;
    end
    %所有车总运行时间
    TotalOperationTime=TotalOperationTime+RealTravelTime;
end

%% 上行
for i=1:1:TrainNum  
    plan=Plan_Up;
    Headway=Headway_Up;
    DwellTimeMat=DwellTimeMatUp;
    plan_index=mod(i,Num_StopPlan);
    if plan_index==0
        plan_index=Num_StopPlan;
    end
    StopPlanNum=plan(1,plan_index);%第几种停站方案
    
    StopPlan=OperationScheme(StopPlanNum,:);%本趟车的停站方案矩阵
    StopStation=find(StopPlan==1);%停站车站号，第1个车站和最后一个车站也包括在内
    StopStation=fliplr(StopStation);%左右颠倒
    StopNum=length(StopStation);%停站次数
    SectionNum=StopNum-1;%区间数
    headway=sum(Headway(1,1:i));%本趟车的发车时间,Headway中第一辆车的发车间隔也加了
 
    d=headway;
    for j=1:1:SectionNum 
        IndexofSectionRunTime=IntervalTimesCell{1,StopPlanNum}(StopStation(1,j),StopStation(1,j+1));
        OptimizeData=OptimizationData{StopStation(1,j),StopStation(1,j+1)}{1,IndexofSectionRunTime};
        Time=OptimizeData(:,1)';
        GLB=OptimizeData(:,2)';
        Velocity=(OptimizeData(:,3)'<0).*(0)+(OptimizeData(:,3)'>=0).*(OptimizeData(:,3)');
        Power=OptimizeData(:,5)';
        Section=OptimizeData(:,6)';
        TimeMat=Time+round(d);%相对时间+出发时刻=真实时间矩阵
        
        % 安全检查：确保数组长度匹配
        expected_length = TimeMat(1,end) - TimeMat(1,1) + 1;
        actual_length = length(Power);
        
        if actual_length ~= expected_length
            % 如果长度不匹配，调整数据长度
            if actual_length > expected_length
                % 截取数据
                Power = Power(1:expected_length);
                Velocity = Velocity(1:expected_length);
                GLB = GLB(1:expected_length);
                Section = Section(1:expected_length);
            else
                % 扩展数据（重复最后一个值）
                Power = [Power, repmat(Power(end), 1, expected_length - actual_length)];
                Velocity = [Velocity, repmat(Velocity(end), 1, expected_length - actual_length)];
                GLB = [GLB, repmat(GLB(end), 1, expected_length - actual_length)];
                Section = [Section, repmat(Section(end), 1, expected_length - actual_length)];
            end
        end
        
        Power_Time(TrainNum+i,TimeMat(1,1)+1:TimeMat(1,end)+1)=Power;
        Velocity_Time(TrainNum+i,TimeMat(1,1)+1:TimeMat(1,end)+1)=Velocity;
        GLB_Time(TrainNum+i,TimeMat(1,1)+1:TimeMat(1,end)+1)=GLB;
        Section_Time(TrainNum+i,TimeMat(1,1)+1:TimeMat(1,end)+1)=Section;
        d=TimeMat(1,end)+DwellTimeMat(StopPlanNum,StopStation(1,j+1));
       
        % 列车速度为0的时候其公里标与刚停车的时候的公里标一致，需要对其赋值
        GLB_Time(TrainNum+i,TimeMat(1,end)+2:round(d))=round(GLB_Time(TrainNum+i,TimeMat(1,end)+1));
        Section_Time(TrainNum+i,TimeMat(1,end)+2:round(d))=Section_Time(TrainNum+i,TimeMat(1,end)+1);
        if j==1
            GLB_Time(TrainNum+i,1:TimeMat(1,1))=round(GLB_Time(TrainNum+i,TimeMat(1,1)+1));
            TravelStartTime=TimeMat(1,1);
        end
        if j==SectionNum
            GLB_Time(TrainNum+i,TimeMat(1,end)+2:end)=round(GLB_Time(TrainNum+i,TimeMat(1,end)+1));
            TravelEndTime=TimeMat(1,end);
        end
    end
    
    %单辆列车的旅行时间偏差
    RealTravelTime=abs(TravelEndTime-TravelStartTime);
    if RealTravelTime>MaxTotalTravelTimeUp(1,StopPlanNum)
        TravelTimeDeviation(1,TrainNum+i)=RealTravelTime-MaxTotalTravelTimeUp(1,StopPlanNum);
    elseif RealTravelTime<MinTotalTravelTimeUp(1,StopPlanNum)
        TravelTimeDeviation(1,TrainNum+i)=MinTotalTravelTimeUp(1,StopPlanNum)-RealTravelTime;
    else
        TravelTimeDeviation(1,TrainNum+i)=0;
    end
    % 铁路总服务时间
    if TravelEndTime>endTime
        endTime=TravelEndTime;
    end
    if abs(endTime-ServiceTimeConstrant)>600
        ServerTimeDeviation(1,2)=abs(endTime-ServiceTimeConstrant);
    else
        ServerTimeDeviation(1,2)=0;
    end
    %所有车总运行时间
    TotalOperationTime=TotalOperationTime+RealTravelTime;
end
%% 对整个功率矩阵加上辅助功率
Power_Time=(GLB_Time<EndStation & GLB_Time>StartStation).*(Power_Time+P_auxi)+ (GLB_Time>=EndStation & GLB_Time<=StartStation).*(Power_Time);


%% 前后车距离矩阵计算以及移动闭塞距离计算
%% 1.首先对公里标矩阵的每一列进行排序，下行的升序排列，上行的降序排列；然后把速度矩阵按照相同的排列顺序进行排列
GLB_Time_NoSort=GLB_Time;%备份
Velocity_Time_NoSort=Velocity_Time;

[GLB_Time(1:TrainNum,:),Index_Down]=sort(GLB_Time(1:TrainNum,:),1);
for i=1:1:length(GLB_Time)
    Velocity_Time(1:TrainNum,i)=Velocity_Time(Index_Down(:,i),i);
end

[GLB_Time(TrainNum+1:TrainNum*2,:),Index_Up]=sort(GLB_Time(TrainNum+1:2*TrainNum,:),1,'descend');
for i=1:1:length(GLB_Time)
    Velocity_Time(TrainNum+1:2*TrainNum,i)=Velocity_Time(Index_Up(:,i)+TrainNum,i);
end
%% 2. 然后进行前后车距离矩阵计算以及移动闭塞距离计算
%最大制动减速度矩阵-单位，m/s2
Velocity_Time_K=Velocity_Time.*3.6;%变成km/h
MaxDeceleration=(Velocity_Time_K>=0 & Velocity_Time_K<=70).*(0.3735)+(Velocity_Time_K>70 & Velocity_Time_K<=80).*(-0.00135.*Velocity_Time_K+0.468)+(Velocity_Time_K>80 & Velocity_Time_K<=118).*(0.0009974.*Velocity_Time_K+0.2802)+(Velocity_Time_K>118).*(-0.0009957.*Velocity_Time_K+0.5154);
% clear Velocity_Time_K
%最短制动距离-与速度有关
MinBrakeDistance=Velocity_Time.^2./(2.*abs(MaxDeceleration));%单位，m
% clear MaxDeceleration
MinBrakeDistance=(MinBrakeDistance>3000).*(3000) + (MinBrakeDistance<=3000).*(MinBrakeDistance);

% 如果前一辆车速度为0，则意味着其已经停车，那么移动闭塞距离也可以是0
Velocity_Time_Down=Velocity_Time(1:TrainNum-1,:);
Velocity_Time_Up=Velocity_Time(TrainNum+1:2*TrainNum-1,:);
Velocity_Time_Down=[zeros(1,TimeLength);Velocity_Time_Down];
Velocity_Time_Up=[zeros(1,TimeLength);Velocity_Time_Up];
Velocity_Time_Last=[Velocity_Time_Down;Velocity_Time_Up];
MinBrakeDistance=(Velocity_Time_Last==0).*(0)+(Velocity_Time_Last~=0).*(MinBrakeDistance);

%每辆车实际距离前车距离
GLB_Time_For_LastTrainDown=GLB_Time(1:TrainNum-1,:);
GLB_Time_For_LastTrainUp=GLB_Time(TrainNum+1:2*TrainNum-1,:);
GLB_Time_For_LastTrainDown=[1e16*ones(1,TimeLength); GLB_Time_For_LastTrainDown];
GLB_Time_For_LastTrainUp=[-1e16*ones(1,TimeLength); GLB_Time_For_LastTrainUp];
GLB_Time_For_LastTrain=zeros(TrainNum*2,TimeLength);
GLB_Time_For_LastTrain(1:TrainNum,:)=GLB_Time_For_LastTrainDown;
GLB_Time_For_LastTrain(TrainNum+1:2*TrainNum,:)=GLB_Time_For_LastTrainUp;
% Distance= GLB_Time_For_LastTrain-GLB_Time;
% Distance(TrainNum+1:2*TrainNum,:)=-Distance(TrainNum+1:2*TrainNum,:);
% clear GLB_Time_For_LastTrainDown GLB_Time_For_LastTrainUp GLB_Time_For_LastTrain
Distance= abs(GLB_Time_For_LastTrain-GLB_Time);
% clear GLB_Time_For_LastTrainDown GLB_Time_For_LastTrainUp GLB_Time_For_LastTrain

% 判断距离是否合法
IFSaftyDistance=Distance-MinBrakeDistance;
% clear MinBrakeDistance

NoSaftyDistance=(IFSaftyDistance<0).*(IFSaftyDistance);
% clear IFSaftyDistance

SaftyDistancePunc=-sum(sum(NoSaftyDistance));
%clear NoSaftyDistance
%% 能耗与功率-时间矩阵计算
Power_Time_EachSection_sum=zeros(SupplySectionNum+1,TimeLength);%每一行是每个供电段的时间-功率曲线
Power_Time_EachSection_TracAfterReg=zeros(SupplySectionNum+1,TimeLength);%每一行是每个供电段的时间-功率曲线
Power_Time_EachSection_BrakAfterReg=zeros(SupplySectionNum+1,TimeLength);%每一行是每个供电段的时间-功率曲线

Power_Time_EachSection_TracNoReg=zeros(SupplySectionNum+1,TimeLength);%每一行是每个供电段的时间-功率曲线
Power_Time_EachSection_BrakNoReg=zeros(SupplySectionNum+1,TimeLength);%每一行是每个供电段的时间-功率曲线

for i=0:1:SupplySectionNum
    %% 再生制动的利用前
    Power_Time_CertainSection=(Section_Time==i).*(Power_Time);%每个供电区段的功率时间车次矩阵
    Power_Time_CertainSection_TracNoReg=sum((Power_Time_CertainSection>=0).*(Power_Time_CertainSection));%每个供电区段的再生制动未利用的牵引+辅助功率
    Power_Time_CertainSection_BrakNoReg=sum((Power_Time_CertainSection<0).*(Power_Time_CertainSection));%每个供电区段的再生制动未利用的-制动功率+辅助功率
    
    %保存到总矩阵中
    Power_Time_EachSection_TracNoReg(i+1,:)=Power_Time_CertainSection_TracNoReg;
    Power_Time_EachSection_BrakNoReg(i+1,:)=Power_Time_CertainSection_BrakNoReg;
    %% 再生制动的利用
    Power_Time_CertainSection_Sum=sum(Power_Time_CertainSection);%把每辆车的功率累加起来-形成功率-时间矩阵，再生制动能量在这个过程中被其他车利用
    %% 再生制动利用后
    Power_Time_CertainSection_TracAfterReg=(Power_Time_CertainSection_Sum>=0).*(Power_Time_CertainSection_Sum);%每个供电区段的再生制动利用完之后的牵引+辅助功率
    Power_Time_CertainSection_BrakAfterReg=(Power_Time_CertainSection_Sum<0).*(Power_Time_CertainSection_Sum);%每个供电区段的再生制动利用完之后的-制动功率+辅助功率
    
    %保存到总矩阵中
    Power_Time_EachSection_sum(i+1,:)=Power_Time_CertainSection_Sum;
    Power_Time_EachSection_TracAfterReg(i+1,:)=Power_Time_CertainSection_TracAfterReg;
    Power_Time_EachSection_BrakAfterReg(i+1,:)=Power_Time_CertainSection_BrakAfterReg;
end

%% 从每个牵引变电所的角度取统计功率
SubStaionNum=ceil(SupplySectionNum/2);

%再生制动利用前
Power_Time_EachSubStaionNum_TracNoReg=zeros(SubStaionNum,TimeLength);
Power_Time_EachSubStation_BrakNoReg=zeros(SubStaionNum,TimeLength);
for i=1:1:SubStaionNum
    Power_Time_EachSubStaionNum_TracNoReg(i,:)=Power_Time_EachSection_TracNoReg(2*i,:)+Power_Time_EachSection_TracNoReg(2*i+1,:);
    Power_Time_EachSubStation_BrakNoReg(i,:)=Power_Time_EachSection_BrakNoReg(2*i,:)+Power_Time_EachSection_BrakNoReg(2*i+1,:); 
end

%再生制动利用后
Power_Time_EachSubStaionNum_TracAfterReg=zeros(SubStaionNum,TimeLength);
Power_Time_EachSubStation_BrakAfterReg=zeros(SubStaionNum,TimeLength);
for i=1:1:SubStaionNum
    Power_Time_EachSubStaionNum_TracAfterReg(i,:)=Power_Time_EachSection_TracAfterReg(2*i,:)+Power_Time_EachSection_TracAfterReg(2*i+1,:);
    Power_Time_EachSubStation_BrakAfterReg(i,:)=Power_Time_EachSection_BrakAfterReg(2*i,:)+Power_Time_EachSection_BrakAfterReg(2*i+1,:); 
end

%% 整个牵引网角度的功率统计功率

%再生制动利用前
Power_Time_TracNoReg=sum(Power_Time_EachSection_TracNoReg(2:9,:));%整个牵引网的再生制动利用完之后的牵引+辅助功率
Power_Time_BrakNoReg=sum(Power_Time_EachSection_BrakNoReg(2:9,:));%整个牵引网的再生制动利用完之后的-制动功率+辅助功率

%再生制动利用后
Power_Time_TracAfterReg=sum(Power_Time_EachSection_TracAfterReg(2:9,:));%整个牵引网的再生制动利用完之后的牵引+辅助功率
Power_Time_BrakAfterReg=sum(Power_Time_EachSection_BrakAfterReg(2:9,:));%整个牵引网的再生制动利用完之后的-制动功率+辅助功率


%% 牵引网角度能耗
%对整个牵引网的功率-时间矩阵进行时间上累加，得到整个牵引网真正要用的电能（网侧牵引能耗-被利用的再生制动能量）
%对整个牵引网的剩余再生制动-时间矩阵进行时间上累加，得到整个牵引网仍会被浪费的再生制动能量
%因此整个系统的再生制动能量的流向有两部分1.自己车和其他车的辅助能耗 2.其他车的牵引能耗
%因此理论上再生制动能量减少量=（整个系统的牵引能耗+辅助能耗的减少量）
%（TotalBrakE_NoReg-TotalBrakEnergyAfterReg）=（TotalTracE_NoReg+TotalAuxiE_NoReg）-（TotalUsedEnergyAfterReg）
TotalUsedEnergyAfterReg=(sum(Power_Time_TracAfterReg(1:TimeLength-1))+sum(Power_Time_TracAfterReg(2:TimeLength)))/2/3600;%整个牵引网真正要用的能耗
TotalBrakEnergyAfterReg=(sum(Power_Time_BrakAfterReg(1:TimeLength-1))+sum(Power_Time_BrakAfterReg(2:TimeLength)))/2/3600;%整个牵引网浪费的制动能量
%% 每个变电站的总能耗
TotalUsedEnergyAfterReg_EachSubstation=zeros(SubStaionNum,1);
TotalBrakEnergyAfterReg_EachSubstation=zeros(SubStaionNum,1);
for i=1:1:SubStaionNum
    TotalUsedEnergyAfterReg_EachSubstation(i,1)=(sum(Power_Time_EachSubStaionNum_TracAfterReg(i,1:TimeLength-1))+sum(Power_Time_EachSubStaionNum_TracAfterReg(i,2:TimeLength)))/2/3600;
    TotalBrakEnergyAfterReg_EachSubstation(i,1)=(sum(Power_Time_EachSubStation_BrakAfterReg(i,1:TimeLength-1))+sum(Power_Time_EachSubStation_BrakAfterReg(i,2:TimeLength)))/2/3600;
end
%% 电费计算
c_buy=(1.252+0.782+0.370)/3;
c_fed=c_buy;
c_dem=42;
P_max=zeros(SubStaionNum,1);
P_mean=zeros(SubStaionNum,1);
for j=1:1:SubStaionNum
    for i=1:1:TimeLength-899
        P_mean(j,1)=sum(Power_Time_EachSubStaionNum_TracAfterReg(j,i:i+899))/900;
        if P_mean(j,1)>P_max(j,1)
            P_max(j,1)=P_mean(j,1);
        end
    end
end
% Cost_net=(TotalUsedEnergyAfterReg*c_buy+TotalBrakEnergyAfterReg*c_fed)/endTime*1440*60;
% Cost_dem=P_max*c_dem/30;
% Cost=Cost_net+Cost_dem;
Cost_net=(sum(TotalUsedEnergyAfterReg_EachSubstation*c_buy)+sum(TotalBrakEnergyAfterReg_EachSubstation*c_fed))*3;
Cost_dem=sum(P_max*c_dem)/30;
Cost=Cost_net+Cost_dem;
%% 适应度计算
Fitness=Cost+f_travel*sum(TravelTimeDeviation,2)+f_service*max(ServerTimeDeviation)+f_safety*SaftyDistancePunc;
end

