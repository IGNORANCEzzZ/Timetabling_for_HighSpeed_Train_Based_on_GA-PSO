clc;
Global;
global PSOPopSize;
global fitness_stop;
global Col_of_Individual;%一个个体的染色体数量=开行车数*2+开行方案种的停站次数*2+开行方案中的区间数*2
global IterMaxPSO;
tic
[Population_PSO]=InitPopulationPSO();

IterationNum=1;
BestParticle_Individual=[];
BestFitness_Individual=zeros(1,PSOPopSize);

BestParticle_Global=zeros(1,Col_of_Individual);
BestFitness_Global=zeros(1,1);
BestFitness_Global(1,1)=1e16;
[AllInitVelocity]=InitVelocityForTotalPopulation_PSO(Population_PSO);

while 1
    tic
    disp('代数')
    disp(IterationNum)
    disp('计算本代种群适应度')   
    tic;
    [Ranked_Fitness,RankedPop,AllFitness,Population]=AllFitnessCalandSort(Population_PSO);  
    disp('本代最优个体适应度= ')
    disp(Ranked_Fitness(1,1))    
    %每个粒子经历过的历史最好点
    if isempty(BestParticle_Individual)
        BestParticle_Individual=Population;
        BestFitness_Individual=AllFitness;
    else
        for j=1:1:PSOPopSize
            if AllFitness(1,j)<BestFitness_Individual(1,j)
                BestParticle_Individual(:,:,j)=Population(:,:,j);
            end
        end
    end
    
    %群体内所有粒子所经过的最好的点
    disp('更新历史最优粒子')
    if Ranked_Fitness(1,1)<BestFitness_Global(1,1)
        BestFitness_Global(1,1)=Ranked_Fitness(1,1);
        BestParticle_Global=RankedPop(:,:,1);
    end
    
    disp('历史最优粒子适应度')
    disp(BestFitness_Global(1,1))
    disp(' ')
    
    if BestFitness_Global(1,1)<fitness_stop
        break;
    else
        disp('粒子群更新至下一代')
        [Population_Moved,Velocity_After]=UpdatePopulationPositionCSO(Population,AllFitness,AllInitVelocity);
    end
    toc;
    Population_PSO=Population_Moved;
    IterationNum=IterationNum+1;
    AllInitVelocity=AllVelocity_After;
    if IterationNum>=IterMaxPSO%停机准则2：达到迭代上限3
        break;
    end
end
