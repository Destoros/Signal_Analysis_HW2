% SA Problem Class
%
% Demo Example on the use of the DFT based measurement system
%
%
% Neumayer 2019
clear all, close all, clc





fs=1e6;   % Sampling Frequency
L=1000;   % Nr Samples
id=50;     % id


% Definition of a cont. time signal, which is sampled by the system

func_signal.sig= @(t,PAR) PAR.A*sin(2*pi*PAR.f*t); % Funktions-Objekt
func_signal.PAR.A = 8;      % Amplitude
func_signal.PAR.f = 1e4;    % Frequency 


% Command to get the signal, this is used in the function osci_input
t = [0 1];
x = func_signal.sig(t,func_signal.PAR); 


x = osci_input(func_signal,L,fs,id);
plot(x)


% Signals for the homework examples
%
% run the function osci_input with this command, to get your 
%

% Task C
xA1=osci_input('sigA1',L,fs,id);
xA2=osci_input('sigA2',L,fs,id);

% Task C
xB1=osci_input('sigB1',L,fs,id);
xB2=osci_input('sigB2',L,fs,id);


% Task D
xC1=osci_input('sigC1',L,fs,id);
xC2=osci_input('sigC2',L,fs,id);
xC3=osci_input('sigC3',L,fs,id);




