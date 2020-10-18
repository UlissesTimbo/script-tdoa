function [ doa_meters, doa_samples, reliability ] = tdoa2(signal1_complex, signal2_complex, corr_type, interpol, sample_rate)
    % tdoa2 calculates the TDOA of two signals captured by two RXs
    %	output:
    %   doa_meters: 		delay in meters (how much signal1 is later than signal 2)
    %	doa_samples: 		delay in samples
    %   reliability: 		reliab. of the correlation, 0(bad)..1(good)
    %   
    %   input:
    %	signal1: 			signal with from RX 1
    %	signal2: 			signal with from RX 2
    %	corr_type: 			switch between abs and delta phase (abs: 0, delta phase: 1);
    %   interpol            interpolation factor
    
    %% Correlation for slice 1 (ref)
%     disp('CORRELATION CALCULATION DETAILS:');
    format long;
    corr_signal_1 = correlate_iq(signal1_complex, signal2_complex, corr_type, 0);
    corr1_reliability = corr_reliability( corr_signal_1 );

    [~, idx1] = max(corr_signal_1);
    delay1_native = idx1 - length(signal1_complex); % >0: signal1 later, <0 signal2 later

    % with interpolation
    if (interpol > 1)
        signal11_interp = interp(signal1_complex, interpol);
        signal12_interp = interp(signal2_complex, interpol);
    
        corr_signal_1_interp = correlate_iq(signal11_interp, signal12_interp, corr_type, 0);
        [~, idx1_interp_i] = max(corr_signal_1_interp);
        idx1_interp = (idx1_interp_i-1) ./ interpol + (1/interpol);
        delay1_interp = idx1_interp - length(signal1_complex); % >0: signal1 later, <0 signal2 later
    else
        delay1_interp = 0;
    end
      

    %% Calculate Correlation Results
    
    if (interpol <= 1)
        delay1 = delay1_native;
    else
        delay1 = delay1_interp;
    end 
    
    % doa_samples/_meters specifies how much signal1 is later than signal2
    doa_samples = delay1;
    doa_meters = (doa_samples / sample_rate) * 3e8;
    

    reliability = corr1_reliability;
    
%     disp(' ');
%     disp('CORRELATION RESULTS');
% 
%     disp(['raw delay1 (ref) (nativ/interp): ' int2str(delay1_native) ' / ' num2str(delay1_interp) ', reliability nativ (0..1): ' num2str(corr1_reliability)]);
% 
%     disp(' ');
%     disp(['specified distance between two RXes [m]: ' num2str(rx_distance)]);
%     disp(' ');
% 
%     disp('FINAL RESULT');
%     disp(['TDOA in samples: ' num2str(doa_samples) '(how much is signal1 later than signal2)']);
%     disp(['TDOA in distance [m]: ' num2str(doa_meters) ]);
%     disp(['Total Reliability (min of all 3): ' num2str(reliability) ]);
%     disp(' ');
end