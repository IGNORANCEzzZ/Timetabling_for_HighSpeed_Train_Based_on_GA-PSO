function [PopulationVelocityNext,PopulationPositionNextWithStopPlan]=UpdatePopulationTSPSO(PopulationPositionWithStopPlan,PopulationVelocity,Pbest,Gbest,Iter,tabu_P,tabu_G)
%% 输入
% 为了不动大部分代码，输入的PopulationPosition是500*236的两维矩阵
%PopulationVelocity-500*216
%Pbest,tabu_P-500*216
%Gbest,tabu_G-500*216
%% 输出
% 输出的PopulationVelocityNext和PopulationPositionNext是500*236的两维矩阵
%%
global Swarm1Size;
global Swarm2Size;
global PSOPopSize;
global Col_of_Individual;%一个个体的染色体数量=开行车数*2+开行方案总的停站次数*2+开行方案中的区间数*2+停站方案数*2 Col_of_Individual=TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan*2;
global Num_StopPlan;
%% 固定学习因子
% global c1;
% global c2;
global IterMaxPSO;
%% 时变学习因子
global c1_i;
global c1_f;
global c2_i;
global c2_f;
%% 与约束有关
global MaxDwellTimeMat;%MaxDwellTimeMat=zeros(1,TotalStopTimes);
global MinDwellTimeMat;%MinDwellTimeMat=zeros(1,TotalStopTimes);
global MaxHeadwayTime;%MaxHeadwayTime=150*ones(1,TrainNum);
global MinHeadwayTime;%MinHeadwayTime=200*ones(1,TrainNum);
global MaxRunTimeMat;%MaxRunTimeMat=ones(1,2*TotalSections);
global MinRunTimeMat;%MinRunTimeMat=ones(1,2*TotalSections);

%%
PopulationPosition=PopulationPositionWithStopPlan(:,1:Col_of_Individual-2*Num_StopPlan);
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
% rand1=rand(PSOPopSize,Col_of_Individual-Num_StopPlan*2);
% rand2=rand(PSOPopSize,Col_of_Individual-Num_StopPlan*2);
rand1=rand;
rand2=rand;

rand3=rand(PSOPopSize,Col_of_Individual-Num_StopPlan*2);
rand4=rand(PSOPopSize,Col_of_Individual-Num_StopPlan*2);
%% 参数准备：GbestMat，tabu_GMat，X_span,Vmax,Vmin
GbestMat=repmat(Gbest,PSOPopSize,1);
tabu_GMat=repmat(tabu_G,PSOPopSize,1);

UpLimit=[MaxHeadwayTime MaxHeadwayTime MaxDwellTimeMat MaxDwellTimeMat MaxRunTimeMat];
LowerLimit=[MinHeadwayTime MinHeadwayTime MinDwellTimeMat MinDwellTimeMat MinRunTimeMat];
X_span=UpLimit-LowerLimit;
X_span=(X_span==0).*(1)+(X_span~=0).*(X_span);

X_spanMat=repmat(X_span,PSOPopSize,1);
Vmax=X_spanMat./4;

c3_used=Vmax.*exp(-abs(Pbest-PopulationPosition)./X_spanMat);
c4_used=Vmax.*exp(-abs(Gbest-PopulationPosition)./X_spanMat);
%% 更新和两个子种群的速度和位置
%子种群1的更新方式
V_next1=(tabu_GMat==0).*(Omega.*PopulationVelocity+c1_used.*rand1.*(Pbest-PopulationPosition)+ c2_used.*rand2.*(GbestMat-PopulationPosition))+(tabu_GMat==1).*(GbestMat-PopulationPosition);
X_next1=round(PopulationPosition+V_next1);

%子种群2的更新方式
VnextCase1=Omega.*PopulationVelocity+c1_used.*rand1.*(Pbest-PopulationPosition)+ c2_used.*rand2.*(GbestMat-PopulationPosition);
VnextCase2=Omega.*PopulationVelocity-c3_used.*(Pbest-PopulationPosition)+c2_used.*rand2.*(GbestMat-PopulationPosition);
VnextCase3=Omega.*PopulationVelocity+c1_used.*rand1.*(Pbest-PopulationPosition)-c4_used.*(GbestMat-PopulationPosition);
VnextCase4=Omega.*PopulationVelocity-c3_used.*(Pbest-PopulationPosition)-c4_used.*(GbestMat-PopulationPosition);
V_next2=(tabu_P==0 & tabu_GMat==0).*(VnextCase1)+(tabu_P==1 & tabu_GMat==0).*(VnextCase2)+(tabu_P==0 & tabu_GMat==1).*(VnextCase3)+(tabu_P==1 & tabu_GMat==1).*(VnextCase4);
X_next2=round(PopulationPosition+V_next2);
%% 把两个子种群在重新合并,更新下一代的位置和速度
PopulationPositionNext=PopulationPositionWithStopPlan;
PopulationPositionNext(1:Swarm1Size,1:Col_of_Individual-Num_StopPlan*2)=X_next1(1:Swarm1Size,:);
PopulationPositionNext(Swarm1Size+1:end,1:Col_of_Individual-Num_StopPlan*2)=X_next2(Swarm1Size+1:end,:);

PopulationVelocityNext=zeros(PSOPopSize,Col_of_Individual-Num_StopPlan*2);
PopulationVelocityNext(1:Swarm1Size,:)=V_next1(1:Swarm1Size,:);
PopulationVelocityNext(Swarm1Size+1:end,:)=V_next2(Swarm1Size+1:end,:);

%% 修正
UpLimitWithStopPlan=[MaxHeadwayTime MaxHeadwayTime MaxDwellTimeMat MaxDwellTimeMat MaxRunTimeMat PopulationPositionWithStopPlan(1,Col_of_Individual-Num_StopPlan*2+1:end)];
LowerLimitWithStopPlan=[MinHeadwayTime MinHeadwayTime MinDwellTimeMat MinDwellTimeMat MinRunTimeMat PopulationPositionWithStopPlan(1,Col_of_Individual-Num_StopPlan*2+1:end)];
UpLimitWithStopPlanMat=repmat(UpLimitWithStopPlan,PSOPopSize,1);
LowerLimitWithStopPlanMat=repmat(LowerLimitWithStopPlan,PSOPopSize,1);

PopulationPositionNextWithStopPlan=(PopulationPositionNext>UpLimitWithStopPlanMat).*(UpLimitWithStopPlanMat)+(PopulationPositionNext<LowerLimitWithStopPlanMat).*(LowerLimitWithStopPlanMat)+(PopulationPositionNext>=LowerLimitWithStopPlanMat & PopulationPositionNext<=UpLimitWithStopPlanMat).*(PopulationPositionNext);

end