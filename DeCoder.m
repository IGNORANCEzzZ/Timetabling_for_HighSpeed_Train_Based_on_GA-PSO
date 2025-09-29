function [Headway,Dwell_Down,Dwell_Up,Runtime_Down,Runtime_Up,RealTime_Down,RealTime_Up]=DeCoder(Solution)
global OperationScheme;
global TrainNum;
%���б���ͣվ����
global TotalStopTimes;
%���б���������
global TotalSections;
global Col_of_Individual;

Headway=zeros(2,TrainNum);
Headway(1,1:TrainNum)=Solution(1,1:TrainNum);
Headway(2,1:TrainNum)=Solution(1,TrainNum+1:TrainNum*2);

%% ͣվʱ��
[StopPlanNum,StationNum]=size(OperationScheme);
TrainSeq=Solution(1,TrainNum*2+TotalStopTimes*2+TotalSections*2+1:Col_of_Individual);
TrainSeq_Down=TrainSeq(1,1:StopPlanNum);%��������-����
TrainSeq_Up=TrainSeq(1,StopPlanNum+1:end);%��������-����

Dwell_Down_tmp=zeros(StopPlanNum,StationNum);%ͣվʱ�����У��б�ʾ���Σ��г���ʾA1-A11
Dwell_Up_tmp=zeros(StopPlanNum,StationNum);%ͣվʱ�����У��б�ʾ���Σ��г���ʾA11-A1

Dwell_Down=zeros(StopPlanNum,StationNum);%ͣվʱ�����У��б�ʾ���Σ��г���ʾA1-A11
Dwell_Up=zeros(StopPlanNum,StationNum);%ͣվʱ�����У��б�ʾ���Σ��г���ʾA11-A1

index_of_stop_down=0;
index_of_stop_up=0;
for i=1:1:StopPlanNum 
    StopPlan_Dowm=OperationScheme(i,:);
    StopPlan_Up=OperationScheme(i,:);
    for j=1:1:StationNum
        if StopPlan_Dowm(1,j)==1
            index_of_stop_down=index_of_stop_down+1;
            Dwell_Down_tmp(i,j)=Solution(1,TrainNum*2+index_of_stop_down);
        end
        if StopPlan_Up(1,j)==1
            index_of_stop_up=index_of_stop_up+1;
            Dwell_Up_tmp(i,j)=Solution(1,TrainNum*2+TotalStopTimes+index_of_stop_up);
        end
    end
end
for i=1:1:StopPlanNum
    Dwell_Down(i,:)=Dwell_Down_tmp(TrainSeq_Down(1,i),:);
    Dwell_Up(i,:)=Dwell_Up_tmp(TrainSeq_Up(1,i),:);
end
Dwell_Up=fliplr(Dwell_Up);
%% ��������ʱ��
Runtime_Down_tmp=zeros(StopPlanNum,StationNum-1);
Runtime_Up_tmp=zeros(StopPlanNum,StationNum-1);
Runtime_Down=zeros(StopPlanNum,StationNum-1);
Runtime_Up=zeros(StopPlanNum,StationNum-1);

index_of_runtime_down=0;
index_of_runtime_up=0;
for i=1:1:StopPlanNum 
    StopPlan_Dowm=OperationScheme(i,:);
    StopStation_Down=find(StopPlan_Dowm==1);

    StopPlan_Up=OperationScheme(i,:);
    StopStation_Up=find(StopPlan_Up==1);

    for d=1:1:length(StopStation_Down)-1%����
        index_of_runtime_down=index_of_runtime_down+1;
        StartStation=StopStation_Down(d);
        EndStation=StopStation_Down(d+1);
        Up=0;
        sheet=Solution(1,TrainNum*2+TotalStopTimes*2+index_of_runtime_down);
        [T]=FindTSet(StartStation,EndStation,sheet,Up);
        Runtime_Down_tmp(i,StartStation:EndStation-1)=T;
    end

    for d=1:1:length(StopStation_Up)-1%����
        index_of_runtime_up=index_of_runtime_up+1;
        StartStation=StopStation_Up(d+1);
        EndStation=StopStation_Up(d);
        Up=1;
        sheet=Solution(1,TrainNum*2+TotalStopTimes*2+TotalSections+index_of_runtime_up);
        [T]=FindTSet(StartStation,EndStation,sheet,Up);
        disp(T)
        Runtime_Up_tmp(i,EndStation:StartStation-1)=fliplr(T);%ǰ��ת
    end
