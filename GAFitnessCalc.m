function [GLB_Time_NoSort,Fitness,Cost,C_grid,C_dem,C_total,Cost_grid,Cost_dem,Power_Time_EachSubStaionNum_AfterReg,Power_Time_EachSubStaionNum_TracAfterReg,Power_Time_EachSubStation_BrakAfterReg]= GAFitnessCalc(Individual)
%[GLB_Time,Velocity_Time,MinBrakeDistance,Distance,IFSaftyDistance,NoSaftyDistance,SaftyDistancePunc]= GAFitnessCalc(Individual)
%[Fitness,GLB_Time,TotalTracE_NoReg,TotalAuxiE_NoReg,TotalUsedEnergyAfterReg,TotalBrakE_NoReg,TotalBrakEnergyAfterReg,TotalTracEAfterAux_NoReg,TotalBrakEAfterAux_NoReg,Power_Time_Trac_sum,Power_Time_Brak_sum,Power_Time_TracAfterAux_sum,Power_Time_BrakAfterAux_sum,Power_Time_TracAfterReg,Power_Time_BrakAfterReg]= GAFitnessCalc(Individual)
%% ����
%Individual,һ������
%% ���
%TotalTracEnergyAfterReg:����ǣ��������Ҫ�õĵ��ܣ�����ǣ���ܺ�-�����õ������ƶ�����������λ��kj
%TotalBrakEnergyAfterReg:����ǣ�����Իᱻ�˷ѵ������ƶ���������λ��kj
%TotalTracE_NoReg:һ�������ƶ������������õ�����µ�����ǣ������Ҫ�õĵ��ܣ���λ��kj
%TotalTracE_NoReg��û�б����õ�����ǣ�����������ƶ���������λ��kj
%Power_Time_Trac_sum�������������ƶ����ʱ���������µ�����ǣ������ǣ������-ʱ��ֲ����󣬵�λ��kw
%Power_Time_Brak_sum�������������ƶ����ʱ���������µ�����ǣ�����������ƶ�����-ʱ��ֲ����󣬵�λ��kw
%Power_Time_TracAfterReg�����������ƶ����ʱ����ú������ǣ������ǣ������-ʱ��ֲ����󣬵�λ��kw
%Power_Time_BrakAfterRegL:���������ƶ����ʱ����ú������ǣ������ʣ��δ�����������ƶ�����-ʱ��ֲ����󣬵�λ��kw
%Fitness:��Ӧ��=�ܺ�+f_travel*|RealTravelTime-SetTravelTime|+f_service*|RealServiceTime-SetServiceTime|
%%
global SupplySectionNum;%������
global TrainNum;%�г���
global StationNum;%��վ��
global Num_StopPlan;%ͣվ��������
global f_travel;
global f_service;
global f_safety;
%�������г��������ʱ��Լ��
global MaxTotalTravelTimeDown;
global MinTotalTravelTimeDown;
global MaxTotalTravelTimeUp;
global MinTotalTravelTimeUp;

global ServiceTimeConstrant;%��·����ʱ��
global OperationScheme;%���з������д���ͬ�Ŀ��з������д���վ��1��ʾͣ��0��ʾ��ͣ
global OptimizationData;%�����Ż����ݿ�
global MaxTotalSectionTimeEachPlanDown%����ÿ��ͣվ�������ۿɴﵽ�����������ʱ�䣨������ͣվʱ�䣩
global MaxTotalSectionTimeEachPlanUp%����ÿ��ͣվ�������ۿɴﵽ�����������ʱ�䣨������ͣվʱ�䣩
global MaxTotalDwellTimeEachPlan%ÿ��ͣվ�������ۿɴﵽ���ͣվʱ��
global TotalStopTimes;%���б���ͣվ����
global TotalSections;%���б���������
global P_auxi;
global StartStation;
global EndStation;
%% �������Ԥ����
Headway_Down=Individual(1,1:TrainNum);
Headway_Up=Individual(1,TrainNum+1:TrainNum*2);
DwellTimes_Down=Individual(TrainNum*2+1:TrainNum*2+TotalStopTimes);
DwellTimes_Up=Individual(TrainNum*2+TotalStopTimes+1:TrainNum*2+TotalStopTimes*2);
IntervalTimes_Down=Individual(TrainNum*2+TotalStopTimes*2+1:TrainNum*2+TotalStopTimes*2+TotalSections);
IntervalTimes_Up=Individual(TrainNum*2+TotalStopTimes*2+TotalSections+1:TrainNum*2+TotalStopTimes*2+TotalSections*2);
Plan_Down=Individual(TrainNum*2+TotalStopTimes*2+TotalSections*2+1:TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan);
Plan_Up=Individual(TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan+1:TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan*2);

