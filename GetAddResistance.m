function [wj]=GetAddResistance(glb,IsUp)
%% ����
%glb������꣬��λ��m
%IsUp:�Ƿ�����
%% ���
% wj����·������������λKN
%%
M=440;
g=9.81;

Gradient=xlsread('��·����','�¶�');
Curve=xlsread('��·����','����');
[row_Gradient,col_Gradient]=size(Gradient);
[row_Curve,col_Curve]=size(Curve);

gradient=0;
curve=0;
for i=1:1:row_Gradient
    if glb>=Gradient(i,1) && glb<Gradient(i,3)
        if IsUp
        gradient=-Gradient(i,2);
        else
          gradient=Gradient(i,2);  
        end
        break;
    end
    if glb==Gradient(end,3)
        if IsUp
            gradient=-Gradient(end,2);
        else
            gradient=Gradient(end,2);
        end
        break;
    end
end

for i=1:1:row_Curve
    if glb>=Curve(i,1) && glb<Curve(i,3)
        curve=Curve(i,2);
        break;
    end
    if glb==Curve(end,3)
        curve=Curve(end,2);
        break;
    end
end

if curve==0
    wj=gradient*M*g*10^-3;
else
    wj=(gradient+600/curve)*M*g*10^-3;%��λkN
end