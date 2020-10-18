clc; clear all;
%% Read Signals from File
disp('______________________________________________________________________________________________');
disp('READ DATA FROM FILES');
signal1 = read_file_iq('test1.dat');
signal2 = read_file_iq('test2.dat');
signal3 = read_file_iq('test3.dat');

%% Read timestamps in ns from receivers
time_stamp1=773629962;
time_stamp2=818946538;
time_stamp3=936366765;

%% alinhamento dos sinais
sample_rate = 2048000;  % in Hz
tam1=length(signal1);

delay21=(time_stamp2-time_stamp1)*10^-9*sample_rate;
delay31=(time_stamp3-time_stamp1)*10^-9*sample_rate;
delay32=(time_stamp3-time_stamp2)*10^-9*sample_rate;

    signal1(1:delay31)=[];
    signal2(1:delay32)=[];
    tam2=length(signal2);
    signal3((tam1-delay31+1):tam1)=[];
    signal2((tam2-delay21+1):tam2)=[];

tam=length(signal1);
    
%% partição
particao=floor(tam/10);

for i=1:10
    for j=1:particao
        Sinal1(j,i)=signal1(j+particao*(i-1));
    end
end
for i=1:10
    for j=1:particao
        Sinal2(j,i)=signal2(j+particao*(i-1));
    end
end
for i=1:10
    for j=1:particao
        Sinal3(j,i)=signal3(j+particao*(i-1));
    end
end


%     for j=1:particao
%         Sinal1(j,2)=signal1(j+particao);
%     end
%     A=[1 2 3 4 5 6 7 8 9 5 0 2 1 4 5 3 6 7 5 9 7];
%     A=A';
% for i=1:3
%     for j=1:7
%         B(j,i)=A(j+7*(i-1));
%     end
% end
%     tam2=length(signal2);
%     
% 
% 
%     delay2=delay2+1;
%     signal3(1:delay2)=[];
%     signal1((tam-delay2+1):tam)=[];
%     signal2((tam-delay2+1):tam2)=[];
    
%         %alinhamento dos sinais
%     delay=(time_stamp1-time_stamp2)*10^-10*sample_rate;
%     if(delay>0)
%         delay=delay+1;
%         signal2_complex(1:delay)=[];
%         signal1_complex((2500000-delay+1):2500000)=[];
%     else
%         delay=-delay+1;
%          disp(['delay:' int2str(delay)]);
%         signal1_complex(1:delay)=[];
%         signal2_complex((2500000-delay+1):2500000)=[];
%     end


