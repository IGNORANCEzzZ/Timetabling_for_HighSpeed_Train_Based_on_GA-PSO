clc;
clear;
Global;
global Col_of_Individual;%一个个体的染色体数量=开行车数*2+开行方案总的停站次数*2+开行方案中的区间数*2+停站方案数*2 Col_of_Individual=TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan*2;
global PSOPopSize;
global fitness_stop;
global IterMaxPSO;
global Num_StopPlan;

[Population_PSO]=InitPopulationPSO();
IterationNum=0;
BestParticle_Individual=zeros(1,Col_of_Individual,PSOPopSize);
BestFitness_Individual=zeros(1,PSOPopSize);

BestParticle_Global=zeros(1,Col_of_Individual);
BestFitness_Global(1,1)=1e16;
[AllInitVelocity]=InitVelocityForTotalPopulation_PSO(Population_PSO);
% 初始化紧急表相关
count_P_before=zeros(PSOPopSize,Col_of_Individual-Num_StopPlan*2);
count_G_before=zeros(1,Col_of_Individual-Num_StopPlan*2);
tabu_P=zeros(PSOPopSize,Col_of_Individual-Num_StopPlan*2);
tabu_G=zeros(1,Col_of_Individual-Num_StopPlan*2);
while 1
    IterationNum=IterationNum+1;
    tic
    disp('代数')
    disp(IterationNum)
    disp('计算本代种群适应度')   
    [Ranked_Fitness,RankedPop,AllFitness,Population]=AllFitnessCalandSort(Population_PSO);  
    disp('本代最优个体适应度= ') 
    disp(Ranked_Fitness(1,1))    
    
    %记录前代个体历史最优位置
    Pbest_before=reshape(BestParticle_Individual(:,1:Col_of_Individual-Num_StopPlan*2,:),[Col_of_Individual-Num_StopPlan*2 PSOPopSize]);
    Pbest_before=Pbest_before';
    %更新每个粒子经历过的历史最好点
    if BestParticle_Individual(1,1,1)==0
        BestParticle_Individual=Population;
        BestFitness_Individual=AllFitness;
    else
        for j=1:1:PSOPopSize
            if AllFitness(1,j)<BestFitness_Individual(1,j)
                BestParticle_Individual(:,:,j)=Population(:,:,j);
            end
        end
    end
    %记录更新后的个体粒子历史最优位置
    Pbest_after=reshape(BestParticle_Individual(:,1:Col_of_Individual-Num_StopPlan*2,:),[Col_of_Individual-Num_StopPlan*2 PSOPopSize]);
    Pbest_after=Pbest_after';
    
    %记录前代种群历史最优位置
    Gbest_before=BestParticle_Global(:,1:Col_of_Individual-Num_StopPlan*2);
    
    %更新群体内所有粒子所经过的最好的点
    disp('更新种群历史最优粒子')
    if Ranked_Fitness(1,1)<BestFitness_Global(1,1)
        BestFitness_Global(1,1)=Ranked_Fitness(1,1);
        BestParticle_Global(1,:)=RankedPop(:,:,1);
    end
    disp('历史最优粒子适应度')
    disp(BestFitness_Global(1,1))
    disp(' ')
    %记录此代种群历史最优位置
    Gbest_after=BestParticle_Global(:,1:Col_of_Individual-Num_StopPlan*2);
    
    % 更新禁忌状态
    [count_P,count_G,tabu_P,tabu_G]=UpdateTabuState(count_P_before,count_G_before,Pbest_before,Pbest_after,Gbest_before,Gbest_after);
    count_P_before=count_P;
    count_G_before=count_G;
    
    %更新粒子的位置和速度
    %把位置和速度矩阵从三维转化成2维的
    PopulationVelocity=reshape(AllInitVelocity,[Col_of_Individual-Num_StopPlan*2 PSOPopSize]);
    PopulationVelocity=PopulationVelocity';
    PopulationPositionWithStopPlan=reshape(Population,[Col_of_Individual PSOPopSize]);
    PopulationPositionWithStopPlan=PopulationPositionWithStopPlan';
     
    if IterationNum>IterMaxPSO
        break;
    elseif BestFitness_Global(1,1)<fitness_stop
        break;
    else
        [PopulationVelocityNext,PopulationPositionNext]=UpdatePopulationTSPSO(PopulationPositionWithStopPlan,PopulationVelocity,Pbest_after,Gbest_after,IterationNum,tabu_P,tabu_G);
    end
    
    parfor i=1:1:PSOPopSize
        AllInitVelocity(1,:,i)=PopulationVelocityNext(i,:);
        Population_PSO(1,:,i)=PopulationPositionNext(i,:);
    end
    toc;
  
end
    