%% ���Ʊ���Ԥ����
%% ͣվʱ��
%ͣվʱ������д���ÿ��ͣվ�������д���ÿ����վ
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
    disp('����ͣվʱ��Ļ�����������')
    return
end

%% ��������ʱ��
%��������ʱ��Ԫ������{1��i}��ʾ��i��ͣվ����{1��i}(x,y)��ʾ��i�ַ������ӵ�xվ����yվ������ʱ������

IntervalTimesCell=cell(1,Num_StopPlan);
 if TotalSections==length(IntervalTimes_Down) & TotalSections==length(IntervalTimes_Up)
    index=0;
    for i=1:1:Num_StopPlan
        StopPlan=OperationScheme(i,:);%���˳���ͣվ����
        StopStation=find(StopPlan==1);%ͣվ��վ
        StopNum=length(StopStation);%ͣվ����
        SectionTimeIndex=zeros(StationNum,StationNum);
        for j=1:1:StopNum-1
            index=index+1;
            SectionTimeIndex(StopStation(1,j),StopStation(1,j+1))=IntervalTimes_Down(1,index);
            SectionTimeIndex(StopStation(1,j+1),StopStation(1,j))=IntervalTimes_Up(1,index);
        end
       IntervalTimesCell{1,i}=SectionTimeIndex;
    end
else
  disp('������������ʱ��Ļ�����������')
  return
end
%% ����-ʱ��-���ξ��󡢹����-ʱ��-���ξ�������
%% ��ʼ��
% �����������ά��
TimeLength=max(sum(Individual(1,1:TrainNum)),sum(Individual(1,TrainNum+1:TrainNum*2)))+max(max(MaxTotalSectionTimeEachPlanDown+MaxTotalDwellTimeEachPlan),max(MaxTotalSectionTimeEachPlanUp+MaxTotalDwellTimeEachPlan));  
TimeLength=ceil(TimeLength/1000)*1000;

