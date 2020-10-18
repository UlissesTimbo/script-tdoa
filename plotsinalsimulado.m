% load sinalr1.mat;
% load sinalr2.mat;
% 
% 
% [p,n,e] = fileparts(mfilename('fullpath'));
% addpath([p '/functions']);
% 
% % Taxa de amostragem:
% sample_rate=2.048e6;
% 
% 
% % Lendo os sinais:
% % x1  = read_file_iq('labssh1.dat'); % IQ signal 1
% % x2  = read_file_iq('labssh2.dat'); % IQ signal 2
% % %x3 = read_file_iq('test3.dat'); % IQ signal 3
% x1 = ones(3600000,1)+1i*ones(3600000,1);
% x2 = x1;
% 
% % Plotando um sinal:
% tam=length(x1); % todos do mesmo tamanho
% t=(1:tam)/sample_rate;
% subplot(2,2,1)
% plot(t/1e-3,real(x1))
% axis([0 0.5e-3/1e-3 1.1*min(real(x1)) 1.2*max(real(x1))])
% xlabel('t (ms)')
% ylabel('Real(x_1(t))')
% subplot(2,2,3)
% plot(t/1e-3,imag(x1))
% axis([0 0.5e-3/1e-3 1.1*min(real(x1)) 1.2*max(real(x1))])
% xlabel('t (ms)')
% ylabel('Imag(x_1(t))')
% subplot(2,2,[2 4])
% [X1,w]=freqz(x1,1,1000000,'whole');
% X1normalizado=X1/max(abs(X1));
% plot((sample_rate/2)*(w-pi)/pi/1e6,fftshift(abs(X1normalizado)))
% xlabel('f (MHz)')
% ylabel('Espectro do sinal 1')
% axis([-sample_rate/2e6 sample_rate/2e6 0 1])
% grid
% 
% % % Alinhando os sinais x1 e x2 (não avaliei x3):
% % delay=round((time_stamp1-time_stamp2)*(10^(-9))*sample_rate); % time_stamp in ns
% % if(delay>0)
% %     %disp(['delay:' int2str(delay)]);
% %     %disp('Foi recortado um pedaço inicial de x2(k)')
% %     x1((tam-delay+1):tam)=[];
% %     x2(1:delay)=[];
% % else
% %     %disp(['delay:' int2str(delay)]);
% %     %disp('Foi recortado um pedaço inicial de x1(k)')
% %     x1(1:abs(delay))=[];
% %     x2((tam-abs(delay)+1):tam)=[];
% % end
% x1=x1-mean(x1);
% x2=x2-mean(x2);
% tam = length(x1); % igual a length(x2)
% 
% figure
% X1=fft(x1,2*tam-1); 
% x1ic=conj(x1(end:-1:1)); X1ic=fft(x1ic,2*tam-1);
% %r11=ifft(X1.*X1ic);
% tau=(-tam+1):(tam-1);
% %plot(tau,abs(r11))
% %xlabel('\tau (in samples)'); ylabel('r_{11}(\tau)')
% %title('Autocorrelation sequence')
% %return
% x2ic=conj(x2(end:-1:1)); X2ic=fft(x2ic,2*tam-1);
% r12=ifft(X1.*X2ic);
% plot(tau,abs(r12))
% hold on
% rcorr12=xcorr(x1,x2);
% plot(tau,abs(rcorr12),'--r')
% xlabel('\tau (in samples)'); ylabel('r_{12}(\tau)')
% title('Cross-correlation sequence (conventional)')
% figure
% r12PHAT=ifft((X1.*X2ic)./(abs(X1).*abs(X2ic)));
% plot(tau,abs(r12PHAT))
% xlabel('\tau (in samples)'); ylabel('r_{12}(\tau)')
% title('Generalized Cross-correlation (PHAT)')
format long;
kk=pi();