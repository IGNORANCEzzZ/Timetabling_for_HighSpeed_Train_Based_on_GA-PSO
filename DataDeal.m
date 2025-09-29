% 处理动态规划得到的单车优化原始数据
%% 删除相同时间的项（同一秒）-plan1
sheet=[1 2 3 4 5 6 7 8 9 10];
for z=1:1:length(sheet)
driver_1_2_20=xlsread('Plan1+20s',sheet(1,z));
[row12,col12]=size(driver_1_2_20);
index=0;
index_mat=[];
for i=2:1:row12
    if floor(driver_1_2_20(i,1))==floor(driver_1_2_20(i-1,1))
        index=index+1;
        index_mat(1,index)=i;
    end
end
driver_1_2_20(index_mat,:)=[];
xlswrite('Plan1+20s(删除重复时间)',driver_1_2_20,sheet(1,z));
end
%% 删除相同时间的项（同一秒）-plan2
sheet=[1 2 3 4 5 6];
for z=1:1:length(sheet)
driver_1_2_20=xlsread('Plan2+20s',sheet(1,z));
[row12,col12]=size(driver_1_2_20);
index=0;
index_mat=[];
for i=2:1:row12
    if floor(driver_1_2_20(i,1))==floor(driver_1_2_20(i-1,1))
        index=index+1;
        index_mat(1,index)=i;
    end
end
driver_1_2_20(index_mat,:)=[];
xlswrite('Plan2+20s(删除重复时间)',driver_1_2_20,sheet(1,z));
end
%% 删除相同时间的项（同一秒）-plan3
sheet=[1 2 3 4 5];
for z=1:1:length(sheet)
driver_1_2_20=xlsread('Plan3+20s',sheet(1,z));
[row12,col12]=size(driver_1_2_20);
index=0;
index_mat=[];
for i=2:1:row12
    if floor(driver_1_2_20(i,1))==floor(driver_1_2_20(i-1,1))
        index=index+1;
        index_mat(1,index)=i;
    end
end
driver_1_2_20(index_mat,:)=[];
xlswrite('Plan3+20s(删除重复时间)',driver_1_2_20,sheet(1,z));
end
%% 对缺少的时间进行插值-plan1
sheet=[1 2 3 4 5 6 7 8 9 10];
for z=1:1:10
driver_1_2_20=xlsread('Plan1+20s(删除重复时间)',sheet(1,z));
[row12,col12]=size(driver_1_2_20);

row_should=driver_1_2_20(end,1);
row_should=floor(row_should)+1;
driver_after=zeros(row_should,col12);

 driver_after(1,:)=driver_1_2_20(1,:);
 index=1;
 for i=2:1:row12
     if floor(driver_1_2_20(i,1))-floor(driver_1_2_20(i-1,1))>1
         n=ceil(driver_1_2_20(i,1)-driver_1_2_20(i-1,1));
         timedivide_n=(driver_1_2_20(i,1)-driver_1_2_20(i-1,1))/n;
%          posdivide_n=(driver_1_2_20(i,2)-driver_1_2_20(i-1,2))/n;
         speeddivide_n=(driver_1_2_20(i,3)-driver_1_2_20(i-1,3))/n;
         forcedivide_n=(driver_1_2_20(i,4)-driver_1_2_20(i-1,4))/n;
         for j=1:1:n
             index=index+1;
             driver_after(index,3)=driver_1_2_20(i-1,3)+j*speeddivide_n;
             driver_after(index,4)=driver_1_2_20(i-1,4)+j*forcedivide_n;
             driver_after(index,6)=driver_1_2_20(i-1,6);
             driver_after(index,1)=driver_1_2_20(i-1,1)+j*timedivide_n;
             if j~=n
                 driver_after(index,2)=driver_after(index-1,2)+(driver_after(index,1)-driver_after(index-1,1))*0.5*(driver_after(index,3)+driver_after(index-1,3));
             else
                 driver_after(index,2)=driver_1_2_20(i,2);
             end
         end
     else
         index=index+1;
         driver_after(index,:)=driver_1_2_20(i,:);
     end    
 end

 %删除相同的项
[row12,col12]=size(driver_after);
index=0;
index_mat=[];
for i=2:1:row12
    if floor(driver_after(i,1))==floor(driver_after(i-1,1))
        index=index+1;
        index_mat(1,index)=i;
    end
end
driver_after(index_mat,:)=[];

% 重新计算每个时刻的功率
[row_after,col_after]=size(driver_after);
for i=1:1:row_after-1
    driver_after(i,5)=(driver_after(i+1,3)+driver_after(i,3))/2*driver_after(i,4)/0.9;
end
driver_after(end,5)=(0+driver_after(end,3))/2*driver_after(end,4)/0.9;

xlswrite('Plan1+20s(插值后)',driver_after,sheet(1,z));
end
%% 对缺少的时间进行插值-plan2
sheet=[1 2 3 4 5 6];
for z=1:1:6
driver_1_2_20=xlsread('Plan2+20s(删除重复时间)',sheet(1,z));
[row12,col12]=size(driver_1_2_20);

