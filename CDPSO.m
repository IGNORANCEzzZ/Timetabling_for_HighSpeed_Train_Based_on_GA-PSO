clc;
clear;
Global;
global Col_of_Individual;%һ�������Ⱦɫ������=���г���*2+���з����ܵ�ͣվ����*2+���з����е�������*2+ͣվ������*2 Col_of_Individual=TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan*2;
global PSOPopSize;
global fitness_stop;
global IterMaxPSO;

[Population_PSO]=InitPopulationPSO();

BestIndividualFromGa=xlsread('��͵��-GA������Ž�',1);
Population_PSO(:,:,1)=BestIndividualFromGa;

IterationNum=0;
BestParticle_Individual=[];
BestFitness_Individual=zeros(1,PSOPopSize);

BestParticle_Global=zeros(4,Col_of_Individual);
BestFitness_Global=zeros(1,4);
BestFitness_Global(1,1:4)=1e16;
[AllInitVelocity]=InitVelocityForTotalPopulation_PSO(Population_PSO); 
[Ranked_Fitness,RankedPop,AllFitness,Population]=AllFitnessCalandSort(Population_PSO);
while 1
    IterationNum=IterationNum+1;
     tic
    disp('����')
    disp(IterationNum)
    disp('���㱾����Ⱥ��Ӧ��')   
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
        BestParticle_Global(1,:)=RankedPop(:,:,1);
    end
    if Ranked_Fitness(1,2)<BestFitness_Global(1,2)
        BestFitness_Global(1,2)=Ranked_Fitness(1,2);
        BestParticle_Global(2,:)=RankedPop(:,:,2);
    end
    if Ranked_Fitness(1,3)<BestFitness_Global(1,3)
        BestFitness_Global(1,3)=Ranked_Fitness(1,3);
        BestParticle_Global(3,:)=RankedPop(:,:,3);
    end
    if Ranked_Fitness(1,4)<BestFitness_Global(1,4)
        BestFitness_Global(1,4)=Ranked_Fitness(1,4);
        BestParticle_Global(4,:)=RankedPop(:,:,4);
    end
    disp('��ʷ����������Ӧ��')
    disp(BestFitness_Global(1,1))
    disp(' ')
    
    if IterationNum>IterMaxPSO
        break;
    end
    if BestFitness_Global(1,1)<fitness_stop
        break;
    else
        disp('����Ⱥ��������һ��')
        [Population_Moved_CSO,Velocity_After_CSO]=UpdatePopulationPositionCSO(Population,AllFitness,AllInitVelocity);
        [Ranked_Fitness,RankedPop,AllFitness,Population]=AllFitnessCalandSort(Population_Moved_CSO);
        if Ranked_Fitness(1,1)<BestFitness_Global(1,1)
            BestFitness_Global(1,1)=Ranked_Fitness(1,1);
            BestParticle_Global(1,:)=RankedPop(:,:,1);
        end
        [Population_Moved_PSO,AllVelocity_After_PSO]=UpdatePositionOfPopulation(Population,AllInitVelocity,BestParticle_Individual,BestParticle_Global,IterationNum);%����PS
        [Ranked_Fitness,RankedPop,AllFitness,Population]=AllFitnessCalandSort(Population_Moved_PSO);
        if Ranked_Fitness(1,1)<BestFitness_Global(1,1)
            BestFitness_Global(1,1)=Ranked_Fitness(1,1);
            BestParticle_Global(1,:)=RankedPop(:,:,1);
        end
    end
    
%% ÿ��N�ε��������ֻ�һ��ѧϰ����   
%     RandSequence(1,1:PSOPopSize/2)=1:2:PSOPopSize-1;
%     RandSequence(1,PSOPopSize/2+1:PSOPopSize)=2:2:PSOPopSize;  
%     if mod(IterationNum,IterationNum/2)==0
%         if RandSequence(1,1)==1
%             RandSequence(1,1:PSOPopSize/2)=2:2:PSOPopSize;
%             RandSequence(1,PSOPopSize/2+1:PSOPopSize)=1:2:PSOPopSize-1;
%         end
%         if RandSequence(1,1)==2
%             RandSequence(1,1:PSOPopSize/2)=1:2:PSOPopSize-1;
%             RandSequence(1,PSOPopSize/2+1:PSOPopSize)=2:2:PSOPopSize;
%         end
%     end
%% ���ֻ�ѧϰ����
    RandSequence(1,1:PSOPopSize/2)=1:2:PSOPopSize-1;
    RandSequence(1,PSOPopSize/2+1:PSOPopSize)=2:2:PSOPopSize;
%%
        Population_PSO(:,:,RandSequence(1,1:PSOPopSize/2))=Population_Moved_CSO(:,:,RandSequence(1,1:PSOPopSize/2));
        AllInitVelocity(:,:,RandSequence(1,1:PSOPopSize/2))=Velocity_After_CSO(:,:,RandSequence(1,1:PSOPopSize/2));
        
        Population_PSO(:,:,RandSequence(1,PSOPopSize/2+1:PSOPopSize))=Population_Moved_PSO(:,:,RandSequence(1,PSOPopSize/2+1:PSOPopSize));
        AllInitVelocity(:,:,RandSequence(1,PSOPopSize/2+1:PSOPopSize))=AllVelocity_After_PSO(:,:,RandSequence(1,PSOPopSize/2+1:PSOPopSize));        
        toc;
%     for i=1:1:PSOPopSize%������Ⱥ
%         while 1        
%             exponent=(log(1.5)+log(19))*Iter/IterMaxPSO-log(19);
%             Omega=1/(1+exp(exponent));           
%             c1_used=(c1_f-c1_i)*(Iter/IterMaxPSO)+c1_i;
%             c2_used=(c2_f-c2_i)*(Iter/IterMaxPSO)+c2_i;       
%             rand1=rand;
%             rand2=rand;
%             
%         end
%     end      
end
xlswrite('���������ս�-CDPSO',BestParticle_Global(1,:),1);