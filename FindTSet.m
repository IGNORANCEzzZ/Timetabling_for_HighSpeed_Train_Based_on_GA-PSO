function [T]=FindTSet(StartStation,EndStation,sheet,Up)
% a=strsplit(Section,'-');
% row=str2double(cell2mat(a(1,1)));
% col=str2double(cell2mat(a(1,2)));
row=StartStation;
col=EndStation;
if Up
    StationNum=row-1:-1:col;
else
    StationNum=row+1:1:col;
end
t=zeros(1,length(StationNum));
for i=1:1:length(StationNum)
t(1,i)=findt(StartStation,EndStation,sheet,StationNum(1,i),Up);
end  
T=t;
end