row_should=driver_1_2_20(end,1);
row_should=floor(row_should)+1;
driver_after=zeros(row_should,col12);

 driver_after(1,:)=driver_1_2_20(1,:);
 index=1;
 for i=2:1:row12
     if floor(driver_1_2_20(i,1))-floor(driver_1_2_20(i-1,1))>1
         n=ceil(driver_1_2_20(i,1)-driver_1_2_20(i-1,1));
         timedivide_n=(driver_1_2_20(i,1)-driver_1_2_20(i-1,1))/n;
%          posdivide_n=(driver_1_2_20(i,2)-driver_1_2_20(i-1,2))/n;
         speeddivide_n=(driver_1_2_20(i,3)-driver_1_2_20(i-1,3))/n;
         forcedivide_n=(driver_1_2_20(i,4)-driver_1_2_20(i-1,4))/n;
         for j=1:1:n
             index=index+1;
             driver_after(index,3)=driver_1_2_20(i-1,3)+j*speeddivide_n;
             driver_after(index,4)=driver_1_2_20(i-1,4)+j*forcedivide_n;
             driver_after(index,6)=driver_1_2_20(i-1,6);
             driver_after(index,1)=driver_1_2_20(i-1,1)+j*timedivide_n;
             if j~=n
                 driver_after(index,2)=driver_after(index-1,2)+(driver_after(index,1)-driver_after(index-1,1))*0.5*(driver_after(index,3)+driver_after(index-1,3));
             else
                 driver_after(index,2)=driver_1_2_20(i,2);
             end
         end
     else
         index=index+1;
         driver_after(index,:)=driver_1_2_20(i,:);
     end    
 end
 
 %删除相同的项
[row12,col12]=size(driver_after);
index=0;
index_mat=[];
for i=2:1:row12
    if floor(driver_after(i,1))==floor(driver_after(i-1,1))
        index=index+1;
        index_mat(1,index)=i;
    end
end
driver_after(index_mat,:)=[];

% 重新计算每个时刻的功率
[row_after,col_after]=size(driver_after);
for i=1:1:row_after-1
    driver_after(i,5)=(driver_after(i+1,3)+driver_after(i,3))/2*driver_after(i,4)/0.9;
end
driver_after(end,5)=(0+driver_after(end,3))/2*driver_after(end,4)/0.9;

xlswrite('Plan2+20s(插值后)',driver_after,sheet(1,z));
end

%% 对缺少的时间进行插值-plan3
sheet=[1 2 3 4 5];
for z=1:1:5
driver_1_2_20=xlsread('Plan3+20s(删除重复时间)',sheet(1,z));
[row12,col12]=size(driver_1_2_20);
row_should=driver_1_2_20(end,1);
row_should=floor(row_should)+1;
driver_after=zeros(row_should,col12);

 driver_after(1,:)=driver_1_2_20(1,:);
 index=1;
 for i=2:1:row12
     if floor(driver_1_2_20(i,1))-floor(driver_1_2_20(i-1,1))>1
         n=ceil(driver_1_2_20(i,1)-driver_1_2_20(i-1,1));
         timedivide_n=(driver_1_2_20(i,1)-driver_1_2_20(i-1,1))/n;
%          posdivide_n=(driver_1_2_20(i,2)-driver_1_2_20(i-1,2))/n;
         speeddivide_n=(driver_1_2_20(i,3)-driver_1_2_20(i-1,3))/n;
         forcedivide_n=(driver_1_2_20(i,4)-driver_1_2_20(i-1,4))/n;
         for j=1:1:n
             index=index+1;
             driver_after(index,3)=driver_1_2_20(i-1,3)+j*speeddivide_n;
             driver_after(index,4)=driver_1_2_20(i-1,4)+j*forcedivide_n;
             driver_after(index,6)=driver_1_2_20(i-1,6);
             driver_after(index,1)=driver_1_2_20(i-1,1)+j*timedivide_n;
             if j~=n
                 driver_after(index,2)=driver_after(index-1,2)+(driver_after(index,1)-driver_after(index-1,1))*0.5*(driver_after(index,3)+driver_after(index-1,3));
             else
                 driver_after(index,2)=driver_1_2_20(i,2);
             end
         end
     else
         index=index+1;
         driver_after(index,:)=driver_1_2_20(i,:);
     end    
 end
 
 %删除相同的项
[row12,col12]=size(driver_after);
index=0;
index_mat=[];
for i=2:1:row12
    if floor(driver_after(i,1))==floor(driver_after(i-1,1))
        index=index+1;
        index_mat(1,index)=i;
    end
end
driver_after(index_mat,:)=[];

% 重新计算每个时刻的功率
[row_after,col_after]=size(driver_after);
for i=1:1:row_after-1
    driver_after(i,5)=(driver_after(i+1,3)+driver_after(i,3))/2*driver_after(i,4)/0.9;
end
driver_after(end,5)=(0+driver_after(end,3))/2*driver_after(end,4)/0.9;

xlswrite('Plan3+20s(插值后)',driver_after,sheet(1,z));
end