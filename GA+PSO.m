clc
Global;
global TrainNum
global TotalStopTimes
global TotalSections
global Num_StopPlan;
global OperationScheme;
global Col_of_Individual;%һ�������Ⱦ�?������=���г���*2+���з����ܵ�ͣվ����*2+���з����е�������*2+ͣվ������*2 Col_of_Individual=TrainNum*2+TotalStopTimes*2+TotalSections*2+Num_StopPlan*2;
global MaxDwellTimeMat;%MaxDwellTimeMat=zeros(1,TotalStopTimes);
global MinDwellTimeMat;%MinDwellTimeMat=zeros(1,TotalStopTimes);
global MaxHeadwayTime;%MaxHeadwayTime=150*ones(1,TrainNum);
global MinHeadwayTime;%MinHeadwayTime=200*ones(1,TrainNum);
global MaxRunTimeMat;%���ʼ����Ⱥʱ��ÿ������ľ�����ʽһ��������������ʱ��������Χ���ƾ��󣬱�����������Ⱥʱʹ��,(1,1:TotalSections)�ֱ��ǵ�����1��ͣվ������һ��������������Ʒ�Χ���������һ���������һ��������������Ʒ�Χ��
%MaxRunTimeMat=ones(1,2*TotalSections);
global MinRunTimeMat;%���ʼ����Ⱥʱ��ÿ������ľ�����ʽһ��������������ʱ��������Χ���ƾ��󣬱�����������Ⱥʱʹ��(1,TotalSections+1:TotalSections*2)�ֱ��ǵ�����1��ͣվ������һ��������������Ʒ�Χ���������һ���������һ��������������Ʒ�Χ��
%MinRunTimeMat=ones(1,2*TotalSections);
global PSOPopSize;
global fitness_stop;
global IterMaxPSO;

%% GA
fun=@GAFitnessCalc;%��Ӧ�Ⱥ������?
nvars=Col_of_Individual;
A=[];
b=[];
Aeq=[];
beq=[];
ub=zeros(Col_of_Individual,1);
lb=zeros(Col_of_Individual,1);
ub(1:TrainNum*2,1)=[MaxHeadwayTime MaxHeadwayTime]';
lb(1:TrainNum*2,1)=[MinHeadwayTime MinHeadwayTime]';
ub(TrainNum*2+1:TrainNum*2+TotalStopTimes*2,1)=[MaxDwellTimeMat MaxDwellTimeMat]';
lb(TrainNum*2+1:TrainNum*2+TotalStopTimes*2,1)=[MinDwellTimeMat MinDwellTimeMat]';
ub(TrainNum*2+TotalStopTimes*2+1:TrainNum*2+TotalStopTimes*2+TotalSections*2,1)=MaxRunTimeMat';
lb(TrainNum*2+TotalStopTimes*2+1:TrainNum*2+TotalStopTimes*2+TotalSections*2,1)=MinRunTimeMat';
PlanDown=[4 2 3 1 5 6 7 8 9 10]';
PlanUp=[4 2 3 1 5 6 7 8 9 10]';
ub(TrainNum*2+TotalStopTimes*2+TotalSections*2+1:Col_of_Individual,1)=[PlanDown; PlanUp];
lb(TrainNum*2+TotalStopTimes*2+TotalSections*2+1:Col_of_Individual,1)=[PlanDown; PlanUp];
options=gaoptimset('PopulationSize',500,'CrossOverFraction',0.8,'Generations',1000);
IntCon=1:1:Col_of_Individual;
[x_best,fval]=ga(fun,nvars,A,b,Aeq,beq,lb,ub,[],IntCon,options);  
xlswrite('��͵��-GA������Ž�?',x_best,1);

%% PSO����
tic
[Population_PSO]=InitPopulationPSO();
BestIndividualFromGa=xlsread('��͵��_GA������Ž�?',1);
Population_PSO(:,:,1)=BestIndividualFromGa;
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
    %ÿ�����Ӿ���������ʷ��õ�?
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
    
    %Ⱥ����������������������õĵ�?
    disp('������ʷ��������')
    if Ranked_Fitness(1,1)<BestFitness_Global(1,1)
        BestFitness_Global(1,1)=Ranked_Fitness(1,1);
        BestParticle_Global=RankedPop(:,:,1);
    end
    
    disp('��ʷ����������Ӧ��')
    disp(BestFitness_Global(1,1))
    disp(' ')
    
    if BestFitness_Global(1,1)<5e4
        break;
    else
        [Population_Moved,AllVelocity_After]=UpdatePositionOfPopulation(Population,AllInitVelocity,BestParticle_Individual,BestParticle_Global,IterationNum);%����PSO
    end
    Population_PSO=Population_Moved;
    IterationNum=IterationNum+1;
    AllInitVelocity=AllVelocity_After;
    if IterationNum>=IterMaxPSO%ͣ��׼��2���ﵽ��������3
        break;
    end
    toc;
end
xlswrite('�������վ�����ʹ��Ž�?6_22',BestParticle_Global,1);
