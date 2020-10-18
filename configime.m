clear all;clc;
%% Config File for TDOA setup
% RX and Ref TX Position
% rx1_lat = -22.955993; % RX ime
% rx1_long = -43.166183;
rx1_lat = -22.95592; % RX ime
rx1_long = -43.16629;

% rx2_lat = -22.953809; % RX epv
% rx2_long = -43.166743;
-22.9508, -43.1517
% rx2_lat = -22.95361; % RX epv
% rx2_long = -43.16629;
rx2_lat = -22.9508; % RX epv
rx2_long = -43.1517;


% rx3_lat = -22.951241; % RX pão de açúcar
% rx3_long = -43.164599;

rx3_lat = -22.9442; % RX pão de açúcar
rx3_long = -43.1611;

tx_ref_lat = -22.954844; % Referência
tx_ref_long = -43.165512;
% IQ Data Files
file_identifier = 'test.dat';
folder_identifier = 'recorded_data_test/';
% signal processing parameters
corr_type = 'abs';  %'abs' or 'dphase'
interpol_factor = 10;
map_mode = 'open_street_map';
% heatmap (only with google maps)
heatmap_resolution = 400; % resolution for heatmap points
heatmap_threshold = 0.1;  % heatmap point with lower mag are suppressed for html output

