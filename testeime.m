% =========================================================================
%  Experimental Evaluation Script for RTL-SDR based TDOA
% =========================================================================

clear;clc;close all;
format long;
% adds subfolder with functions to PATH
[p,n,e] = fileparts(mfilename('fullpath'));
addpath([p '/functions']);
% addpath([p '/recorded_data_test']);


%% Read Parameters from config file, that specifies all parameters
%---------------------------------------------

configime;

% calculate geodetic reference point as mean center of all RX positions
geo_ref_lat  = mean([rx1_lat, rx2_lat, rx3_lat]);
geo_ref_long = mean([rx1_long, rx2_long, rx3_long]);
disp(['geodetic reference point (mean of RX positions): lat=' num2str(geo_ref_lat, 8) ', long=' num2str(geo_ref_long, 8) ])

% known signal path differences between two RXes to Ref (sign of result is important!)
rx_distance_diff12 = dist_latlong(tx_ref_lat, tx_ref_long, rx1_lat, rx1_long, geo_ref_lat, geo_ref_long) - dist_latlong(tx_ref_lat, tx_ref_long, rx2_lat, rx2_long, geo_ref_lat, geo_ref_long); % (Ref to RX1 - Ref to RX2) in meters
rx_distance_diff13 = dist_latlong(tx_ref_lat, tx_ref_long, rx1_lat, rx1_long, geo_ref_lat, geo_ref_long) - dist_latlong(tx_ref_lat, tx_ref_long, rx3_lat, rx3_long, geo_ref_lat, geo_ref_long); % (Ref to RX1 - Ref to RX3) in meters
rx_distance_diff23 = dist_latlong(tx_ref_lat, tx_ref_long, rx2_lat, rx2_long, geo_ref_lat, geo_ref_long) - dist_latlong(tx_ref_lat, tx_ref_long, rx3_lat, rx3_long, geo_ref_lat, geo_ref_long); % (Ref to RX2 - Ref to RX3) in meters

% distance between two RXes in meters
rx_distance12 = dist_latlong(rx1_lat, rx1_long, rx2_lat, rx2_long, geo_ref_lat, geo_ref_long);
rx_distance13 = dist_latlong(rx1_lat, rx1_long, rx3_lat, rx3_long, geo_ref_lat, geo_ref_long);
rx_distance23 = dist_latlong(rx2_lat, rx2_long, rx3_lat, rx3_long, geo_ref_lat, geo_ref_long);

%% Read Signals from File
signal1 = read_file_iq('labssh1.dat');
signal2 = read_file_iq('labssh2.dat');
signal3 = read_file_iq('labssh3.dat');

%% Read timestamps in ns from receivers
time_stamp1=430616899;
time_stamp2=359779977;
time_stamp3=336762141;

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

%% Calculate TDOA
for i=1:10
[doa_meters12(i), doa_samples12(i), reliability12(i) ] = tdoa2(Sinal1(:,i), Sinal2(:,i), corr_type, interpol_factor, sample_rate);

[doa_meters13(i), doa_samples13(i), reliability13(i) ] = tdoa2(Sinal1(:,i), Sinal3(:,i), corr_type, interpol_factor, sample_rate);

[doa_meters23(i), doa_samples23(i), reliability23(i) ] = tdoa2(Sinal2(:,i), Sinal3(:,i), corr_type, interpol_factor, sample_rate);
end

% %% Generate html map
% disp(' ');
% disp('______________________________________________________________________________________________');
% disp('GENERATE HYPERBOLAS');
% 
% [points_lat1, points_long1] = gen_hyperbola(doa_meters12, rx1_lat, rx1_long, rx2_lat, rx2_long, geo_ref_lat, geo_ref_long);
% [points_lat2, points_long2] = gen_hyperbola(doa_meters13, rx1_lat, rx1_long, rx3_lat, rx3_long, geo_ref_lat, geo_ref_long);
% [points_lat3, points_long3] = gen_hyperbola(doa_meters23, rx2_lat, rx2_long, rx3_lat, rx3_long, geo_ref_lat, geo_ref_long);
% 
% disp(' ');
% disp('______________________________________________________________________________________________');
% disp('GENERATE HTML');
% rx_lat_positions  = [rx1_lat   rx2_lat   rx3_lat ];
% rx_long_positions = [rx1_long  rx2_long  rx3_long];
% 
% hyperbola_lat_cell  = {points_lat1,  points_lat2, points_lat3};
% hyperbola_long_cell = {points_long1, points_long2, points_long3};
% 
% [heatmap_long, heatmap_lat, heatmap_mag] = create_heatmap(doa_meters12, doa_meters13, doa_meters23, rx1_lat, rx1_long, rx2_lat, rx2_long, rx3_lat, rx3_long, heatmap_resolution, geo_ref_lat, geo_ref_long); % generate heatmap
% heatmap_cell = {heatmap_long, heatmap_lat, heatmap_mag};
% 
% if strcmp(map_mode, 'google_maps')
%     % for google maps
%     create_html_file_gm( ['imeg/map_' file_identifier '_' corr_type '_interp' num2str(interpol_factor) '_bw' int2str(signal_bandwidth_khz) '_smooth' int2str(smoothing_factor) '_gm.html'], rx_lat_positions, rx_long_positions, hyperbola_lat_cell, hyperbola_long_cell, heatmap_cell, heatmap_threshold);
% else
%     % for open street map
%     create_html_file_osm( ['imeg/map_' file_identifier '_' corr_type '_interp' num2str(interpol_factor) '_bw' int2str(signal_bandwidth_khz) '_smooth' int2str(smoothing_factor) '_osm.html'], rx_lat_positions, rx_long_positions, hyperbola_lat_cell, hyperbola_long_cell, heatmap_cell, heatmap_threshold);
% end
% disp('______________________________________________________________________________________________');
