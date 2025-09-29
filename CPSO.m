clc;
Global;
global PSOPopSize;
global fitness_stop;
global Col_of_Individual;%һ�������Ⱦɫ������=���г���*2+���з����ֵ�ͣվ����*2+���з����е�������*2
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
    disp('����')
    disp(IterationNum)
    disp('���㱾����Ⱥ��Ӧ��')   
    tic;
    [Ranked_Fitness,RankedPop,AllFitness,Population]=AllFitnessCalandSort(Population_PSO);  
    disp('�������Ÿ�����Ӧ��= ')
    disp(Ranked_Fitness(1,1))    
    %ÿ�����Ӿ���������ʷ��õ�
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
    
    %Ⱥ����������������������õĵ�
    disp('������ʷ��������')
    if Ranked_Fitness(1,1)<BestFitness_Global(1,1)
        BestFitness_Global(1,1)=Ranked_Fitness(1,1);
        BestParticle_Global=RankedPop(:,:,1);
    end
    
    disp('��ʷ����������Ӧ��')
    disp(BestFitness_Global(1,1))
    disp(' ')
    
    if BestFitness_Global(1,1)<fitness_stop
        break;
    else
        disp('����Ⱥ��������һ��')
        [Population_Moved,Velocity_After]=UpdatePopulationPositionCSO(Population,AllFitness,AllInitVelocity);
    end
    toc;
    Population_PSO=Population_Moved;
    IterationNum=IterationNum+1;
    AllInitVelocity=AllVelocity_After;
    if IterationNum>=IterMaxPSO%ͣ��׼��2���ﵽ��������3
        break;
    end
end
