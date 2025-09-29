function [Population_GA]=InitPopulationGA()
global GAPopSize;
Population_GA=cell(GAPopSize,1);
Para=ones(1,GAPopSize);
Population_GA=arrayfun(@InitIndividual,Para,'un',0);
end