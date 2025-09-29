function [count_P,count_G,tabu_P,tabu_G]=UpdateTabuState(count_P_before,Count_G_before,Pbest_before,Pbest_after,Gbest_before,Gbest_after)

global T_tabu;
global T_free;
%����һ�ε���û�и��£�count_P(i,j)=count_P(i,j)+1,count_G(i,j)=count_G(i,j)+1һ��������һ�Σ���count_P(i,j),count_G(i,j)����Ϊ0
count_P=(Pbest_after==Pbest_before).*(count_P_before+1)+(Pbest_after~=Pbest_before).*(0);
count_G=(Gbest_after==Gbest_before).*(Count_G_before+1)+(Gbest_after~=Gbest_before).*(0);

%��count_P(i,j) =T1,��������ʷ����λ����ά��j��T1��û�е�������tabu_P(i,j)=1,����ά���ϵ�λ�ý����ڽ���״̬����count_P(i,j) =T1+T2���ֹ���T2�ε�������ά�Ȼ�û�и��£���tabu_P(i,j)����Ϊ0
%count_P(i,j)Ҳ����Ϊ0
tabu_P=(count_P<T_tabu).*(0)+(count_P>=T_tabu & count_P<T_tabu+T_free).*(1)+(count_P>=T_tabu+T_free).*(0);
tabu_G=(count_G<T_tabu).*(0)+(count_G>=T_tabu & count_G<T_tabu+T_free).*(1)+(count_G>=T_tabu+T_free).*(0);

disp(sum(sum(tabu_P)))
disp(sum(sum(tabu_G)))

count_P=(count_P<T_tabu+T_free).*(count_P)+(count_P>=T_tabu+T_free).*(0);
count_G=(count_G<T_tabu+T_free).*(count_G)+(count_G>=T_tabu+T_free).*(0);


end