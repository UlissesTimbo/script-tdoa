clear; close all; clc; 
x = -1.544; y = 0; z = 0.90; 
Ps = [x;y;z;]; 
x1 = -1.30; y1 = 0; z1 = 0.700;%closest point P(1,:)=[x1 y1 z1]; 
P(7,:)=[-x1 -y1 z1-0.81*6/7]; 
deltadfmax=(norm(Ps-P(7,:)')-norm(Ps-P(1,:)'))/6; for i=1:6 
 P(i+1,1)=((norm(Ps-P(1,:)')+deltadfmax*i)^2-(-0.2- (0.81*i/7))^2-x1^2-x^2)/(2*-1*x); 
 P(i+1,2)=sqrt(1.3^2-P(i+1,1)^2); 
 P(i+1,3)=P(1,3)-0.81*i/7; 
end 
P=P'; 
M = size(P,2); %number of sensors 
plot3([P(1,:)],[P(2,:)],[P(3,:)],'ob','linewidth',4) hold on 
for i=1:7 
 text(P(1,i)-0.5, P(2,i)-0.2, P(3,i)-0.5,  'SENSOR'); 
end
hold on 
plot3(x,y,z,'pr','linewidth',4) 
text(x-0.5,y+0.5,z+0.5,'SOURCE');  
xlabel('Axis x') 
ylabel('Axis y') 
zlabel('Axis z') 
axis equal; axis([-2 2 -2 2 0 2]); grid on; %----------------------------------------------------- --------- 
% Generating the signals: 
%----------------------------------------------------- --------- 
% Parameters 
f = 2e9; %2GHz 
fs =160e9; %160MHz Sampling frequency ts = 1/fs; % sec 
v=3e8; % light speed 
signal = rand(1, 3200); 
noise = randn(1, length(signal))/1000; 
noisy_signal = signal + noise; 
%Measurements 
df=sqrt(sum((P-kron(ones(1,M),Ps)).^2 ,1)); tf=df/v; 
deltan=round(tf/ts); 
for n=1:M  
 r(:,n) = circshift(noisy_signal, [1 deltan(n)]); end 
%----------------------------------------------------- --------- 
% Estimating TDoAs and Deltad: 
%----------------------------------------------------- --------- 
NFFT=length(r(:,1)'); 
for n=1:M  
 R(:,n)=fft(r(:,n)); 
end 
for n=1:M  
 for m=1:M 
 if m>=n 
 rx=ifft((R(:,m)./(R(:,n)))); 
 [val,pos]=max(abs(rx)); 
 if pos-1 < NFFT/2 
 TDoA(m,n)=pos-1; % in number of  samples 
 else 
 TDoA(m,n)=-NFFT+pos-1; 
 end
 end 
 end 
end 
Deltad=TDoA*v/fs; 
%----------------------------------------------------- ----------------- 
% Estimating the transmitter position using  conventional LS (M=5) 
%----------------------------------------------------- ----------------- 
for n=2:M 
 A1(n-1,:)=[(P(:,n)-P(:,1))' Deltad(n,1)]; end 
for n=2:M 
 b1(n-1,:)=[(P(:,n))'*P(:,n)-(P(:,1))'*P(:,1)- Deltad(n,1)^2]/2; 
end 
poConvLS=(A1'*A1)\(A1'*b1); 
poConvLS=poConvLS(1:3); 
plot3(poConvLS(1),poConvLS(2),poConvLS(3),'xg','linewi dth',4) 
%----------------------------------------------------- ----------------- 
% Estimating the transmitter position using EXTENDED  LS 
%----------------------------------------------------- ----------------- 
N=M*(M-1)/2; 
% Seting up the matrix A e the vector b: 
A=[(P(:,2)-P(:,1))' Deltad(2,1) 0 0  0 0 0  
 (P(:,3)-P(:,1))' Deltad(3,1) 0 0  0 0 0  
 (P(:,4)-P(:,1))' Deltad(4,1) 0 0  0 0 0  
 (P(:,5)-P(:,1))' Deltad(5,1) 0 0  0 0 0  
 (P(:,6)-P(:,1))' Deltad(6,1) 0 0  0 0 0  
 (P(:,7)-P(:,1))' Deltad(7,1) 0 0  0 0 0  
 (P(:,3)-P(:,2))' 0 Deltad(3,2) 0  0 0 0  
 (P(:,4)-P(:,2))' 0 Deltad(4,2) 0  0 0 0  
 (P(:,5)-P(:,2))' 0 Deltad(5,2) 0  0 0 0 
 (P(:,6)-P(:,2))' 0 Deltad(6,2) 0  0 0 0  
 (P(:,7)-P(:,2))' 0 Deltad(7,2) 0  0 0 0  
 (P(:,4)-P(:,3))' 0 0  
Deltad(4,3) 0 0 0  
 (P(:,5)-P(:,3))' 0 0  
Deltad(5,3) 0 0 0  
 (P(:,6)-P(:,3))' 0 0  
Deltad(6,3) 0 0 0  
 (P(:,7)-P(:,3))' 0 0  
Deltad(7,3) 0 0 0  
 (P(:,5)-P(:,4))' 0 0 0  Deltad(5,4) 0 0  
 (P(:,6)-P(:,4))' 0 0 0  Deltad(6,4) 0 0  
 (P(:,7)-P(:,4))' 0 0 0  Deltad(7,4) 0 0  
 (P(:,6)-P(:,5))' 0 0 0  0 Deltad(6,5) 0  
 (P(:,7)-P(:,5))' 0 0 0  0 Deltad(7,5) 0  
 (P(:,7)-P(:,6))' 0 0 0  0 0 Deltad(7,6)]; 
k=0; 
for n=1:M 
 for m=1:M 
 if m>n 
 k=k+1; 
 b(k,:)=[(P(:,m))'*P(:,m)-(P(:,n))'*P(:,n)- Deltad(m,n)^2]/2; 
 end 
 end 
end 
poExtLS=(A'*A)\(A'*b); 
poExtLS=poExtLS(1:3); 
plot3(poExtLS(1),poExtLS(2),poExtLS(3),'xk','linewidth ',4) 
% ---------------------------------------------------- ------------------ 
% Estimating the transmitter position using Data  Selection LS (n=6) 
% ---------------------------------------------------- ------------------ 
% using the estimate of the source location (extended  LS), we can calculate Deltadhat : 
for n=1:M
 dhat(n,1)=norm(poExtLS-P(:,n)); 
end 
for n=1:M  
 for m=1:M 
 if m>=n 
 Deltadhat(m,n)=(dhat(m)-dhat(n));  end 
 end 
end 
sit1=0; % no null column of An 
sit2=0; % null column 6 
sit3=0; % null column 7 
sit4=0; % columns 7 and 9 null 
sit5=0; % null column 8 
sit6=0; % columns 8 and 9 null 
sit7=0; % null column 9 
% checking the deltas! 
k=0; 
for n=1:M  
 for m=1:M 
 if m>n 
 k=k+1; 
 subcheck(1,k)=(norm(Deltad(m,n)) >  norm(P(:,m)-P(:,n))); 
 end 
 end 
end 
% Checking all the n-combinations of N elements: n=8; 
po=poExtLS; 
ximin=(Deltad-Deltadhat)^2; 
ximin=(sum(ximin))/N; 
ximin=(sum(ximin)); 
xi_k=ximin*ones((factorial(N)/(factorial(n)*factorial( N-n))+1),1); 
k=1; xi_k(k)=ximin; 
for BC = 0:(2^N-1) 
 aux=zeros(1,N); 
 aux(1:length(de2bi(BC)))=de2bi(BC); 
 if sum(aux)==n && (sum(aux & subcheck)==0)  [bogus,pos1]=sort(aux,'descend');  An=A(pos1(1:n),:); 
  
[bogus,pos2]=sort(sum(abs(An(:,:))),'descend');  if sum(bogus==0)==0 
 sit1=1; % no null column of An (don't  remove any column)
 else % bogus(9) has to be zero!  
 if bogus(7)==0 
 An(:,pos2(7:9))=[];  
 elseif bogus(8)==0 % two null columns  (remove two columns) 
 An(:,pos2(8:9))=[];  
if (pos2(8)==7) || (pos2(9)==7) 
 sit4=1; % columns 7 and 9 null  elseif (pos2(8)==8) || (pos2(9)==8)  sit6=1; % columns 8 and 9 null  end 
 else % a single null column (remove one  column!) 
 An(:,pos2(9))=[]; 
 switch pos2(9)  
 case 6 
 sit2=1; 
 case 7 
 sit3=1; 
 case 8 
 sit5=1; 
 case 9  
 sit7=1; 
 end 
 end 
 end  
 bn=b(pos1(1:n),:); 
 xn=inv(An'*An)*(An'*bn); 
 Pshat=xn(1:3);  
 for i=1:M 
 dhat(i,1)=norm(P(:,i)-Pshat);  end 
 for j=1:M  
 for i=1:M 
 if i>=j 
 Deltadhat(i,j)=(dhat(i)-dhat(j));  end 
 end 
 end 
 xin=0;l=0; 
 for j=1:M  
 for i=1:M 
 if i>j 
 l=l+1; 
xin(l,1)=(Deltad(i,j)- 
Deltadhat(i,j))^2; 
 end
 end 
 end 
 xin=aux*xin/n; 
 k=k+1; 
 xi_k(k)=xin; 
 if (xin <= ximin) % if norm(xn(1:2)-ps)<ximin  ximin = xin; % ximin = norm(xn(1:2)-ps);  po=xn(1:3); 
 end 
 sit1=0; sit2=0; sit3=0; sit4=0; sit5=0;  sit6=0; sit7=0;  
 end 
end 
plot3(po(1),po(2),po(3),'xm','linewidth',4) errorConvLS=norm(Ps-poConvLS) 
errorExtLS=norm(Ps-poExtLS) 
errorDSLS=norm(Ps-po)
