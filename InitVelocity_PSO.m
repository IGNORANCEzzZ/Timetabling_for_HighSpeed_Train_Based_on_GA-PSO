function [InitialVelocity]=InitVelocity_PSO(Particle)
%% ����򳤶��й�
global TrainNum;%�г��� 
global TotalStopTimes;
global TotalSections;

%% ��Լ���й�
global MaxDwellTimeMat;%MaxDwellTimeMat=zeros(1,TotalStopTimes);
global MinDwellTimeMat;%MinDwellTimeMat=zeros(1,TotalStopTimes);
global MaxHeadwayTime;%MaxHeadwayTime=150*ones(1,TrainNum);
global MinHeadwayTime;%MinHeadwayTime=200*ones(1,TrainNum);
global MaxRunTimeMat;%���ʼ����Ⱥʱ��ÿ������ľ�����ʽһ��������������ʱ��������Χ���ƾ��󣬱�����������Ⱥʱʹ��,(1,1:TotalSections)�ֱ��ǵ�����1��ͣվ������һ��������������Ʒ�Χ���������һ���������һ��������������Ʒ�Χ��
%MaxRunTimeMat=ones(1,2*TotalSections);
global MinRunTimeMat;%���ʼ����Ⱥʱ��ÿ������ľ�����ʽһ��������������ʱ��������Χ���ƾ��󣬱�����������Ⱥʱʹ��(1,TotalSections+1:TotalSections*2)�ֱ��ǵ�����1��ͣվ������һ��������������Ʒ�Χ���������һ���������һ��������������Ʒ�Χ��
%MinRunTimeMat=ones(1,2*TotalSections);
%%
Individual=zeros(1,TrainNum*2+TotalStopTimes*2+TotalSections*2);
Individual(1,1:TrainNum*2)=[round((MaxHeadwayTime-MinHeadwayTime).*rand(1,TrainNum)+MinHeadwayTime) round((MaxHeadwayTime-MinHeadwayTime).*rand(1,TrainNum)+MinHeadwayTime)];
Individual(1,TrainNum*2+1:TrainNum*2+TotalStopTimes*2)=[round((MaxDwellTimeMat-MinDwellTimeMat).*rand(1,TotalStopTimes)+MinDwellTimeMat) round((MaxDwellTimeMat-MinDwellTimeMat).*rand(1,TotalStopTimes)+MinDwellTimeMat)];
Individual(1,TrainNum*2+TotalStopTimes*2+1:TrainNum*2+TotalStopTimes*2+TotalSections*2)=round((MaxRunTimeMat-MinRunTimeMat).*rand(1,TotalSections*2)+MinRunTimeMat);
InitialVelocity=Individual(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2)-Particle(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2);
end