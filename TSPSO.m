clc;
clear;
Global;
global Col_of_Individual;%һ�������Ⱦɫ������=���г���*2+���з����ܵ�ͣվ����*2+���з����е�������*2+ͣվ������*2 Col_of_Individual=TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan*2;
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
% ��ʼ�����������
count_P_before=zeros(PSOPopSize,Col_of_Individual-Num_StopPlan*2);
count_G_before=zeros(1,Col_of_Individual-Num_StopPlan*2);
tabu_P=zeros(PSOPopSize,Col_of_Individual-Num_StopPlan*2);
tabu_G=zeros(1,Col_of_Individual-Num_StopPlan*2);
while 1
    IterationNum=IterationNum+1;
    tic
    disp('����')
    disp(IterationNum)
    disp('���㱾����Ⱥ��Ӧ��')   
    [Ranked_Fitness,RankedPop,AllFitness,Population]=AllFitnessCalandSort(Population_PSO);  
    disp('�������Ÿ�����Ӧ��= ') 
    disp(Ranked_Fitness(1,1))    
    
    %��¼ǰ��������ʷ����λ��
    Pbest_before=reshape(BestParticle_Individual(:,1:Col_of_Individual-Num_StopPlan*2,:),[Col_of_Individual-Num_StopPlan*2 PSOPopSize]);
    Pbest_before=Pbest_before';
    %����ÿ�����Ӿ���������ʷ��õ�
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
    %��¼���º�ĸ���������ʷ����λ��
    Pbest_after=reshape(BestParticle_Individual(:,1:Col_of_Individual-Num_StopPlan*2,:),[Col_of_Individual-Num_StopPlan*2 PSOPopSize]);
    Pbest_after=Pbest_after';
    
    %��¼ǰ����Ⱥ��ʷ����λ��
    Gbest_before=BestParticle_Global(:,1:Col_of_Individual-Num_StopPlan*2);
    
    %����Ⱥ����������������������õĵ�
    disp('������Ⱥ��ʷ��������')
    if Ranked_Fitness(1,1)<BestFitness_Global(1,1)
        BestFitness_Global(1,1)=Ranked_Fitness(1,1);
        BestParticle_Global(1,:)=RankedPop(:,:,1);
    end
    disp('��ʷ����������Ӧ��')
    disp(BestFitness_Global(1,1))
    disp(' ')
    %��¼�˴���Ⱥ��ʷ����λ��
    Gbest_after=BestParticle_Global(:,1:Col_of_Individual-Num_StopPlan*2);
    
    % ���½���״̬
    [count_P,count_G,tabu_P,tabu_G]=UpdateTabuState(count_P_before,count_G_before,Pbest_before,Pbest_after,Gbest_before,Gbest_after);
    count_P_before=count_P;
    count_G_before=count_G;
    
    %�������ӵ�λ�ú��ٶ�
    %��λ�ú��ٶȾ������άת����2ά��
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
    
