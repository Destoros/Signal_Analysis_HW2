function t_detect = threshold_detection(x,t,threshold,T_HoldOff)
%threshold hold detection to avoid several time values for one symbol

flag = 1;
t_detect = 0; %init to avoid erros, 0 gets delteted later

for ii = 1:length(x)
    
    if x(ii) > threshold && flag == 1
        flag = 0;
        t_detect = [t_detect; t(ii)];
               
    end
    
    %avoid multiple detection
    if (t(ii) - t_detect(end)) >= T_HoldOff
        flag = 1;
    end    
    
end

t_detect(1) = [];

end