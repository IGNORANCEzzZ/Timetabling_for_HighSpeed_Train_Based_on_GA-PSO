function [Population_Moved,AllVelocity_After]=UpdatePositionOfPopulation(Population,AllInitVelocity,BestParticle_Individual,BestParticle_Global,Iter)
global PSOPopSize;
global TrainNum;%�г��� 
global TotalStopTimes;
global TotalSections;
global Col_of_Individual;%һ�������Ⱦɫ������=���г���*2+���з����ֵ�ͣվ����*2+���з����е�������*2

Population_Moved=zeros(1,Col_of_Individual,PSOPopSize);
AllVelocity_After=zeros(1,TrainNum*2+TotalStopTimes*2+TotalSections*2,PSOPopSize);

[row, ~]=size(BestParticle_Global);
BestParticle_Global=sum(BestParticle_Global,1)/row;
for i=1:1:PSOPopSize
   [Population_Moved(:,:,i),AllVelocity_After(:,:,i)]=UpdatePositionPSO(Population(:,:,i),AllInitVelocity(:,:,i),BestParticle_Individual(:,:,i),BestParticle_Global,Iter);
end

end