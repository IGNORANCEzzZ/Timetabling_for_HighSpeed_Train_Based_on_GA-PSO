% �Կռ������ĵ����Ż����ݷ���õ����ٶ�-����-��-λ��-ʱ�����ݽ��в�ֵ���õ�ÿ1���ϵ����ݣ������������������
M=440;
g=9.81;
UP=["11-10","11-9","11-8","11-7","11-4","11-2","10-9","10-7","10-4","9-8","9-5","9-2","8-7","8-5","8-4","7-5","7-4","7-2","5-4","5-2","4-2","4-1","2-1"];
DOWN=["1-2","1-4","2-4","2-5","2-7","2-9","2-11","4-5","4-7","4-8","4-10","4-11","5-7","5-8","5-9","7-8","7-10","7-11","8-9","8-11","9-10","9-11","10-11"];



NameUp=["�Ż�����up+10s","�Ż�����up+20s","�Ż�����up+30s","�Ż�����up+40s","�Ż�����up+1%","�Ż�����up+2%","�Ż�����up+3%","�Ż�����up+4%","�Ż�����up+5%","�Ż�����up+6%","�Ż�����up+7%","�Ż�����up+8%","�Ż�����up+9%","�Ż�����up+10%","�Ż�����up+11%","�Ż�����up+12%","�Ż�����up+13%","�Ż�����up+14%","�Ż�����up+15%","�Ż�����up+16%","�Ż�����up+17%","�Ż�����up+18%","�Ż�����up+19%","�Ż�����up+20%"];
NameDown=["�Ż�����down+10s","�Ż�����down+20s","�Ż�����down+30s","�Ż�����down+40s","�Ż�����down+1%","�Ż�����down+2%","�Ż�����down+3%","�Ż�����down+4%","�Ż�����down+5%","�Ż�����down+6%","�Ż�����down+7%","�Ż�����down+8%","�Ż�����down+9%","�Ż�����down+10%","�Ż�����down+11%","�Ż�����down+12%","�Ż�����down+13%","�Ż�����down+14%","�Ż�����down+15%","�Ż�����down+16%","�Ż�����down+17%","�Ż�����down+18%","�Ż�����down+19%","�Ż�����down+20%"];
for table=5:1:24
 for sheet=1:1:23
 driver=xlsread(NameUp(1,table),sheet);
 plot(driver(:,1),driver(:,3),'b')  
 hold on
 t=0:1:round(driver(end,1));
 t=t';
 speed=interp1(driver(:,1),driver(:,3),t,'pchip');
 plot(t,speed,'r');
 hold off
 
