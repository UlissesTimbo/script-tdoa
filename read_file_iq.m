function [ iq_signal ] = read_file_iq( filename )
%read_file_tdoa reads a file with IQ data (e.g. from rtl_sdr)


    fileID = fopen(filename);
    a = fread(fileID);
    fclose(fileID);

    inphase1 = a(1:2:end) -128;
    quadrature1 = a(2:2:end) -128;

    % complex representation
    iq_signal = inphase1 + 1i.*quadrature1;

end

