close all
clear all
clc

mkdir Figures


%PPM Parameters
PPM.TBase    = 0.001;   % Time Base in sec
PPM.TPulse   = 0.3;     % Pulse duration as fraction of time base
PPM.TJitter  = 0.2;     % Jitter as fraction of time base

PPM.f_S   = 200E3;      % Sampling Frequency in Hz

% Pulse Parameters
PPM.A     = 1;
PPM.f     = 10E3;
PPM.phi   = 0;


id = 25;
f_S = 200E3; %Hz


% (A) ----------------------------------------------------------------------------
%Analyze output of PPM-modem
disp('---------(A)---------')

string = 'hi'; 
[x,t] = func_PPMModulator(string,f_S,id);


figure
    plot(t,x)
    grid on
    xlabel('t')
    ylabel('x(t)')
    title(['(A) PPM Modualtion for string = ', string])    
  
    saveas(gcf,['Figures/' own_strrep(gca)],'epsc')
    
figure
    plot(t,x)
    grid on
    xlabel('t')
    ylabel('x(t)')
    title('(A) Signal Pattern')
    xlim([4.8*PPM.TBase, 5.5*PPM.TBase])
  
    saveas(gcf,['Figures/' own_strrep(gca)],'epsc')

%Find Peaks and delete the value for those base durations, to get only the
%noise values
threshold = 0.8;
T_HoldOff = PPM.TBase*PPM.TPulse; %(I guess we should not know this number by now)
t_detect = threshold_detection(x,t,threshold,T_HoldOff);

%add the jitter time to get the correct block each time
t_detect = t_detect + PPM.TBase * PPM.TJitter; %dont know if we are supposed to know the jitter timings yet

index_block = floor(t_detect/PPM.TBase);
index_block = [index_block, index_block+1];
time_bases = PPM.TBase:PPM.TBase:t(end); 
times_block_delete = time_bases(index_block);

times_block_delete(:,1) = times_block_delete(:,1) - PPM.TBase * PPM.TJitter; %consider jitter time to be sure all of the actual signal values get deleted
times_block_delete(:,2) = times_block_delete(:,2) - PPM.TBase * PPM.TJitter;

bool_time = (t<times_block_delete(:,1) | t>times_block_delete(:,2));
bool_time = logical(floor(sum(bool_time,1)/3));

x_noise = x(bool_time);

figure
    plot(x_noise)
    xlabel('sample n')
    ylabel('x_{noise}')
    title('(A) Signal to calculate Noise')
    ylim([-1 1])
    grid on
    
    saveas(gcf,['Figures/' own_strrep(gca)],'epsc')

RMS = sqrt(mean(x_noise.^2)) %= sqrt(noise variance)

%or via ACF
% [rxx, mxx] = xcorr(x_noise,'biased');
% var_x = rxx(mxx == 0);
% RMS_2 = sqrt(var_x)


%We see from the plot that the pulse consists of 3.5 sin waves with the Period and Amplitude
%given from the values of the modulator

t_length_pulse = 3.5*1/PPM.f; %the pulse consists of 3 and a half period
t_pulse = 0:1/f_S:t_length_pulse;

%assuming we do know the signal shape as we create this Modulator
sig = @(t,PPM) PPM.A*sin(2*pi*PPM.f*t+PPM.phi); %from demo file; 
s = sig(t_pulse,PPM);

%matched filter: h[n] = s[-n] where s is the signalform to detect
h = s(end:-1:1)/norm(s)^2; %mirror and normalize it

figure
    plot(t_pulse,h)
    grid on
    xlabel('t')
    ylabel('h(t')
    title('(A) Impulse response of matched filter h')
    
    saveas(gcf,['Figures/' own_strrep(gca)],'epsc')

    
%(B) ----------------------------------------------------------------------------
disp('---------(B)---------')

%add noise to showcase the matched filter h
x_added_noise = x + randn(size(x))*(1/2 - RMS);     %HIER WSL NOCH FEHLER; VARIANZ EINFACH ADDIERT WERDEN?????

%now filter it through the matched filter h
x_filter = conv(x_added_noise,h); %signal values dont get increased due to normalization of h


figure
subplot(3,1,1)
    plot(t,x)
    title('(B) Matched filtering for noisy signal')
    grid minor
    legend('given signal')
    ylabel('x(t)') 
    ylimits = ylim;
    
    f = gca;
    
subplot(3,1,2)
    plot(t,x_added_noise)
    grid minor
    legend('signal corrupted with noise')
    ylabel('x_{noise}(t)')
    ylim(ylimits)
    
subplot(3,1,3)
    t_filter = 0:1/f_S:(length(x_filter)- 1)/f_S;
    plot(t_filter,x_filter)
    grid minor
    ylabel('x_{filter}(t)')
    xlabel('t')    
    legend('signal after filter')
    ylim(ylimits)
    
   
    saveas(gcf,['Figures/' own_strrep(f)],'epsc')
    
    
% (C) ----------------------------------------------------------------------------
%create histogramm of jitter
disp('---------(C)---------')

string = repmat('a',[1,2]); %creates a string with 200 a

[x,t] = func_PPMModulator(string,f_S,id);

n_blocks = length(string);


figure
    plot(t,x)
    grid on
    ylabel('x(t)')
    xlabel('t')
    title('(C) Signal to describe Jitter')    
    ylimits = ylim;
    ylim(ylimits) %to keep limits the same after drawing the lines
    
    for ii = 5:5+n_blocks
        line([PPM.TBase, PPM.TBase]*ii ,ylimits ,'Color' ,'r' , 'LineWidth', 2)        
    end
    xlim([4.8*PPM.TBase, (n_blocks+5.2)*PPM.TBase])
    
    saveas(gcf,['Figures/' own_strrep(gca)],'epsc')
    
    

