function [VelocityForTotalPopulation]=InitVelocityForTotalPopulation_PSO(Population)
%% ����򳤶��й�
global TrainNum;%�г��� 
global TotalStopTimes;
global TotalSections;
global PSOPopSize;
VelocityForTotalPopulation=zeros(1,TrainNum*2+TotalStopTimes*2+TotalSections*2,PSOPopSize);


for i=1:1:PSOPopSize
    VelocityForTotalPopulation(:,:,i)=InitVelocity_PSO(Population(:,:,i));
end
end