%  s=zeros(length(t),1);
%  s(1,1)=driver(1,2);
%  F=zeros(length(t),1);
%  F(length(t),1)=0;
%  for i=2:1:length(t)
%      a=(speed(1,i)-speed(1,i-1))/(t(1,i)-t(1,i-1));
%      if IsUp
%          s(i,1)=s(i-1,1)-(speed(1,i)^2-speed(1,i-1)^2)/(2*a);
%      else
%          s(i,1)=s(i-1,1)+(speed(1,i)^2-speed(1,i-1)^2)/(2*a);
%      end
%      
%      B=(GetBasicResistance(speed(1,i)*3.6)+GetBasicResistance(speed(1,i-1))*3.6)/2 *M*g;  %����λN
%      w0=(GetAddResistance(s(i-1,1),IsUp));  %��λKN
%      f=M*a+B/1000+w0;
%      F(i-1,1)=f;
%  end
%  driver2=[t' s speed' F];
%  
%  figure(1)
%  plot(driver(:,1),driver(:,4),'b');
%  hold on
%  plot(t,F','g')
 
 f_interp=interp1(driver(:,1),driver(:,4),t,'pchip');
 figure(2)
 plot(driver(:,1),driver(:,4),'b');
 hold on
 plot(t,f_interp,'r');
 
 s_interp=interp1(driver(:,1),driver(:,2),t,'pchip');
 figure(3)
 plot(driver(:,1),driver(:,2),'b')
 hold on 
 plot(t,s_interp,'r')
  
  p_interp=interp1(driver(:,1),driver(:,5),t,'pchip');
  figure(4)
  plot(driver(:,1),driver(:,5),'b')
  hold on 
  plot(t,p_interp,'r')
  
  E_Trac_NoInterp=0;
 for i=1:1:length(driver(:,1))-1
     E_Trac_NoInterp=E_Trac_NoInterp+(driver(i+1,1)-driver(i,1))*(driver(i+1,5)+driver(i,5))/2;
 end
 
 E_Trac_WithInterp=0;
 for i=1:1:length(t)-1
     E_Trac_WithInterp=E_Trac_WithInterp+(t(i+1,1)-t(i,1))*(p_interp(i,1)+p_interp(i+1,1))/2;
 end
 
 disp(E_Trac_NoInterp-E_Trac_WithInterp)
 
  neu_interp=ceil(interp1(driver(:,1),driver(:,6),t,'pchip'));
  figure(5)
  plot(driver(:,1),driver(:,6),'b')
  hold on 
  plot(t,neu_interp,'r');

  close all;
  driver_interp=[t,s_interp,speed,f_interp,p_interp,neu_interp];
  xlswrite(DOWN(1,sheet),driver_interp,table);
 end
 
%%
 for sheet=1:1:23
 driver=xlsread(NameDown(1,table),sheet);
 plot(driver(:,1),driver(:,3),'b')  
 hold on
 t=0:1:round(driver(end,1));
 t=t';
 speed=interp1(driver(:,1),driver(:,3),t,'pchip');
 plot(t,speed,'r');
 hold off
 
%  s=zeros(length(t),1);
%  s(1,1)=driver(1,2);
%  F=zeros(length(t),1);
%  F(length(t),1)=0;
%  for i=2:1:length(t)
%      a=(speed(1,i)-speed(1,i-1))/(t(1,i)-t(1,i-1));
%      if IsUp
%          s(i,1)=s(i-1,1)-(speed(1,i)^2-speed(1,i-1)^2)/(2*a);
%      else
%          s(i,1)=s(i-1,1)+(speed(1,i)^2-speed(1,i-1)^2)/(2*a);
%      end
%      
%      B=(GetBasicResistance(speed(1,i)*3.6)+GetBasicResistance(speed(1,i-1))*3.6)/2 *M*g;  %����λN
%      w0=(GetAddResistance(s(i-1,1),IsUp));  %��λKN
%      f=M*a+B/1000+w0;
%      F(i-1,1)=f;
%  end
%  driver2=[t' s speed' F];
%  
%  figure(1)
%  plot(driver(:,1),driver(:,4),'b');
%  hold on
%  plot(t,F','g')
 
 f_interp=interp1(driver(:,1),driver(:,4),t,'pchip');
 figure(2)
 plot(driver(:,1),driver(:,4),'b');
 hold on
 plot(t,f_interp,'r');
 
 s_interp=interp1(driver(:,1),driver(:,2),t,'pchip');
 figure(3)
 plot(driver(:,1),driver(:,2),'b')
 hold on 
 plot(t,s_interp,'r')
  
  p_interp=interp1(driver(:,1),driver(:,5),t,'pchip');
  figure(4)
  plot(driver(:,1),driver(:,5),'b')
  hold on 
  plot(t,p_interp,'r')
  
  E_Trac_NoInterp=0;
 for i=1:1:length(driver(:,1))-1
     E_Trac_NoInterp=E_Trac_NoInterp+(driver(i+1,1)-driver(i,1))*(driver(i+1,5)+driver(i,5))/2;
 end
 
 E_Trac_WithInterp=0;
 for i=1:1:length(t)-1
     E_Trac_WithInterp=E_Trac_WithInterp+(t(i+1,1)-t(i,1))*(p_interp(i,1)+p_interp(i+1,1))/2;
 end
 
 disp(E_Trac_NoInterp-E_Trac_WithInterp)
 
  neu_interp=ceil(interp1(driver(:,1),driver(:,6),t,'pchip'));
  figure(5)
  plot(driver(:,1),driver(:,6),'b')
  hold on 
  plot(t,neu_interp,'r');

  close all;
  driver_interp=[t,s_interp,speed,f_interp,p_interp,neu_interp];
  xlswrite(UP(1,sheet),driver_interp,table);
  end
end