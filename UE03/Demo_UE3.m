% SA Problem Class
%
% Demo Example on the use of the PPM modulator
%
%
% Neumayer 2019
clear all, close all, clc

Msg = 'i like signal analysis'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PPM Parameters
PPM.TBase    = 0.001;   % Time Base in sec
PPM.TPulse   = 0.3;     % Pulse duration as fraction of time base
PPM.TJitter  = 0.2;     % Jitter as fraction of time base

PPM.f_S   = 200E3;      % Sampling Frequency in Hz

% Pulse Parameters
PPM.A     = 1;
PPM.f     = 10E3;
PPM.phi   = 0;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pattern function
u   = @(t,PPM) 0.5*(sign(t) - sign(t-PPM.TPulse*PPM.TBase));

sig = @(t,PPM) PPM.A*sin(2*pi*PPM.f*t+PPM.phi).*u(t,PPM);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Time generation
%
% vT are the time differences as multiples of the time base ==> in combination with the time base we get
% the real time difference

Nsymb   = size(Msg,2);
v_T = zeros(Nsymb,1);

for ii = 1:Nsymb
 s = Msg(ii);
 
 v_T(ii) = func_char2int(s);
 
 if  v_T(ii) == 0
     warning('String contains wrong symbol. Symbol was skipped')
 end 
 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Decoder
MSG = func_decoder( v_T )


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pulse start points

v_Tpulse = zeros(Nsymb+1,1);
for ii = 2:Nsymb+1
    TJitter =    PPM.TJitter * (2*rand - 1);
    
    v_Tpulse(ii) =   v_Tpulse(ii-1) + v_T(ii-1) + TJitter;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generation of signal

t = -5*PPM.TPulse*PPM.TBase: 1/PPM.f_S : v_Tpulse(end)*PPM.TBase + 5*PPM.TPulse*PPM.TBase;
SIG = zeros(size(t));


for ii = 1:Nsymb+1
   SIG = SIG +  sig(t-v_Tpulse(ii)*PPM.TBase,PPM) ; 
end

t = t- t(1);

SIGn = SIG + 0.5*randn(size(SIG));


figure, hold on, set(gca,'FontSize',26),set(gcf,'Color','White');
plot(t,SIGn,'b','LineWidth',2), grid on
plot(t,SIG,'r','LineWidth',2), grid on
xlabel('t (s)')
ylabel('x(t)')
title('PPM Example')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
id = 50;
f_S = 200E3;
[SIG,t] = func_PPMModulator('test test',f_S,id);

figure, hold on, set(gca,'FontSize',26),set(gcf,'Color','White');
plot(t,SIG,'b','LineWidth',2), grid on
xlabel('t (s)')
ylabel('x(t)')
title('func\_PPMModulator')

% Hidden Message
[SIG,t] = func_PPMModulator([],f_S,id);
figure, hold on, set(gca,'FontSize',26),set(gcf,'Color','White');
plot(t,SIG,'b','LineWidth',2), grid on
xlabel('t (s)')
ylabel('x(t)')
title('PPM Example (Christmas Special)')


