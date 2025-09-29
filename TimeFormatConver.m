function Output = TimeFormatConver(num,BaseTimeHour,BaseTimeMin,BaseTimeSec)

hour = floor(num/3600);              % floor: 向下取整
    minute = floor(mod(num,3600)/60);  % mod： 求余数
    second = num - 3600*hour - 60*minute;
    
   hour=hour+BaseTimeHour;
    minute=minute+BaseTimeMin;
    second=second+BaseTimeSec;
    
    minAdd=0;
    while second>=60
        second=second-60;
        minAdd=minAdd+1;
    end
    minute=minute+minAdd;
    
    HourAdd=0;
    while minute>=60
        minute=minute-60;
        HourAdd=HourAdd+1;
    end
    hour=hour+HourAdd;
    
    if hour < 10
        hour = ['0',mat2str(hour)];      % mat2str：将double转化为字符串
    else
        hour = mat2str(hour);
    end
    
    if minute < 10
        minute = ['0',mat2str(minute)];
    else
        minute = mat2str(minute);
    end
    
    if second < 10
        second = ['0',mat2str(second)];
    else
        second = mat2str(second);
    end
   
    
    Output = [hour,':',minute,':',second];
    Output=mat2str(Output);
end
