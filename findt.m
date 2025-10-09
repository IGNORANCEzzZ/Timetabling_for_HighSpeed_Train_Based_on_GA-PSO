function [t]=findt(StartStation,EndStation,sheet,StationNum,Up)
%% ��������������ʱ

%%
global Station;
global OptimizationData;
%   a=strsplit(Section,'-');
%   row=str2double(cell2mat(a(1,1)));
%   col=str2double(cell2mat(a(1,2)));

row=StartStation;
col=EndStation;

% 安全检查：确保索引不超出边界
if isempty(OptimizationData{row,col})
    error('OptimizationData{%d,%d} 为空，请检查数据初始化', row, col);
end

% 获取可用的数据集数量
available_sheets = length(OptimizationData{row,col});
if sheet > available_sheets
    warning('请求的sheet索引 %d 超出可用范围 %d，使用最后一个可用的数据集', sheet, available_sheets);
    sheet = available_sheets;
end

DataforOneSection = OptimizationData{row,col}{1,sheet};
t=0;
t0=0;
t1=0;
Glb=0;
Glb_last=0;

 if StationNum~=row
     Glb=Station(StationNum);
     if Up
         Glb_last=Station(StationNum+1);
     else
         Glb_last=Station(StationNum-1);
     end
 end
 for i=2:1:length(DataforOneSection)
     if Up
         if Glb<=DataforOneSection(i-1,2) & Glb>=DataforOneSection(i,2)
             t1=DataforOneSection(i,1);
             break;
         end
     else
         if Glb>=DataforOneSection(i-1,2) & Glb<=DataforOneSection(i,2)
             t1=DataforOneSection(i,1);
             break;
         end
     end
 end
 for i=2:1:length(DataforOneSection)
     if Up
         if Glb_last<=DataforOneSection(i-1,2) & Glb_last>=DataforOneSection(i,2)
             t0=DataforOneSection(i,1);
             break;
         end
     else
         if Glb_last>=DataforOneSection(i-1,2) & Glb_last<=DataforOneSection(i,2)
             t0=DataforOneSection(i,1);
             break;
         end
     end
 end
 
 t=t1-t0;
 if StationNum==col
     t=DataforOneSection(end,1)-t0;
 end
 if StationNum==row
      t=DataforOneSection(1,1);
 end
end