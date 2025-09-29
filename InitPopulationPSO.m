function [Population_PSO]=InitPopulationPSO()
global PSOPopSize;
global Col_of_Individual;%一个个体的染色体数量=开行车数*2+开行方案种的停站次数*2+开行方案中的区间数*2
% Population_PSO=cell(1,PSOPopSize);
% Para=ones(1,PSOPopSize);
% Population_PSO=arrayfun(@InitIndividual,Para,'un',0);

Population_PSO=zeros(1,Col_of_Individual,PSOPopSize);
for i=1:1:PSOPopSize
    Population_PSO(:,:,i)=InitIndividual(1);
end
end