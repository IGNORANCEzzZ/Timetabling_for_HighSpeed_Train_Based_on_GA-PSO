function [Population_PSO]=InitPopulationPSO()
global PSOPopSize;
global Col_of_Individual;%һ�������Ⱦɫ������=���г���*2+���з����ֵ�ͣվ����*2+���з����е�������*2
% Population_PSO=cell(1,PSOPopSize);
% Para=ones(1,PSOPopSize);
% Population_PSO=arrayfun(@InitIndividual,Para,'un',0);

Population_PSO=zeros(1,Col_of_Individual,PSOPopSize);
for i=1:1:PSOPopSize
    Population_PSO(:,:,i)=InitIndividual(1);
end
end