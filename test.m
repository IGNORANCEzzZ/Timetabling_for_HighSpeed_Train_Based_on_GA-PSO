clc;
Global;
tic
[Individual]=InitIndividual(1);
[Fitness,TravelTimeDeviation,ServerTimeDeviation,GLB_Time,NoSaftyDistance,TotalTracEnergyAfterReg,TotalBrakEnergyAfterReg,TotalTracE_NoReg,TotalBrakE_NoReg,Power_Time_Trac_sum,Power_Time_Brak_sum,Power_Time_TracAfterReg,Power_Time_BrakAfterReg]= FitnessCalc(Individual);
TracEDecrease=abs(TotalTracE_NoReg-TotalTracEnergyAfterReg);
BrakEDcrease=abs(TotalBrakE_NoReg-TotalBrakEnergyAfterReg);
Eta=TracEDecrease/TotalTracE_NoReg*100;
disp(TracEDecrease)
disp(BrakEDcrease)
disp(Eta)
a=(GLB_Time==0).*(GLB_Time);
disp(sum(sum(a)))
toc;
%% plot
% Power_Time_T=array2table(Power_Time');
% writetable(Power_Time_T,'功率-区段-时间-车次矩阵.xlsx','Sheet',1,'Range','A1:CV36000')
% 
% Section_Time_T=array2table(Section_Time');
% writetable(Section_Time_T,'功率-区段-时间-车次矩阵.xlsx','Sheet',2,'Range','A1:CV36000')
t=1:1:length(Power_Time);
figure(1)
plot(t,Power_Time_Trac_sum,'r','Linewidth',2);
hold on 
plot(t,Power_Time_TracAfterReg,'g','Linewidth',0.5);

figure(2)
plot(t,Power_Time_Brak_sum,'r','Linewidth',1.5);
hold on
plot(t,Power_Time_BrakAfterReg,'g','Linewidth',1.5);

%% matlab 函数功能测试
% Plan=randi([1,3],10,10);
% [r,c]=find(Plan==1);
% 
% plan2=zeros(10,10);
% 
% for i=1:1:length(r)
%     plan2(r(i),c(i))=Plan(r(i),c(i));
% end

% Plan=randi([-3,3],10,10);
% Plan_Positive=(Plan>0).*(Plan);
% Plan_Negative=(Plan<0).*(Plan);
% 
% Plan_sum=sum(Plan);
% Plan_Positive_sum=sum(Plan_Positive);
% Plan_Negative_sum=sum(Plan_Negative);
% E=sum(Plan_sum,2).*(Plan_sum>0);

[Population_PSO]=InitPopulationPSO();
Allfitness=cell(1,length(Population_PSO));
for i=1:1:length(Population_PSO)
    disp(i)
[Fitness,~,~,~,~,~,~,~,~,~]= FitnessCalc(Population_PSO{1,i});
Allfitness{1,i}=Fitness;
end


D3Mat=zeros(6,6,6);
a=ones(6,6);
b=2*ones(6,6);
c=3*ones(6,6);
d=4*ones(6,6);
e=5*ones(6,6);
f=6*ones(6,6);
D3Mat(:,:,1)=b;
D3Mat(:,:,2)=d;
D3Mat(:,:,3)=a;
D3Mat(:,:,4)=f;
D3Mat(:,:,5)=c;
D3Mat(:,:,6)=e;
paxu=[2 4 1 6 3 5];
[ranked,ind]=sort(paxu);
ranked_mat=D3Mat(:,:,ind);


a=randi([1 100],6,6);
disp(a)
r=[1 2 3 4 5 6]';
rank=[r,r,r,r,r,r];
disp(rank)

[a(1:3,:),ind1]=sort(a(1:3,:),1);
rank(1:3,:)=rank(ind1);

[a(4:6,:),ind2]=sort(a(4:6,:),1,'descend');
rank(4:6,:)=rank(ind2+3);

disp(a)
disp(rank)


a=randi([120 1200],1,236,500);
c=a(1,1:216,1);
b=reshape(a (:,1:216,:),[216 500]);
b=b';



Pb=randi([1 5],6,6);
Pa=randi([1 5],6,6);

Cb=zeros(6,6);
Ca=(Pb==Pa).*(Cb+1)+(Cb);
Ta=(Ca>=1).*(1)+(0);


vnext=zeros(6,6);
w=0.5;
v=randi([1 10],6,6);
c1=2;
c2=2;
rand1=rand;
rand2=rand;
x=randi([1 10],6,6);
pbest=randi([1 10],6,6);
gbest=randi([1 10],1,6);
gbestMat=repmat(gbest,6,1);

tabu_G=randi([0 1],1,6);
tabu_GMat=repmat(tabu_G,6,1);
vnext1=(tabu_GMat==0).*(w.*v+c1*rand1.*(pbest-x)+ c2*rand2.*(gbestMat-x))+(tabu_GMat==1).*(gbestMat-x);
xnext=x+vnext1;


rand1=randi([1 10],6,6);
rand2=randi([1 10],6,6);
c=rand1.*rand2;
x_span=randi([8 10],1,6);
x_spanMat=repmat(x_span,6,1);

z=exp(-abs(pbest-xnext)./x_spanMat);

a=randi([1 10],6,6);
disp(a)
b=randi([1 10],6,6);
disp(b)

[a(1:3,:),rank1]=sort(a(1:3,:),1);
disp(a)
for i=1:1:6
    b(1:3,i)=b(rank1(:,i),i);
end
disp(b)

[a(4:6,:),rank2]=sort(a(4:6,:),1,'descend');
disp(a)
for i=1:1:6
    b(4:6,i)=b(rank2(:,i)+3,i);
end
disp(b)