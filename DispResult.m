

% BadIndividual=xlsread('各个变电站电费最低次优解6_23',1);
% BestIndividual=xlsread('电费最低6_22',1);
% 
% BadIndividual=xlsread('各个变电站电费最低次优解6_23',1);
% BestIndividual=xlsread('各个变电站电费最低最终解6_23',1);

BestIndividual=xlsread('电费最低最终解GA+PSO_手动修改上下行',1);
% BestIndividual(1,61)=610;
% BestIndividual(1,83)=400;
% BestIndividual(1,85)=550;
% BestIndividual(1,74)=350;
% BestIndividual(1,45)=300;
% BestIndividual(1,79)=400;
% 
% xlswrite('电费最低最终解GA+PSO_手动修改上行',BestIndividual,1);
% 
% BestIndividual(1,104)=740;
% BestIndividual(1,103)=1000;
% BestIndividual(1,94)=930;
% BestIndividual(1,93)=430;
% BestIndividual(1,39)=600;
% xlswrite('电费最低最终解GA+PSO-手动修改上下行',BestIndividual,1);
%% 解码
[Headway,Dwell_Down,Dwell_Up,Runtime_Down,Runtime_Up,RealTime_Down,RealTime_Up]=DeCoder(BestIndividual);

%% 结果统计
%[Fitness,GLB_Time_NoSort,TotalTracE_NoReg,TotalAuxiE_NoReg,TotalUsedEnergyAfterReg,TotalBrakE_NoReg,TotalBrakEnergyAfterReg,TotalTracEAfterAux_NoReg,TotalBrakEAfterAux_NoReg,Power_Time_Trac_sum,Power_Time_Brak_sum,Power_Time_TracAfterAux_sum,Power_Time_BrakAfterAux_sum,Power_Time_TracAfterReg,Power_Time_BrakAfterReg]= GAFitnessCalc(BestIndividual);
%[GLB_Time,Velocity_Time,MinBrakeDistance,Distance,IFSaftyDistance,NoSaftyDistance,SaftyDistancePunc]= GAFitnessCalc(BestIndividual);
[GLB_Time_NoSortb,Fitnessb,Costb,C_gridb,C_demb,C_totalb,Cost_gridb,Cost_demb,Power_Time_EachSubStaionNum_AfterRegb,Power_Time_EachSubStaionNum_TracAfterRegb,Power_Time_EachSubStation_BrakAfterRegb]= GAFitnessCalc(BadIndividual);
[GLB_Time_NoSort,Fitness,Cost,C_grid,C_dem,C_total,Cost_grid,Cost_dem,Power_Time_EachSubStaionNum_AfterReg,Power_Time_EachSubStaionNum_TracAfterReg,Power_Time_EachSubStation_BrakAfterReg]= GAFitnessCalc(BestIndividual);

%% 电费
if sum(C_gridb)+sum(C_demb)==Costb && sum(C_grid)+sum(C_dem)==Cost
    disp('各个电站电费相加与总电费一致')
end
C_grid_DeceaseRate=(C_gridb-C_grid)./C_gridb*100;
C_dem_DeceaseRate=(C_demb-C_dem)./C_demb*100;
C_total_DeceaseRate=(C_totalb-C_total)./C_totalb*100;

Cost_gridb_Decrease=(Cost_gridb-Cost_grid)./Cost_gridb*100;
Cost_demb_Decrease=(Cost_demb-Cost_dem)./Cost_demb*100;
Cost_Drease=(Costb-Cost)./Costb*100;

%% 功率分布
[train_numb,length_tb]=size(GLB_Time_NoSortb);
[train_num,length_t]=size(GLB_Time_NoSort);
tb=1:1:length_tb;
t=1:1:length_t;
% 牵引变电所牵引负荷削峰填谷对比（总功率对比）
figure(1)
plot(tb,Power_Time_EachSubStaionNum_AfterRegb(3,:),'-','color',[255/255, 153/255, 51/255],'linewidth',1.5);
line=max(Power_Time_EachSubStaionNum_AfterRegb(3,:))*ones(1,length_tb);
hold on
plot(t,Power_Time_EachSubStaionNum_AfterReg(3,:),'-','color',[0, 102/255, 204/255],'linewidth',1.5);
hold off
title('牵引变电所牵引负荷削峰填谷对比')
xlabel('时间（s）')
ylabel('功率（kw）')
legend('优化前','优化后')

figure(2)
% 牵引变电所需量大小对比（正的牵引功率对比）
plot(tb,Power_Time_EachSubStaionNum_TracAfterRegb(3,:),'-','color',[255/255, 153/255, 51/255],'linewidth',1.5);
hold on
plot(t,Power_Time_EachSubStaionNum_TracAfterReg(3,:),'-','color',[0, 102/255, 204/255],'linewidth',1.5);
hold off
title('牵引变电所需量大小对比')
xlabel('时间（s）')
ylabel('功率（kw）')
legend('优化前','优化后')

figure(3)
% 牵引变电所反馈至电网的反向潮流对比（正的牵引功率对比）
plot(tb,-Power_Time_EachSubStation_BrakAfterRegb(3,:),'-','color',[255/255, 153/255, 51/255],'linewidth',1.5);
hold on
plot(t,-Power_Time_EachSubStation_BrakAfterReg(3,:),'-','color',[0, 102/255, 204/255],'linewidth',1.5);
hold off
title('牵引变电所反馈至电网的反向潮流对比')
xlabel('时间（s）')
ylabel('功率（kw）')
legend('优化前','优化后')
%% 时刻表
A1=12414*ones(1,length_t);
A2=23600*ones(1,length_t);
A3=34142*ones(1,length_t);
A4=43320*ones(1,length_t);
A5=68050*ones(1,length_t);
A6=72500*ones(1,length_t);
A7=89565*ones(1,length_t);
A8=110650*ones(1,length_t);
A9=137950*ones(1,length_t);
A10=164510*ones(1,length_t);
A11=192370*ones(1,length_t);

figure(5)
for i=1:1:train_num/2
    train=GLB_Time_NoSort(i,:);
    plot(t,train,'color',[0/255, 102/255, 255/255],'linewidth',1.5)
    hold on
end
for i=1+train_num/2:1:train_num
    train=GLB_Time_NoSort(i,:);
    plot(t,train,'color',[255/255, 153/255, 51/255],'linewidth',1.5)
    hold on
end
% hold off

figure(7)
for i=1:1:train_num
    train=GLB_Time_NoSort(i,1:20000);
    plot(t(1,1:20000),train,'linewidth',1.5)
    hold on
end
hold off
yticks([12414 23600 34142 43320 68050 72500 89565 110650 137950 164510 192370]);
yticklabels({'A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11'});
set(gca,'YGrid','on','gridlinestyle','--','gridcolor','k','gridalpha',0.7,'linewidth',1.5);
xlabel('时间（s）')
ylabel('车站')
title('节能经济时刻表')