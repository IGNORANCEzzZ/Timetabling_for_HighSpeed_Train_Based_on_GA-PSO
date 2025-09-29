function [count_P,count_G,tabu_P,tabu_G]=UpdateTabuState(count_P_before,Count_G_before,Pbest_before,Pbest_after,Gbest_before,Gbest_after)

global T_tabu;
global T_free;
%过了一次迭代没有更新，count_P(i,j)=count_P(i,j)+1,count_G(i,j)=count_G(i,j)+1一旦更新了一次，则count_P(i,j),count_G(i,j)重置为0
count_P=(Pbest_after==Pbest_before).*(count_P_before+1)+(Pbest_after~=Pbest_before).*(0);
count_G=(Gbest_after==Gbest_before).*(Count_G_before+1)+(Gbest_after~=Gbest_before).*(0);

%当count_P(i,j) =T1,即个体历史最优位置在维度j上T1次没有迭代，则tabu_P(i,j)=1,即该维度上的位置将处于禁忌状态。当count_P(i,j) =T1+T2即又过了T2次迭代，该维度还没有更新，则将tabu_P(i,j)重置为0
%count_P(i,j)也重置为0
tabu_P=(count_P<T_tabu).*(0)+(count_P>=T_tabu & count_P<T_tabu+T_free).*(1)+(count_P>=T_tabu+T_free).*(0);
tabu_G=(count_G<T_tabu).*(0)+(count_G>=T_tabu & count_G<T_tabu+T_free).*(1)+(count_G>=T_tabu+T_free).*(0);

disp(sum(sum(tabu_P)))
disp(sum(sum(tabu_G)))

count_P=(count_P<T_tabu+T_free).*(count_P)+(count_P>=T_tabu+T_free).*(0);
count_G=(count_G<T_tabu+T_free).*(count_G)+(count_G>=T_tabu+T_free).*(0);


end