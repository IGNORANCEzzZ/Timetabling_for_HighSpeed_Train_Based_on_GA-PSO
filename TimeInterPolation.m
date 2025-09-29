% 对空间域解算的单车优化数据反算得到的速度-功率-力-位置-时间数据进行插值，得到每1秒上的数据，并且舍弃多余的数据
M=440;
g=9.81;
UP=["11-10","11-9","11-8","11-7","11-4","11-2","10-9","10-7","10-4","9-8","9-5","9-2","8-7","8-5","8-4","7-5","7-4","7-2","5-4","5-2","4-2","4-1","2-1"];
DOWN=["1-2","1-4","2-4","2-5","2-7","2-9","2-11","4-5","4-7","4-8","4-10","4-11","5-7","5-8","5-9","7-8","7-10","7-11","8-9","8-11","9-10","9-11","10-11"];



NameUp=["优化数据up+10s","优化数据up+20s","优化数据up+30s","优化数据up+40s","优化数据up+1%","优化数据up+2%","优化数据up+3%","优化数据up+4%","优化数据up+5%","优化数据up+6%","优化数据up+7%","优化数据up+8%","优化数据up+9%","优化数据up+10%","优化数据up+11%","优化数据up+12%","优化数据up+13%","优化数据up+14%","优化数据up+15%","优化数据up+16%","优化数据up+17%","优化数据up+18%","优化数据up+19%","优化数据up+20%"];
NameDown=["优化数据down+10s","优化数据down+20s","优化数据down+30s","优化数据down+40s","优化数据down+1%","优化数据down+2%","优化数据down+3%","优化数据down+4%","优化数据down+5%","优化数据down+6%","优化数据down+7%","优化数据down+8%","优化数据down+9%","优化数据down+10%","优化数据down+11%","优化数据down+12%","优化数据down+13%","优化数据down+14%","优化数据down+15%","优化数据down+16%","优化数据down+17%","优化数据down+18%","优化数据down+19%","优化数据down+20%"];
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
%      B=(GetBasicResistance(speed(1,i)*3.6)+GetBasicResistance(speed(1,i-1))*3.6)/2 *M*g;  %：单位N
%      w0=(GetAddResistance(s(i-1,1),IsUp));  %单位KN
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
%      B=(GetBasicResistance(speed(1,i)*3.6)+GetBasicResistance(speed(1,i-1))*3.6)/2 *M*g;  %：单位N
%      w0=(GetAddResistance(s(i-1,1),IsUp));  %单位KN
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