function [Population_Moved,Velocity_After]=UpdatePopulationPositionCSO(Population,AllFitness,Velocity_Before)
%% ����򳤶��й�
global TrainNum;%�г��� 
global TotalStopTimes;
global TotalSections;
%% ��Լ���й�
global MaxDwellTimeMat;%MaxDwellTimeMat=zeros(1,TotalStopTimes);
global MinDwellTimeMat;%MinDwellTimeMat=zeros(1,TotalStopTimes);
global MaxHeadwayTime;%MaxHeadwayTime=150*ones(1,TrainNum);
global MinHeadwayTime;%MinHeadwayTime=200*ones(1,TrainNum);
global MaxRunTimeMat;%MaxRunTimeMat=ones(1,2*TotalSections);
global MinRunTimeMat;%MinRunTimeMat=ones(1,2*TotalSections);
%% 
global Num_Parts;%�ֳ�Num_Parts��С��
global PSOPopSize;
global Col_of_Individual;%һ�������Ⱦɫ������=���г���*2+���з����ֵ�ͣվ����*2+���з����е�������*2
global fai;
SizePerPart=PSOPopSize/Num_Parts;%ÿ��part�ĸ�����
PartilcesInAllPart=cell(1,Num_Parts);%����part
RandomSequence=randperm(PSOPopSize);%�������
Population_Moved=zeros(1,Col_of_Individual,PSOPopSize);%���º����Ⱥ
Velocity_After=zeros(1,TrainNum*2+TotalStopTimes*2+TotalSections*2,PSOPopSize);
AveragePopulationPosition=sum(Population,3)/PSOPopSize;%������Ⱥ��ƽ��λ��

%% ����Ⱥ����ֳ�Num_Parts��
for i=1:1:Num_Parts 
    PartilcesInEachPart=zeros(1,Col_of_Individual,SizePerPart);
    for j=1:1:SizePerPart
        PartilcesInEachPart(:,:,j)=Population(:,:,RandomSequence(1,j+SizePerPart*(i-1)));
    end
    PartilcesInAllPart{1,i}=PartilcesInEachPart;
end
    PosMat=zeros(Num_Parts,SizePerPart);
    for i=1:1:Num_Parts
       PosMat(i,:)=randperm(SizePerPart); %��ÿ�������ȡ��ȥ��˳��
    end
%% λ�ø���-������������
for k=1:1:SizePerPart
    R1_k=rand;
    R2_k=rand;
    R3_k=rand;
%     PosMat=randi([1,SizePerPart+1-k],1,Num_Parts);%ѡȡÿ��part�е��½Ǳ�Ϊ�˾���Ԫ�صĸ���
    OrinPosMat=zeros(1,Num_Parts);%��ѡ�е�ÿ��������ԭ��ά�����е�λ��
    FitnessMat=zeros(1,Num_Parts);%��ѡ�е�ÿ���������Ӧ��
    ParticlesMat=zeros(1,Col_of_Individual,Num_Parts);%��ѡ�еĸ���
    MovedParticlesMat=zeros(1,Col_of_Individual,Num_Parts);%��ѡ�еĸ������֮��
    VelocityMat=zeros(1,TrainNum*2+TotalStopTimes*2+TotalSections*2,Num_Parts);%��ѡ�еĸ���ĳ�ʼ�ٶ�
    VelocityAfterMat=zeros(1,TrainNum*2+TotalStopTimes*2+TotalSections*2,Num_Parts);%��ѡ�и���ĸ����ٶ�
    for i=1:1:Num_Parts
        OrinPosMat(1,i)=RandomSequence(1,PosMat(i,k)+SizePerPart*(i-1));%��ѡ�е�ÿ��������ԭ��ά�����е�λ��
        FitnessMat(1,i)=AllFitness(1,OrinPosMat(1,i));%��ѡ�е�ÿ���������Ӧ��
        ParticlesMat(:,:,i)=PartilcesInAllPart{1,i}(:,:,PosMat(i,k));%��ѡ�еĸ���
        VelocityMat(:,:,i)=Velocity_Before(:,:,OrinPosMat(1,i));%��ѡ�еĸ���ĳ��ٶ�
%         PartilcesInAllPart{1,i}(:,:,PosMat(i,k))=[];    % ɾ���Ѿ���ѡ�еĸ���
    end

    [~,index]=min(FitnessMat);
    for i=1:1:Num_Parts%�����⼸������
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
%% Լ���������º󳬷�Χ������
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