function [Population_Moved,AllVelocity_After]=UpdatePositionOfPopulation(Population,AllInitVelocity,BestParticle_Individual,BestParticle_Global,Iter)
global PSOPopSize;
global TrainNum;%列车数 
global TotalStopTimes;
global TotalSections;
global Col_of_Individual;%一个个体的染色体数量=开行车数*2+开行方案种的停站次数*2+开行方案中的区间数*2

Population_Moved=zeros(1,Col_of_Individual,PSOPopSize);
AllVelocity_After=zeros(1,TrainNum*2+TotalStopTimes*2+TotalSections*2,PSOPopSize);

[row, ~]=size(BestParticle_Global);
BestParticle_Global=sum(BestParticle_Global,1)/row;
for i=1:1:PSOPopSize
   [Population_Moved(:,:,i),AllVelocity_After(:,:,i)]=UpdatePositionPSO(Population(:,:,i),AllInitVelocity(:,:,i),BestParticle_Individual(:,:,i),BestParticle_Global,Iter);
end

end