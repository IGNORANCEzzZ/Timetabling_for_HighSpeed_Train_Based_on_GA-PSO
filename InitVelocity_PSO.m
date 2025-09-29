function [InitialVelocity]=InitVelocity_PSO(Particle)
%% 与基因长度有关
global TrainNum;%列车数 
global TotalStopTimes;
global TotalSections;

%% 与约束有关
global MaxDwellTimeMat;%MaxDwellTimeMat=zeros(1,TotalStopTimes);
global MinDwellTimeMat;%MinDwellTimeMat=zeros(1,TotalStopTimes);
global MaxHeadwayTime;%MaxHeadwayTime=150*ones(1,TrainNum);
global MinHeadwayTime;%MinHeadwayTime=200*ones(1,TrainNum);
global MaxRunTimeMat;%与初始化种群时的每个个体的矩阵形式一样的子区间运行时间索引范围限制矩阵，便于在生成种群时使用,(1,1:TotalSections)分别是第下行1个停站方案第一个运行区间的限制范围到下行最后一个方案最后一个运行区间的限制范围；
%MaxRunTimeMat=ones(1,2*TotalSections);
global MinRunTimeMat;%与初始化种群时的每个个体的矩阵形式一样的子区间运行时间索引范围限制矩阵，便于在生成种群时使用(1,TotalSections+1:TotalSections*2)分别是第上行1个停站方案第一个运行区间的限制范围到上行最后一个方案最后一个运行区间的限制范围；
%MinRunTimeMat=ones(1,2*TotalSections);
%%
Individual=zeros(1,TrainNum*2+TotalStopTimes*2+TotalSections*2);
Individual(1,1:TrainNum*2)=[round((MaxHeadwayTime-MinHeadwayTime).*rand(1,TrainNum)+MinHeadwayTime) round((MaxHeadwayTime-MinHeadwayTime).*rand(1,TrainNum)+MinHeadwayTime)];
Individual(1,TrainNum*2+1:TrainNum*2+TotalStopTimes*2)=[round((MaxDwellTimeMat-MinDwellTimeMat).*rand(1,TotalStopTimes)+MinDwellTimeMat) round((MaxDwellTimeMat-MinDwellTimeMat).*rand(1,TotalStopTimes)+MinDwellTimeMat)];
Individual(1,TrainNum*2+TotalStopTimes*2+1:TrainNum*2+TotalStopTimes*2+TotalSections*2)=round((MaxRunTimeMat-MinRunTimeMat).*rand(1,TotalSections*2)+MinRunTimeMat);
InitialVelocity=Individual(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2)-Particle(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2);
end