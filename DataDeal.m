% ����̬�滮�õ��ĵ����Ż�ԭʼ����
%% ɾ����ͬʱ����ͬһ�룩-plan1
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
xlswrite('Plan1+20s(ɾ���ظ�ʱ��)',driver_1_2_20,sheet(1,z));
end
%% ɾ����ͬʱ����ͬһ�룩-plan2
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
xlswrite('Plan2+20s(ɾ���ظ�ʱ��)',driver_1_2_20,sheet(1,z));
end
%% ɾ����ͬʱ����ͬһ�룩-plan3
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
xlswrite('Plan3+20s(ɾ���ظ�ʱ��)',driver_1_2_20,sheet(1,z));
end
%% ��ȱ�ٵ�ʱ����в�ֵ-plan1
sheet=[1 2 3 4 5 6 7 8 9 10];
for z=1:1:10
driver_1_2_20=xlsread('Plan1+20s(ɾ���ظ�ʱ��)',sheet(1,z));
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

 %ɾ����ͬ����
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

% ���¼���ÿ��ʱ�̵Ĺ���
[row_after,col_after]=size(driver_after);
for i=1:1:row_after-1
    driver_after(i,5)=(driver_after(i+1,3)+driver_after(i,3))/2*driver_after(i,4)/0.9;
end
driver_after(end,5)=(0+driver_after(end,3))/2*driver_after(end,4)/0.9;

xlswrite('Plan1+20s(��ֵ��)',driver_after,sheet(1,z));
end
%% ��ȱ�ٵ�ʱ����в�ֵ-plan2
sheet=[1 2 3 4 5 6];
for z=1:1:6
driver_1_2_20=xlsread('Plan2+20s(ɾ���ظ�ʱ��)',sheet(1,z));
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
 
 %ɾ����ͬ����
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

% ���¼���ÿ��ʱ�̵Ĺ���
[row_after,col_after]=size(driver_after);
for i=1:1:row_after-1
    driver_after(i,5)=(driver_after(i+1,3)+driver_after(i,3))/2*driver_after(i,4)/0.9;
end
driver_after(end,5)=(0+driver_after(end,3))/2*driver_after(end,4)/0.9;

xlswrite('Plan2+20s(��ֵ��)',driver_after,sheet(1,z));
end

%% ��ȱ�ٵ�ʱ����в�ֵ-plan3
sheet=[1 2 3 4 5];
for z=1:1:5
driver_1_2_20=xlsread('Plan3+20s(ɾ���ظ�ʱ��)',sheet(1,z));
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
 
 %ɾ����ͬ����
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

% ���¼���ÿ��ʱ�̵Ĺ���
[row_after,col_after]=size(driver_after);
for i=1:1:row_after-1
    driver_after(i,5)=(driver_after(i+1,3)+driver_after(i,3))/2*driver_after(i,4)/0.9;
end
driver_after(end,5)=(0+driver_after(end,3))/2*driver_after(end,4)/0.9;

xlswrite('Plan3+20s(��ֵ��)',driver_after,sheet(1,z));
end