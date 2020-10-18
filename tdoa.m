clear;clc;close all;
format long;
[p,n,e] = fileparts(mfilename('fullpath'));
addpath([p '/functions']);

sample_rate=2.048e6;

x1  = read_file_iq('teste15103g30.dat'); % IQ signal 1
x2  = read_file_iq('teste15101g30.dat'); % IQ signal 2
%x3 = read_file_iq('test3.dat'); % IQ signal 3

tam1=length(x1);

time_stamp3=343478482;
time_stamp1=173927565;

delay31=(time_stamp3-time_stamp1)*10^-9*sample_rate;

x1(1:delay31)=[];
x2((tam1-delay31+1):tam1)=[];

abs1 = remove_mean((x1)); %remove a média do absoluto
abs2 = remove_mean((x2));
tam=length(x1);
particao=floor(tam/10);

for i=1:10
    for j=1:particao
        Sinal1(j,i)=abs1(j+particao*(i-1));
    end
end
for i=1:10
    for j=1:particao
        Sinal2(j,i)=abs2(j+particao*(i-1));
    end
end
 % todos do mesmo tamanho
% [X1,w]=freqz(x1,1,1000000,'whole');
% X1normalizado=X1/max(abs(X1));
% plot((sample_rate/2)*(w-pi)/pi/1e6,fftshift(abs(X1normalizado)))
% xlabel('f (MHz)')
% ylabel('Espectro do sinal 1')
% axis([-sample_rate/2e6 sample_rate/2e6 0 1])
% grid


% abs1 = remove_mean((x1)); %remove a média do absoluto
% abs2 = remove_mean((x2));
% 
% X1=fft(abs1,2*tam-1);
% x2ic=conj(abs2(end:-1:1)); X2ic=fft(x2ic,2*tam-1);
% abs_corr=ifft(X1.*X2ic);
for i=1:10
abs_corr = xcorr(Sinal1(:,i), Sinal2(:,i));
           
abs_corr1 = abs_corr ./ max(abs_corr);

[~, idx1] = max(abs_corr1);
delay1_native(i) = idx1 - particao; % >0: signal1 later, <0 signal2 later
end