string = repmat('a',[1,200]); %creates a string with 200 a

[x,t] = func_PPMModulator(string,f_S,id);

T_HoldOff = PPM.TBase*(PPM.TPulse + 0.1) ; %if the signal was above the threshold, wait for the pulse length plus some leeway
threshold = 0.5; %seen from plot

t_detect = threshold_detection(x,t,threshold,T_HoldOff);

t_expected_time = PPM.TBase; %expected time difference between two symbols, only holds true for the symbol "a"

t_diff = diff(t_detect);
t_jitter = t_diff - t_expected_time;


figure
    plot(t,x)
    grid on
    ylabel('x(t)')
    title('(C) signal to derive Jitter')        
    
    xlim(xlim) %this codeline makes sure, the limits dont change due to the line drawn next
    line(xlim,[threshold, threshold],'Color' ,'r' ,'LineWidth',2)    
    
    legend('x(t)', 'threshold')
        
    saveas(gcf,['Figures/' own_strrep(gca)],'epsc')
    

%calcualte maximum jitter; can change from max jitter to min jitter within
%one symbol
t_jitter_max = (max(t_jitter) - min(t_jitter))*1.1; %since it is differential, it can jitter form max to min t_jitter
t_jitter_ref = PPM.TBase * PPM.TJitter;  %I suppose we dont know this

figure
    histogram(t_jitter) 
    title('(C) Histogramm Jitter')
    
    saveas(gcf,['Figures/' own_strrep(gca)],'epsc')
    
    
    
    
% (D) ----------------------------------------------------------------------------
%Generate new signal
disp('---------(D)---------')

string = 'testing my super smart threshold detection method';
[x,t] = func_PPMModulator(string,f_S,id);


%add noise to showcase the matched filter h
sigma = 0.5;
x_added_noise = x + randn(size(x))*sigma;

%now filter it through the matched filter h
x_filter = conv(x_added_noise,h); %signal values get increased bc. of covolution

T_HoldOff = PPM.TBase*(PPM.TPulse + 0.1) ; %if the signal was above the threshold, wait for the pulse length plus some leeway
threshold = 0.5; %from plot

t_filter = 0:1/f_S:(length(x_filter)-1)/f_S;
t_detect = threshold_detection(x_filter,t_filter,threshold,T_HoldOff);
t_diff = diff(t_detect);
    
    
vT = floor((t_diff+ t_jitter_max)/PPM.TBase); %add jitter time to be inside the right block all the time, divide by base time and floor it to get indizes

[ MSG ] = func_decoder( vT )

% (E) ----------------------------------------------------------------------------
%Christmas Special
disp('---------(E)---------')
string = [];
[x_C,t_C] = func_PPMModulator(string,f_S,id);    
    
    
%now filter it through the matched filter h
x_filter = conv(x_C,h); %signal values get increased bc. of covolution
t_filter = 0:1/f_S:(length(x_filter)- 1)/f_S;


T_HoldOff = PPM.TBase*(PPM.TPulse + 0.1) ; %if the signal was above the threshold, wait for the pulse length plus some leeway
threshold = 0.5; %from plot

t_detect = threshold_detection(x_filter,t_filter,threshold,T_HoldOff);

%calcualte time difference with jitter safety and relate it to base time
vT = floor((diff(t_detect) + t_jitter_max)/PPM.TBase); %add jitter time to be inside the right block all the time, divide by base time and floor it to get indizes
[ MSG ] = func_decoder( vT )

%MSG = 'i am serious and dont call me shirley'
%from the movie: Airplane! (GER: Die unglaubliche Reise in einem verrückten
%Flugzeug)
%Character: Dr. Rumack played from the actor Leslie Nielsen

figure
subplot(2,1,1)
    plot(t_C,x_C)
    grid on
    ylabel('x(t)')
    title('(E) PPM Modualtion for Christmas Special signal')
    legend('x(t)')    
        
    f = gca;
     
subplot(2,1,2)
    plot(t_filter, x_filter)
    grid on
    xlabel('t')
    ylabel('x(t)')
    grid on
    xlabel('t')
    ylabel('filtered x(t)')
    
    xlim(xlim) %this line makes sure, the limits dont change due to the line drawn next
    line(xlim,[threshold, threshold],'Color' ,'r' ,'LineWidth',2)
    
    legend('x_{filtered}', 'threshold')
   
    saveas(gcf,['Figures/' own_strrep(f)],'epsc')
  


% %create a placeholder function to overwrite the saveas function
function saveas(~, ~, ~)
    disp('Figure not saved')
end









% to (A)
%IDEA BEHIND THIS: We know the signal patter, hence we can calculate the
%signal power and add them up for every pulse. The Value of the ACF rxx[0]
%is the signal power of the entire signal. By subtracting the signal power
%of the know pulse, only the noise power is left. 
%DOES NOT WORK, due to the finite amount of pulses. Did cause often a
%negative Noise Power
% [rxx,m] = xcorr(x); 
% 
% figure
%     plot(m,rxx)
% % Signal energy of pulses is ||h|| = 35 for each pulse
% total_signal_energy = (length(string)+1) * 35;
% noise_power = rxx(m==0) - total_signal_energy;  %not useful for limited amount of signals 

