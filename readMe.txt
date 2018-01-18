Rohde & Schwarz Network Analyzer Remote Sensing - MATLAB
by Sinan Yilmaz
Bogazici University Electrical-Electronics Engineering / MNCL

MATLAB_directSCPI_NetworkAnalyzer_MNCL.m
1- Check the IP address of the hardware entered in "MATLAB_directSCPI_NetworkAnalyzer_MNCL.m"
2- Make sure that all traces have the same "number of sweep points."
3- Provided code will measure all of the traces in the Channel 1.
	Alter the code accordingly:
		chan1 = netAnalyzer.QueryASCII_ListOfDoubles('FORM ASC;:CALC1:DATA:ALL? SDAT', sweepPoints*2*numTrace);
		chan2 = netAnalyzer.QueryASCII_ListOfDoubles('FORM ASC;:CALC2:DATA:ALL? SDAT', sweepPoints*2*numTrace);
4- Raw data is saved in default. You may access the magnitude or phase directly by changing the output in .
5- Raw data has the form: 	first row = frequencyRange,
				second row = real part of first trace
				third row = imaginary part of first trace
				fourth row = real part of second trace
				fifth row = imaginary part of second trace
				etc.

----------------------------

GUI - networkAnalyzerDisplay.m
1- "Show traces on Channel 1" button will start updating the figure in every ... second. Timer information is taken from the "editted text 1" next to the button.
2- After pushing the button first time, the button will be "Taking data... Press to restart." Pressing the button again will restart updating figure according to new timer value.
3- "Start Autosave" button will start saving the data to the specified folder.
	Alter the code accordingly:
		xlswrite(strcat('C:\directory...\','rawDataSaved',num2str(countFigureAfterAutosave*timer2),'.xlsx'),rawDataSaved);
4- Autosave mode starts counting when "Start Autosave" button is enabled. Saves .xlsx or .png file in every ... second. Timer information is taken from the "editted text 2" next to the button.
	Example: Timer2 = 3 seconds. Saved files in the specified directory:
								rawDataSaved3.xlsx
								rawDataSaved6.xlsx
								rawDataSaved9.xlsx
								etc.
	*Avoid overwriting by changing the directory or name of the saved files in "xlswrite" function.
5- There are other saving methods available in the code. Please examine the "pushbutton1_Callback" function for further methods.
6- "Save Figure" button is used to capture the instant picture of the figure as .png file. This starts counting from the beginning of updating figure.
	When "Show traces on Channel 1" or "Taking data... Press to restart" buttons are pressed.
7- By using the right menu, you can communicate with the hardware to change the number of sweep points, start frequency and stop frequency.
8- Above that, there is a pop-up menu and a button. You can add another trace on the axis.
9- If you would like to display those traces on the device display, you can uncomment necessary lines of "pushbutton6_Callback" in "networkAnalyzerDisplay.m" file.
10- Below the right menu, there is a reset button which corresponds to PRESET function of the device.