end
for i=1:1:StopPlanNum
    Runtime_Down(i,:)=Runtime_Down_tmp(TrainSeq_Down(1,i),:);
    Runtime_Up(i,:)=Runtime_Up_tmp(TrainSeq_Up(1,i),:);
end
Runtime_Up=fliplr(Runtime_Up);

%% ������������ʱ������ۼƣ����ÿ������ÿ����վ�ĵ���ʱ��
RealTime_Down=zeros(StationNum,3,TrainNum);
RealTime_Up=zeros(StationNum,3,TrainNum);
%�б�ʾ��վ
%��һ�У�����ʱ��
%�ڶ��У�����ʱ��
%�����У�ͣվʱ��

%����
for i=1:1:TrainNum
    plan=mod(i,10);
    if (plan==0)
        plan=10;
    end
    DepartTime=sum(Headway(1,1:i));
    RealTime_Down(1,1,i)=DepartTime;
    RealTime_Down(1,2,i)=DepartTime;
    RealTime_Down(1,3,i)=Dwell_Down(plan,1);
    for j=2:1:StationNum
        %����ʱ��=�ϸ���վ�ķ���ʱ��+�ϸ���վ�������վ����������ʱ��
        ArrivalTime=RealTime_Down(j-1,2,i)+Runtime_Down(plan,j-1);
        %����ʱ��=����ʱ��+�����վ��ͣվʱ��
        DepartTime=ArrivalTime+Dwell_Down(plan,j);
        RealTime_Down(j,1,i)=ArrivalTime;
        RealTime_Down(j,2,i)=DepartTime;
        RealTime_Down(j,3,i)=Dwell_Down(plan,j);
    end
end

%����
for i=1:1:TrainNum
    plan=mod(i,10);
    if (plan==0)
        plan=10;
    end
    DepartTime=sum(Headway(2,1:i));
    RealTime_Up(1,1,i)=DepartTime;
    RealTime_Up(1,2,i)=DepartTime;
    RealTime_Up(1,3,i)=Dwell_Up(plan,1);
    for j=2:1:StationNum
        %����ʱ��=�ϸ���վ�ķ���ʱ��+�ϸ���վ�������վ����������ʱ��
        ArrivalTime=RealTime_Up(j-1,2,i)+Runtime_Up(plan,j-1);
        %����ʱ��=����ʱ��+�����վ��ͣվʱ��
        DepartTime=ArrivalTime+Dwell_Up(plan,j);
        RealTime_Up(j,1,i)=ArrivalTime;
        RealTime_Up(j,2,i)=DepartTime;
        RealTime_Up(j,3,i)=Dwell_Up(plan,j);
    end
end

% RealTime_Down_ceil=zero(StationNum,3,TrainNum);
% RealTime_Up_ceil=zero(StationNum,3,TrainNum);
fid=fopen("C:\Users\cjs\Desktop\����40����-��͵��.txt",'wt');		% д���ļ�·��
fid2=fopen("C:\Users\cjs\Desktop\����40����-��͵��.txt",'wt');		% д���ļ�·��
for x=1:1:TrainNum
    for y=1:1:StationNum
           fprintf(fid,'%10s %10s %10s\n',TimeFormatConver(RealTime_Down(y,1,x),9,0,0),TimeFormatConver(RealTime_Down(y,2,x),9,0,0),mat2str(RealTime_Down(y,3,x)));  
           fprintf(fid2,'%10s %10s %10s\n',TimeFormatConver(RealTime_Up(y,1,x),9,0,0),TimeFormatConver(RealTime_Up(y,2,x),9,0,0),mat2str(RealTime_Up(y,3,x))); 
    end
    fprintf(fid,'%s\n',"  ");
    fprintf(fid2,'%s\n',"  ");
end
fclose(fid);
fclose(fid2);
end