function [Particle_Moved,Velocity_After]=UpdatePositionPSO(Particle,Velocity_Before,BestParticle_Individual,BestParticle_Global,Iter)
%% 固定学习因子
% global c1;
% global c2;
global IterMaxPSO;
%% 时变学习因子
global c1_i;
global c1_f;
global c2_i;
global c2_f;
%% 与基因长度有关
global TrainNum;%列车数 
global TotalStopTimes;
global TotalSections;

%% 与约束有关
global MaxDwellTimeMat;%MaxDwellTimeMat=zeros(1,TotalStopTimes);
global MinDwellTimeMat;%MinDwellTimeMat=zeros(1,TotalStopTimes);
global MaxHeadwayTime;%MaxHeadwayTime=150*ones(1,TrainNum);
global MinHeadwayTime;%MinHeadwayTime=200*ones(1,TrainNum);
global MaxRunTimeMat;%MaxRunTimeMat=ones(1,2*TotalSections);
global MinRunTimeMat;%MinRunTimeMat=ones(1,2*TotalSections);
%% 惯性权重
exponent=(log(1.5)+log(19))*Iter/IterMaxPSO-log(19);
Omega=1/(1+exp(exponent));
% Omega=0.4;
%% 学习因子
c1_used=(c1_f-c1_i)*(Iter/IterMaxPSO)+c1_i;
c2_used=(c2_f-c2_i)*(Iter/IterMaxPSO)+c2_i;
% c1_used=2;
% c2_used=2;
%% 随机数
rand1=rand;
rand2=rand;
%% 位置更新
Velocity_After=Omega.*Velocity_Before+c1_used*rand1.*(BestParticle_Individual(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2)-Particle(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2))+c2_used*rand2.*(BestParticle_Global(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2)-Particle(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2));
Particle_Moved=Particle;
Particle_Moved(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2)=round(Particle_Moved(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2)+Velocity_After);
%% 约束处理（更新后超范围修正）
UpLimit=[MaxHeadwayTime MaxHeadwayTime MaxDwellTimeMat MaxDwellTimeMat MaxRunTimeMat];
LowerLimit=[MinHeadwayTime MinHeadwayTime MinDwellTimeMat MinDwellTimeMat MinRunTimeMat];

for i=1:1:TrainNum*2+TotalStopTimes*2+TotalSections*2
    if Particle_Moved(1,i)>UpLimit(1,i)
        Particle_Moved(1,i)=UpLimit(1,i);
    end
    if Particle_Moved(1,i)<LowerLimit(1,i)
        Particle_Moved(1,i)=LowerLimit(1,i);
    end
end
end