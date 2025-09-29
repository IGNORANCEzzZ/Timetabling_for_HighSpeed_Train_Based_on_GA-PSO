function [PopulationVelocityNext,PopulationPositionNextWithStopPlan]=UpdatePopulationTSPSO(PopulationPositionWithStopPlan,PopulationVelocity,Pbest,Gbest,Iter,tabu_P,tabu_G)
%% ����
% Ϊ�˲����󲿷ִ��룬�����PopulationPosition��500*236����ά����
%PopulationVelocity-500*216
%Pbest,tabu_P-500*216
%Gbest,tabu_G-500*216
%% ���
% �����PopulationVelocityNext��PopulationPositionNext��500*236����ά����
%%
global Swarm1Size;
global Swarm2Size;
global PSOPopSize;
global Col_of_Individual;%һ�������Ⱦɫ������=���г���*2+���з����ܵ�ͣվ����*2+���з����е�������*2+ͣվ������*2 Col_of_Individual=TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan*2;
global Num_StopPlan;
%% �̶�ѧϰ����
% global c1;
% global c2;
global IterMaxPSO;
%% ʱ��ѧϰ����
global c1_i;
global c1_f;
global c2_i;
global c2_f;
%% ��Լ���й�
global MaxDwellTimeMat;%MaxDwellTimeMat=zeros(1,TotalStopTimes);
global MinDwellTimeMat;%MinDwellTimeMat=zeros(1,TotalStopTimes);
global MaxHeadwayTime;%MaxHeadwayTime=150*ones(1,TrainNum);
global MinHeadwayTime;%MinHeadwayTime=200*ones(1,TrainNum);
global MaxRunTimeMat;%MaxRunTimeMat=ones(1,2*TotalSections);
global MinRunTimeMat;%MinRunTimeMat=ones(1,2*TotalSections);

%%
PopulationPosition=PopulationPositionWithStopPlan(:,1:Col_of_Individual-2*Num_StopPlan);
%% ����Ȩ��
exponent=(log(1.5)+log(19))*Iter/IterMaxPSO-log(19);
Omega=1/(1+exp(exponent));
% Omega=0.4;
%% ѧϰ����
c1_used=(c1_f-c1_i)*(Iter/IterMaxPSO)+c1_i;
c2_used=(c2_f-c2_i)*(Iter/IterMaxPSO)+c2_i;
% c1_used=2;
% c2_used=2;
%% �����
% rand1=rand(PSOPopSize,Col_of_Individual-Num_StopPlan*2);
% rand2=rand(PSOPopSize,Col_of_Individual-Num_StopPlan*2);
rand1=rand;
rand2=rand;

rand3=rand(PSOPopSize,Col_of_Individual-Num_StopPlan*2);
rand4=rand(PSOPopSize,Col_of_Individual-Num_StopPlan*2);
%% ����׼����GbestMat��tabu_GMat��X_span,Vmax,Vmin
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
%% ���º���������Ⱥ���ٶȺ�λ��
%����Ⱥ1�ĸ��·�ʽ
V_next1=(tabu_GMat==0).*(Omega.*PopulationVelocity+c1_used.*rand1.*(Pbest-PopulationPosition)+ c2_used.*rand2.*(GbestMat-PopulationPosition))+(tabu_GMat==1).*(GbestMat-PopulationPosition);
X_next1=round(PopulationPosition+V_next1);

%����Ⱥ2�ĸ��·�ʽ
VnextCase1=Omega.*PopulationVelocity+c1_used.*rand1.*(Pbest-PopulationPosition)+ c2_used.*rand2.*(GbestMat-PopulationPosition);
VnextCase2=Omega.*PopulationVelocity-c3_used.*(Pbest-PopulationPosition)+c2_used.*rand2.*(GbestMat-PopulationPosition);
VnextCase3=Omega.*PopulationVelocity+c1_used.*rand1.*(Pbest-PopulationPosition)-c4_used.*(GbestMat-PopulationPosition);
VnextCase4=Omega.*PopulationVelocity-c3_used.*(Pbest-PopulationPosition)-c4_used.*(GbestMat-PopulationPosition);
V_next2=(tabu_P==0 & tabu_GMat==0).*(VnextCase1)+(tabu_P==1 & tabu_GMat==0).*(VnextCase2)+(tabu_P==0 & tabu_GMat==1).*(VnextCase3)+(tabu_P==1 & tabu_GMat==1).*(VnextCase4);
X_next2=round(PopulationPosition+V_next2);
%% ����������Ⱥ�����ºϲ�,������һ����λ�ú��ٶ�
PopulationPositionNext=PopulationPositionWithStopPlan;
PopulationPositionNext(1:Swarm1Size,1:Col_of_Individual-Num_StopPlan*2)=X_next1(1:Swarm1Size,:);
PopulationPositionNext(Swarm1Size+1:end,1:Col_of_Individual-Num_StopPlan*2)=X_next2(Swarm1Size+1:end,:);

PopulationVelocityNext=zeros(PSOPopSize,Col_of_Individual-Num_StopPlan*2);
PopulationVelocityNext(1:Swarm1Size,:)=V_next1(1:Swarm1Size,:);
PopulationVelocityNext(Swarm1Size+1:end,:)=V_next2(Swarm1Size+1:end,:);

%% ����
UpLimitWithStopPlan=[MaxHeadwayTime MaxHeadwayTime MaxDwellTimeMat MaxDwellTimeMat MaxRunTimeMat PopulationPositionWithStopPlan(1,Col_of_Individual-Num_StopPlan*2+1:end)];
LowerLimitWithStopPlan=[MinHeadwayTime MinHeadwayTime MinDwellTimeMat MinDwellTimeMat MinRunTimeMat PopulationPositionWithStopPlan(1,Col_of_Individual-Num_StopPlan*2+1:end)];
UpLimitWithStopPlanMat=repmat(UpLimitWithStopPlan,PSOPopSize,1);
LowerLimitWithStopPlanMat=repmat(LowerLimitWithStopPlan,PSOPopSize,1);

PopulationPositionNextWithStopPlan=(PopulationPositionNext>UpLimitWithStopPlanMat).*(UpLimitWithStopPlanMat)+(PopulationPositionNext<LowerLimitWithStopPlanMat).*(LowerLimitWithStopPlanMat)+(PopulationPositionNext>=LowerLimitWithStopPlanMat & PopulationPositionNext<=UpLimitWithStopPlanMat).*(PopulationPositionNext);

end