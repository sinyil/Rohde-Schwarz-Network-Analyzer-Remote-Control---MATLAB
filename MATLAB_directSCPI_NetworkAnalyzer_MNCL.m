function [stimulusValues, rawData, magdB, phaseAng] = MATLAB_directSCPI_NetworkAnalyzer_MNCL()

    % General example of an *IDN? query
    % Make sure you have installed NI VISA 15.0 or newer with .NET support
    % This example does not require MATLAB Instrument Control Toolbox
    % It is based on using .NET assembly called Ivi.Visa
    % that is istalled together with NI VISA

    try
        netAnalyzer = VISA_Instrument('TCPIP::193.140.195.31::INSTR'); % Adjust the VISA Resource string to fit your instrument
        netAnalyzer.SetTimeoutMilliseconds(2000); % Timeout for VISA Read Operations
        % netAnalyzer.AddLFtoWriteEnd = false;
    catch ME
        error ('Error initializing the instrument:\n%s', ME.message);
    end

    netAnalyzer.Write('*CLS'); % to clear all status data structures in the device.
    %netAnalyzer.Write('*RST'); % to preset before operation

    idnResponse = netAnalyzer.QueryString('*IDN?'); % to obtain ID
    options = netAnalyzer.QueryString('*OPT?'); % to obtain device options
    err = netAnalyzer.QueryString(':SYST:ERR?'); % to get oldest error info
    scpiVersion = netAnalyzer.QueryString(':SYST:VERS?'); % to get SCPI version

    netAnalyzer.Write(':STAT:OPER?');
    status = char(netAnalyzer.ReadString());

    netAnalyzer.Write(':INST:PORT:COUN?'); 
    portNumber = char(netAnalyzer.ReadString());

    netAnalyzer.Write(':SYST:FREQ? MAX'); 
    maxFreq = char(netAnalyzer.ReadString());

    netAnalyzer.Write(':SYST:FREQ? MIN'); 
    minFreq = char(netAnalyzer.ReadString());

    swPoints = netAnalyzer.QueryInteger(':SWE:POIN?');

    netAnalyzer.Write(':MMEM:CAT?'); 
    capacityInfo = char(netAnalyzer.ReadString());

    netAnalyzer.Write(':CONF:CHAN:CAT?'); 
    channels = char(netAnalyzer.ReadString());

    sweepTime = netAnalyzer.QueryDouble(':SWE:TIME?');
    startFreq = netAnalyzer.QueryDouble(':FREQ:STAR?');
    stopFreq = netAnalyzer.QueryDouble(':FREQ:STOP?');

    % to print info about the device on the Command Window
    fprintf('Device: %s\n', idnResponse);
    fprintf('SCPI Version: %s\n', scpiVersion);
    fprintf('Number of Ports: %s\n', portNumber);
    fprintf('Maximum Frequency: %s\n', maxFreq);
    fprintf('Minimum Frequency: %s\n', minFreq);
    fprintf('Capacity Info: %s\n', capacityInfo);
    fprintf('Channels: %s\n', channels);
    fprintf('Options: %s\n', options);
    fprintf('Error: %s\n', err);
    fprintf('Status: %s\n', status);
    fprintf('Start Frequency: %d Hz\n', startFreq);
    fprintf('Stop Frequency: %d Hz\n', stopFreq);
    fprintf('Sweep Time: %s sec \n', sweepTime);
    fprintf('Sweep Points: %d \n', swPoints);

    % to set the display settings
    %netAnalyzer.Write(':SWE:TYPE LIN');
    %netAnalyzer.Write(':FREQ:STAR 0.1 GHz');
    %netAnalyzer.Write(':FREQ:STOP 2 GHz');

    % to set up the display and its parameters
    netAnalyzer.Write(':SYST:DISP:UPD ON'); % to set the built-in display of the device ON/OFF
    %netAnalyzer.Write(':INIT:CONT OFF');
    %netAnalyzer.Write(':SWE:POIN 201'); %number of sweep points
    %netAnalyzer.Write(':SWE:TIME 100ms');

    netAnalyzer.Write(':INIT:CONT ON'); % Start the sweep
    fprintf('Waiting for the sweep to finish... ');
    tic
    waitStr = netAnalyzer.QueryString('*OPC?'); % Using *OPC? query waits until the instrument finished the Acquisition
    toc
    netAnalyzer.ErrorChecking(); % Error Checking after the acquisition is finished
    % -----------------------------------------------------------
    % SyncPoint 'AcquisitionFinished' - the results are ready
    % -----------------------------------------------------------
    % Fetching the trace in ASCII format
    % -----------------------------------------------------------
    sweepPoints = netAnalyzer.QueryInteger(':SWE:POIN?'); % Query the expected sweep points
    fprintf('Fetching trace in ASCII format... ');
    
    netAnalyzer.Write(':CONF:TRAC:CAT?');
    traceCatalog = char(netAnalyzer.ReadString());
    fprintf('\nTrace Catalog: %s\n', traceCatalog);
    numTrace = (size(strfind(traceCatalog,','),2)+1)/2;

    % to read stimulus values of the active data. In our case, frequency(Hz).
    stimulusValues = netAnalyzer.QueryASCII_ListOfDoubles('FORM ASC;:CALC1:DATA:STIM?', sweepPoints);

    %'CALCulate<Ch>:DATA:SGRoup? FDAT' should be used to read the current
    %response values of all S-parameters associated to a group of logical ports
    tic
    chan1 = netAnalyzer.QueryASCII_ListOfDoubles('FORM ASC;:CALC1:DATA:ALL? SDAT', sweepPoints*2*numTrace); % sweepPoints*2*numTrace is the maximum possible allowed count to read
    toc
    fprintf('Sweep points count: %d\n', size(chan1, 2)/2/numTrace);

    for i = 1:numTrace
        real(i,:) = chan1(sweepPoints*2*(i-1)+1:2:sweepPoints*2*(i-1)+sweepPoints*2);
        imaginary(i,:) = chan1(sweepPoints*2*(i-1)+2:2:sweepPoints*2*(i-1)+sweepPoints*2);
        
        % rawData has this form: first row = frequencyRange,
        %                       second row = real of first trace
        %                       third row = imaginary of first trace
        %                       fourth row = real of second trace
        %                       fifth row = imaginary of second trace etc.
        rawData(1,:) = stimulusValues;
        rawData(2*i,:) = real(i,:);
        rawData(2*i+1,:) = imaginary(i,:);
        
        magdB(i,:) = 10*log10((real(i,:).^2)+(imaginary(i,:).^2));
        phaseAng(i,:) = atan(imaginary(i,:)./real(i,:));
    end
end