Power_Time=zeros(TrainNum*2,TimeLength);
Section_Time=zeros(TrainNum*2,TimeLength);
Velocity_Time=zeros(TrainNum*2,TimeLength);
GLB_Time=zeros(TrainNum*2,TimeLength);
%����ʱ��ƫ�����
TravelTimeDeviation=zeros(1,TrainNum*2);
ServerTimeDeviation=zeros(1,2);%(1,1)�����У���1��2��������
% �����г�������ʱ��
TotalOperationTime=0;
%% ����
for i=1:1:TrainNum
    plan=Plan_Down;
    Headway=Headway_Down;
    DwellTimeMat=DwellTimeMatDown;
    
    plan_index=mod(i,Num_StopPlan);
    if plan_index==0
        plan_index=Num_StopPlan;
    end
    StopPlanNum=plan(1,plan_index);%�ڼ���ͣվ����
    
    StopPlan=OperationScheme(StopPlanNum,:);%���˳���ͣվ��������
    StopStation=find(StopPlan==1);%ͣվ��վ�ţ���1����վ�����һ����վҲ��������
    StopNum=length(StopStation);%ͣվ����
    SectionNum=StopNum-1;%������
    headway=sum(Headway(1,1:i));%���˳��ķ���ʱ��,Headway�е�һ�����ķ������Ҳ����
 
    d=headway;
    for j=1:1:SectionNum 
        IndexofSectionRunTime=IntervalTimesCell{1,StopPlanNum}(StopStation(1,j),StopStation(1,j+1));    
        OptimizeData=OptimizationData{StopStation(1,j),StopStation(1,j+1)}{1,IndexofSectionRunTime};
        Time=OptimizeData(:,1)';
        GLB=OptimizeData(:,2)';
        Velocity=(OptimizeData(:,3)'<0).*(0)+(OptimizeData(:,3)'>=0).*(OptimizeData(:,3)');
        Power=OptimizeData(:,5)';
        Section=OptimizeData(:,6)';
        TimeMat=Time+round(d);%���ʱ��+����ʱ��=��ʵʱ�����
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
 
        % �г��ٶ�Ϊ0��ʱ���乫������ͣ����ʱ��Ĺ����һ�£���Ҫ���丳ֵ
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
    %�����г�������ʱ��ƫ��
    RealTravelTime=abs(TravelEndTime-TravelStartTime);
    if RealTravelTime>MaxTotalTravelTimeDown(1,StopPlanNum)
        TravelTimeDeviation(1,i)=RealTravelTime-MaxTotalTravelTimeDown(1,StopPlanNum);
    elseif RealTravelTime<MinTotalTravelTimeDown(1,StopPlanNum)
        TravelTimeDeviation(1,i)=MinTotalTravelTimeDown(1,StopPlanNum)-RealTravelTime;
    else
        TravelTimeDeviation(1,i)=0;
    end
    % ��·�ܷ���ʱ��
    endTime=0;
    if TravelEndTime>endTime
        endTime=TravelEndTime;
    end
    if abs(endTime-ServiceTimeConstrant)>600
        ServerTimeDeviation(1,1)=abs(endTime-ServiceTimeConstrant);
    else
        ServerTimeDeviation(1,1)=0;
    end
    %���г�������ʱ��
    TotalOperationTime=TotalOperationTime+RealTravelTime;
end

%% ����
for i=1:1:TrainNum  
    plan=Plan_Up;
    Headway=Headway_Up;
    DwellTimeMat=DwellTimeMatUp;
    plan_index=mod(i,Num_StopPlan);
    if plan_index==0
        plan_index=Num_StopPlan;
    end
    StopPlanNum=plan(1,plan_index);%�ڼ���ͣվ����
    
    StopPlan=OperationScheme(StopPlanNum,:);%���˳���ͣվ��������
    StopStation=find(StopPlan==1);%ͣվ��վ�ţ���1����վ�����һ����վҲ��������
    StopStation=fliplr(StopStation);%���ҵߵ�
    StopNum=length(StopStation);%ͣվ����
    SectionNum=StopNum-1;%������
    headway=sum(Headway(1,1:i));%���˳��ķ���ʱ��,Headway�е�һ�����ķ������Ҳ����
 
    d=headway;
    for j=1:1:SectionNum 
        IndexofSectionRunTime=IntervalTimesCell{1,StopPlanNum}(StopStation(1,j),StopStation(1,j+1));
        OptimizeData=OptimizationData{StopStation(1,j),StopStation(1,j+1)}{1,IndexofSectionRunTime};
        Time=OptimizeData(:,1)';
        GLB=OptimizeData(:,2)';
        Velocity=(OptimizeData(:,3)'<0).*(0)+(OptimizeData(:,3)'>=0).*(OptimizeData(:,3)');
        Power=OptimizeData(:,5)';
        Section=OptimizeData(:,6)';
        TimeMat=Time+round(d);%���ʱ��+����ʱ��=��ʵʱ�����
        
        Power_Time(TrainNum+i,TimeMat(1,1)+1:TimeMat(1,end)+1)=Power;
        Velocity_Time(TrainNum+i,TimeMat(1,1)+1:TimeMat(1,end)+1)=Velocity;
        GLB_Time(TrainNum+i,TimeMat(1,1)+1:TimeMat(1,end)+1)=GLB;
        Section_Time(TrainNum+i,TimeMat(1,1)+1:TimeMat(1,end)+1)=Section;
        d=TimeMat(1,end)+DwellTimeMat(StopPlanNum,StopStation(1,j+1));
       
        % �г��ٶ�Ϊ0��ʱ���乫������ͣ����ʱ��Ĺ����һ�£���Ҫ���丳ֵ
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
    
    %�����г�������ʱ��ƫ��
    RealTravelTime=abs(TravelEndTime-TravelStartTime);
    if RealTravelTime>MaxTotalTravelTimeUp(1,StopPlanNum)
        TravelTimeDeviation(1,TrainNum+i)=RealTravelTime-MaxTotalTravelTimeUp(1,StopPlanNum);
    elseif RealTravelTime<MinTotalTravelTimeUp(1,StopPlanNum)
        TravelTimeDeviation(1,TrainNum+i)=MinTotalTravelTimeUp(1,StopPlanNum)-RealTravelTime;
    else
        TravelTimeDeviation(1,TrainNum+i)=0;
    end
    % ��·�ܷ���ʱ��
    if TravelEndTime>endTime
        endTime=TravelEndTime;
    end
    if abs(endTime-ServiceTimeConstrant)>600
        ServerTimeDeviation(1,2)=abs(endTime-ServiceTimeConstrant);
    else
        ServerTimeDeviation(1,2)=0;
    end
    %���г�������ʱ��
    TotalOperationTime=TotalOperationTime+RealTravelTime;
end
%% ���������ʾ�����ϸ�������
Power_Time=(GLB_Time<EndStation & GLB_Time>StartStation).*(Power_Time+P_auxi)+ (GLB_Time>=EndStation & GLB_Time<=StartStation).*(Power_Time);


%% ǰ�󳵾����������Լ��ƶ������������
%% 1.���ȶԹ��������ÿһ�н����������е��������У����еĽ������У�Ȼ����ٶȾ�������ͬ������˳���������
GLB_Time_NoSort=GLB_Time;%����
Velocity_Time_NoSort=Velocity_Time;

[GLB_Time(1:TrainNum,:),Index_Down]=sort(GLB_Time(1:TrainNum,:),1);
for i=1:1:length(GLB_Time)
    Velocity_Time(1:TrainNum,i)=Velocity_Time(Index_Down(:,i),i);
end

[GLB_Time(TrainNum+1:TrainNum*2,:),Index_Up]=sort(GLB_Time(TrainNum+1:2*TrainNum,:),1,'descend');
for i=1:1:length(GLB_Time)
    Velocity_Time(TrainNum+1:2*TrainNum,i)=Velocity_Time(Index_Up(:,i)+TrainNum,i);
end
%% 2. Ȼ�����ǰ�󳵾����������Լ��ƶ������������
%����ƶ����ٶȾ���-��λ��m/s2
Velocity_Time_K=Velocity_Time.*3.6;%���km/h
MaxDeceleration=(Velocity_Time_K>=0 & Velocity_Time_K<=70).*(0.3735)+(Velocity_Time_K>70 & Velocity_Time_K<=80).*(-0.00135.*Velocity_Time_K+0.468)+(Velocity_Time_K>80 & Velocity_Time_K<=118).*(0.0009974.*Velocity_Time_K+0.2802)+(Velocity_Time_K>118).*(-0.0009957.*Velocity_Time_K+0.5154);
% clear Velocity_Time_K
%����ƶ�����-���ٶ��й�
MinBrakeDistance=Velocity_Time.^2./(2.*abs(MaxDeceleration));%��λ��m
% clear MaxDeceleration
MinBrakeDistance=(MinBrakeDistance>3000).*(3000) + (MinBrakeDistance<=3000).*(MinBrakeDistance);

% ���ǰһ�����ٶ�Ϊ0������ζ�����Ѿ�ͣ������ô�ƶ���������Ҳ������0
Velocity_Time_Down=Velocity_Time(1:TrainNum-1,:);
Velocity_Time_Up=Velocity_Time(TrainNum+1:2*TrainNum-1,:);
Velocity_Time_Down=[zeros(1,TimeLength);Velocity_Time_Down];
Velocity_Time_Up=[zeros(1,TimeLength);Velocity_Time_Up];
Velocity_Time_Last=[Velocity_Time_Down;Velocity_Time_Up];
MinBrakeDistance=(Velocity_Time_Last==0).*(0)+(Velocity_Time_Last~=0).*(MinBrakeDistance);

%ÿ����ʵ�ʾ���ǰ������
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

% �жϾ����Ƿ�Ϸ�
IFSaftyDistance=Distance-MinBrakeDistance;
% clear MinBrakeDistance

NoSaftyDistance=(IFSaftyDistance<0).*(IFSaftyDistance);
% clear IFSaftyDistance

SaftyDistancePunc=-sum(sum(NoSaftyDistance));
%clear NoSaftyDistance
%% �ܺ��빦��-ʱ��������
Power_Time_EachSection_sum=zeros(SupplySectionNum+1,TimeLength);%ÿһ����ÿ������ε�ʱ��-��������
Power_Time_EachSection_TracAfterReg=zeros(SupplySectionNum+1,TimeLength);%ÿһ����ÿ������ε�ʱ��-��������
Power_Time_EachSection_BrakAfterReg=zeros(SupplySectionNum+1,TimeLength);%ÿһ����ÿ������ε�ʱ��-��������


Power_Time_EachSection_TracNoReg=zeros(SupplySectionNum+1,TimeLength);%ÿһ����ÿ������ε�ʱ��-��������
Power_Time_EachSection_BrakNoReg=zeros(SupplySectionNum+1,TimeLength);%ÿһ����ÿ������ε�ʱ��-��������

for i=0:1:SupplySectionNum
    %% �����ƶ�������ǰ
    Power_Time_CertainSection=(Section_Time==i).*(Power_Time);%ÿ���������εĹ���ʱ�䳵�ξ���
    Power_Time_CertainSection_TracNoReg=sum((Power_Time_CertainSection>=0).*(Power_Time_CertainSection));%ÿ���������ε������ƶ�δ���õ�ǣ��+��������
    Power_Time_CertainSection_BrakNoReg=sum((Power_Time_CertainSection<0).*(Power_Time_CertainSection));%ÿ���������ε������ƶ�δ���õ�-�ƶ�����+��������
    
    %���浽�ܾ�����
    Power_Time_EachSection_TracNoReg(i+1,:)=Power_Time_CertainSection_TracNoReg;
    Power_Time_EachSection_BrakNoReg(i+1,:)=Power_Time_CertainSection_BrakNoReg;
    %% �����ƶ�������
    Power_Time_CertainSection_Sum=sum(Power_Time_CertainSection);%��ÿ�����Ĺ����ۼ�����-�γɹ���-ʱ����������ƶ���������������б�����������
    %% �����ƶ����ú�
    Power_Time_CertainSection_TracAfterReg=(Power_Time_CertainSection_Sum>=0).*(Power_Time_CertainSection_Sum);%ÿ���������ε������ƶ�������֮���ǣ��+��������
    Power_Time_CertainSection_BrakAfterReg=(Power_Time_CertainSection_Sum<0).*(Power_Time_CertainSection_Sum);%ÿ���������ε������ƶ�������֮���-�ƶ�����+��������
    
    %���浽�ܾ�����
    Power_Time_EachSection_sum(i+1,:)=Power_Time_CertainSection_Sum;
    Power_Time_EachSection_TracAfterReg(i+1,:)=Power_Time_CertainSection_TracAfterReg;
    Power_Time_EachSection_BrakAfterReg(i+1,:)=Power_Time_CertainSection_BrakAfterReg;
end

%% ��ÿ��ǣ��������ĽǶ�ȡͳ�ƹ���
SubStaionNum=ceil(SupplySectionNum/2);

%�����ƶ�����ǰ
Power_Time_EachSubStaionNum_TracNoReg=zeros(SubStaionNum,TimeLength);
Power_Time_EachSubStation_BrakNoReg=zeros(SubStaionNum,TimeLength);
for i=1:1:SubStaionNum
    Power_Time_EachSubStaionNum_TracNoReg(i,:)=Power_Time_EachSection_TracNoReg(2*i,:)+Power_Time_EachSection_TracNoReg(2*i+1,:);
    Power_Time_EachSubStation_BrakNoReg(i,:)=Power_Time_EachSection_BrakNoReg(2*i,:)+Power_Time_EachSection_BrakNoReg(2*i+1,:); 
end

%�����ƶ����ú�
Power_Time_EachSubStaionNum_AfterReg=zeros(SubStaionNum,TimeLength);
Power_Time_EachSubStaionNum_TracAfterReg=zeros(SubStaionNum,TimeLength);
Power_Time_EachSubStation_BrakAfterReg=zeros(SubStaionNum,TimeLength);
for i=1:1:SubStaionNum
    Power_Time_EachSubStaionNum_AfterReg(i,:)=Power_Time_EachSection_sum(2*i,:)+Power_Time_EachSection_sum(2*i+1,:);
    Power_Time_EachSubStaionNum_TracAfterReg(i,:)=Power_Time_EachSection_TracAfterReg(2*i,:)+Power_Time_EachSection_TracAfterReg(2*i+1,:);
    Power_Time_EachSubStation_BrakAfterReg(i,:)=Power_Time_EachSection_BrakAfterReg(2*i,:)+Power_Time_EachSection_BrakAfterReg(2*i+1,:); 
end

%% ����ǣ�����ǶȵĹ���ͳ�ƹ���

%�����ƶ�����ǰ
Power_Time_TracNoReg=sum(Power_Time_EachSection_TracNoReg(2:9,:));%����ǣ�����������ƶ�������֮���ǣ��+��������
Power_Time_BrakNoReg=sum(Power_Time_EachSection_BrakNoReg(2:9,:));%����ǣ�����������ƶ�������֮���-�ƶ�����+��������

%�����ƶ����ú�
Power_Time_TracAfterReg=sum(Power_Time_EachSection_TracAfterReg(2:9,:));%����ǣ�����������ƶ�������֮���ǣ��+��������
Power_Time_BrakAfterReg=sum(Power_Time_EachSection_BrakAfterReg(2:9,:));%����ǣ�����������ƶ�������֮���-�ƶ�����+��������


%% ǣ�����Ƕ��ܺ�
%������ǣ�����Ĺ���-ʱ��������ʱ�����ۼӣ��õ�����ǣ��������Ҫ�õĵ��ܣ�����ǣ���ܺ�-�����õ������ƶ�������
%������ǣ������ʣ�������ƶ�-ʱ��������ʱ�����ۼӣ��õ�����ǣ�����Իᱻ�˷ѵ������ƶ�����
%�������ϵͳ�������ƶ�������������������1.�Լ������������ĸ����ܺ� 2.��������ǣ���ܺ�
%��������������ƶ�����������=������ϵͳ��ǣ���ܺ�+�����ܺĵļ�������
%��TotalBrakE_NoReg-TotalBrakEnergyAfterReg��=��TotalTracE_NoReg+TotalAuxiE_NoReg��-��TotalUsedEnergyAfterReg��
TotalUsedEnergyAfterReg=(sum(Power_Time_TracAfterReg(1:TimeLength-1))+sum(Power_Time_TracAfterReg(2:TimeLength)))/2/3600;%����ǣ��������Ҫ�õ��ܺ�
TotalBrakEnergyAfterReg=(sum(Power_Time_BrakAfterReg(1:TimeLength-1))+sum(Power_Time_BrakAfterReg(2:TimeLength)))/2/3600;%����ǣ�����˷ѵ��ƶ�����
%% ÿ�����վ�����ܺ�
TotalUsedEnergyAfterReg_EachSubstation=zeros(SubStaionNum,1);
TotalBrakEnergyAfterReg_EachSubstation=zeros(SubStaionNum,1);
for i=1:1:SubStaionNum
    TotalUsedEnergyAfterReg_EachSubstation(i,1)=(sum(Power_Time_EachSubStaionNum_TracAfterReg(i,1:TimeLength-1))+sum(Power_Time_EachSubStaionNum_TracAfterReg(i,2:TimeLength)))/2/3600;
    TotalBrakEnergyAfterReg_EachSubstation(i,1)=(sum(Power_Time_EachSubStation_BrakAfterReg(i,1:TimeLength-1))+sum(Power_Time_EachSubStation_BrakAfterReg(i,2:TimeLength)))/2/3600;
end
%% ��Ѽ���
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
C_grid=TotalUsedEnergyAfterReg_EachSubstation*c_buy*3+TotalBrakEnergyAfterReg_EachSubstation*c_fed*3;
C_dem=P_max*c_dem/30;
C_total=C_grid+C_dem;

Cost_grid=(sum(TotalUsedEnergyAfterReg_EachSubstation*c_buy)+sum(TotalBrakEnergyAfterReg_EachSubstation*c_fed))*3;
Cost_dem=sum(P_max*c_dem)/30;
Cost=Cost_grid+Cost_dem;
%% ��Ӧ�ȼ���
Fitness=Cost+f_travel*sum(TravelTimeDeviation,2)+f_service*max(ServerTimeDeviation)+f_safety*SaftyDistancePunc;
%Fitness=TotalTracEnergyAfterReg/3600+f_travel*sum(TravelTimeDeviation,2)+f_service*max(ServerTimeDeviation);
end

