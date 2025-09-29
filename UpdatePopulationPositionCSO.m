function [Population_Moved,Velocity_After]=UpdatePopulationPositionCSO(Population,AllFitness,Velocity_Before)
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
%% 
global Num_Parts;%分成Num_Parts个小组
global PSOPopSize;
global Col_of_Individual;%一个个体的染色体数量=开行车数*2+开行方案种的停站次数*2+开行方案中的区间数*2
global fai;
SizePerPart=PSOPopSize/Num_Parts;%每个part的个体数
PartilcesInAllPart=cell(1,Num_Parts);%所有part
RandomSequence=randperm(PSOPopSize);%随机序列
Population_Moved=zeros(1,Col_of_Individual,PSOPopSize);%更新后的种群
Velocity_After=zeros(1,TrainNum*2+TotalStopTimes*2+TotalSections*2,PSOPopSize);
AveragePopulationPosition=sum(Population,3)/PSOPopSize;%整个种群的平均位置

%% 将种群随机分成Num_Parts组
for i=1:1:Num_Parts 
    PartilcesInEachPart=zeros(1,Col_of_Individual,SizePerPart);
    for j=1:1:SizePerPart
        PartilcesInEachPart(:,:,j)=Population(:,:,RandomSequence(1,j+SizePerPart*(i-1)));
    end
    PartilcesInAllPart{1,i}=PartilcesInEachPart;
end
    PosMat=zeros(Num_Parts,SizePerPart);
    for i=1:1:Num_Parts
       PosMat(i,:)=randperm(SizePerPart); %从每组中随机取出去的顺序
    end
%% 位置更新-竞争进化策略
for k=1:1:SizePerPart
    R1_k=rand;
    R2_k=rand;
    R3_k=rand;
%     PosMat=randi([1,SizePerPart+1-k],1,Num_Parts);%选取每个part中的下角标为此矩阵元素的个体
    OrinPosMat=zeros(1,Num_Parts);%被选中的每个个体在原三维矩阵中的位置
    FitnessMat=zeros(1,Num_Parts);%被选中的每个个体的适应度
    ParticlesMat=zeros(1,Col_of_Individual,Num_Parts);%被选中的个体
    MovedParticlesMat=zeros(1,Col_of_Individual,Num_Parts);%被选中的个体更新之后
    VelocityMat=zeros(1,TrainNum*2+TotalStopTimes*2+TotalSections*2,Num_Parts);%被选中的个体的初始速度
    VelocityAfterMat=zeros(1,TrainNum*2+TotalStopTimes*2+TotalSections*2,Num_Parts);%被选中个体的更新速度
    for i=1:1:Num_Parts
        OrinPosMat(1,i)=RandomSequence(1,PosMat(i,k)+SizePerPart*(i-1));%被选中的每个个体在原三维矩阵中的位置
        FitnessMat(1,i)=AllFitness(1,OrinPosMat(1,i));%被选中的每个个体的适应度
        ParticlesMat(:,:,i)=PartilcesInAllPart{1,i}(:,:,PosMat(i,k));%被选中的个体
        VelocityMat(:,:,i)=Velocity_Before(:,:,OrinPosMat(1,i));%被选中的个体的初速度
%         PartilcesInAllPart{1,i}(:,:,PosMat(i,k))=[];    % 删掉已经被选中的个体
    end

    [~,index]=min(FitnessMat);
    for i=1:1:Num_Parts%更新这几个个体
        if i==index
            MovedParticlesMat(:,:,i)=ParticlesMat(:,:,i);
        else
            MovedParticlesMat(:,:,i)=ParticlesMat(:,:,i);
            VelocityAfterMat(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2,i)= R1_k.*VelocityMat(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2,i)+R2_k.*(ParticlesMat(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2,index)-ParticlesMat(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2,i))+(fai*R3_k).*(AveragePopulationPosition(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2)-ParticlesMat(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2,i));
            MovedParticlesMat(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2,i)=round(MovedParticlesMat(1,1:TrainNum*2+TotalStopTimes*2+TotalSections*2,i)+VelocityAfterMat(:,:,i));
        end
        Population_Moved(:,:,OrinPosMat(1,i))=MovedParticlesMat(:,:,i);
        Velocity_After(:,:,OrinPosMat(1,i))=VelocityMat(:,:,i);
    end  
end
%% 约束处理（更新后超范围修正）
UpLimit=[MaxHeadwayTime MaxHeadwayTime MaxDwellTimeMat MaxDwellTimeMat MaxRunTimeMat];
LowerLimit=[MinHeadwayTime MinHeadwayTime MinDwellTimeMat MinDwellTimeMat MinRunTimeMat];
for j=1:1:PSOPopSize
    for i=1:1:TrainNum*2+TotalStopTimes*2+TotalSections*2
        if Population_Moved(1,i,j)>UpLimit(1,i)
            Population_Moved(1,i,j)=UpLimit(1,i);
        end
        if Population_Moved(1,i,j)<LowerLimit(1,i)
           Population_Moved(1,i,j)=LowerLimit(1,i);
        end
    end
end
end