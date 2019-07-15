///Updated 05 June 2018
//comments - 23/06/19
//debug and update 24/06/19 - batch mode temp disabled

//Dialog.create("Options");
//Dialog.addChoice("Type:", newArray("Bivalves", "Gastropods"));
  
//Dialog.addCheckbox("Clean Original Photo", true);
//Dialog.addCheckbox("Draw Bounding Box", true);
//Dialog.addCheckbox("Calculate Valve Orientation (only for bivalves)", false);

//Dialog.show();
 //clean = Dialog.getCheckbox();
 // bbox = Dialog.getCheckbox();
 // valve = Dialog.getCheckbox();
  
  //if (bbox ==true) //draw bounding box etc; 

////Set I/O Directories
dir1 = getDirectory("Choose Source Directory "); 
dir2 = getDirectory("Choose Destination Directory "); 
list = getFileList(dir1); //list of files in input dir

total_shell = 0; //global variable, shell counter for specimen numbers 

macro_file = getDirectory("plugins")+"Macros/"; //macro location path

////for each file (image) in input dir
for (i=0; i<list.length; i++) {  
	showProgress(i+1, list.length); //progress bar for input dir
	open(dir1+list[i]); //open image

////calibrate scale for measurements
	runMacro(macro_file + "SetCalibration.ijm"); //scale bar calibration macro
	run("Select None"); //ensure nothing selected
	
////object identification
	setBatchMode(true); //turn on batch mode, hides all images except active
	run("Duplicate...", "title=origCopy"); //create a copy of the active original image, entitled "origCopy"
	
	selectWindow(list[i]); //select image of interest
	
	run("RGB Stack"); //ImageJ function, convert image to RGB stack

	selectWindow(list[i]); //select image of interest
	run("Auto Threshold", "method=Triangle"); //thresholding to detect objects
	run("Fill Holes", "Red"); //fill any object internal holes in "Red" slice from RGB stack
	
	run("Stack to Images"); //convert RGB stack to seperate windows
	close("Blue"); //close Blue window (unused)
	close("Green"); //close Green window (unused)

	selectWindow("Red"); //select the Red window
 
	run("8-bit"); //convert to 8bit greyscale
	setOption("BlackBackground", false); //state is not black background --> once converted is black objects on white
	run("Make Binary"); //turn into true black and white. is necessary?
	//Erode and dilate in combination remove noise but effects are insignificant on measurements (test)
	run("Erode"); //remove pixels from around the edges of objects (will slightly shrink objects)
	run("Dilate"); //dilate restores pixels to object edges. couteracts erode.

	//choose the measurements which are collected by analyse particles
	run("Set Measurements...", "area centroid bounding feret's display redirect=None decimal=3"); //ImageJ function "Set Measurements", lists measurements taken, display - show measurements, redirect -?, decimal - no. decimal places  
	run("Analyze Particles...", "size=0.4-Infinity show=Nothing exclude clear display record"); //ImageJ function "Analyze Particles", size - size range in mm^2, show - , clear - , record - , no display - results not shown

////paste object masks into a new clean window
	run("Duplicate...", "title=Unrotated"); //duplicate active window, rename as "Unrotated"
	setBackgroundColor(255,255,255); //set background colour as black
	run("Select All"); //select everything in the image
	run("Clear"); //clear all in image (leaving black background)
	run("Select None"); //ensure nothing is selected

	setTool("wand"); //select wand tool (for uniform colour or thresholded objects)

	//for every object in the image
	for (k=0;k<nResults; k++){
	
		x = getResult("XStart", k); //x coordinate of the start of the particle (from analyzer)
		y =getResult("YStart", k); //y coordinate of the start of the particle (from analyzer)
	
		selectWindow("Red"); //select the red window
		doWand(x,y); //use wand tool in the centre of the object
	
		selectWindow("Unrotated"); //switch to window "Unrotated"
		run("Restore Selection"); //restore selection (from wand tool)
	
		setForegroundColor(0,0,0); //set foreground colour as white
		run("Fill", "slice"); //fill selection with foreground colour
		run("Select None"); //ensure nothing is selected
		
	} 

	close("Red"); //close the red window

////identify broken shells
	selectWindow("origCopy"); //select the Copy window produced earlier
	setTool("multipoint"); //select multipoint tool
	 
	setBatchMode("exit and display"); //exits batchmode and display hidden images

	ans=0; //set global variable for safety loop
	//while, runs block until ans /= 0
	while (ans == 0){
		Dialog.create("Broken Shells"); //create a dialog for user input
		Dialog.addNumber("How many broken shells present?", 0); //user input value - number of broken shells, preset value = 0
		Dialog.show(); //display dialog
		br = Dialog.getNumber(); // extract value (no. broken shells) from dialog
	
		//if broken shells present, identify them
		if (br>0){
			waitForUser("Select broken shells, then click OK"); //display instruction message and wait for user input (select broken shells)
			getSelectionCoordinates(brokenx, brokeny); //retrieve coordinates of broken shells
			run("Select None"); //ensure nothing is selected
	
			//check selected number of objects is the same as input value. If not, display error and reset.
			if (brokenx.length != br){ 
				showMessage("Error","Selected number of shells does not match expected");
			} else {
				ans=getBoolean("Broken shells =" + br + ". Is this correct?");
			} 
		} else {
			ans=getBoolean("Broken shells =" + br + ". Is this correct?");
		}
	}
	
	shells = nResults; //keep track of the number of results for data compliation

	//change shell label to the original image name, to keep track of data
	for (j=0; j < nResults; j++){
	setResult("Label", j, list[i]);
	}
	
	IJ.renameResults("PrelimResults"); //rename results to prevent overwriting

////gather drillhole data
	runMacro(macro_file + "DrillholeMeasurement.ijm"); //run Drillhole Measurement macro. Measures drillholes, produces reference numbers and labelled verification images

////save drill data and images then remove from the workspace
	if(isOpen("Drill")){ //if the labelled drill original image is open
		selectWindow("Drills"); //select the rotated shell mask and drillholes image
		run("Select None"); //ensure nothing is selected
	//place scalebar
		runMacro(macro_file + "SetScale.ijm"); //collects location of mouse click
		run("Scale Bar...", "width="+1 +" height=16 font=56 color=Black background=None location=[At Selection] bold"); //ImageJ function - scale bar. Appearance is set here.
		saveAs("Jpeg", dir2+list[i]+"drillholes"); //save rotated rotated mask and drillholes image
		
		selectWindow("Drill"); //select labelled drill original image
		saveAs("Jpeg", dir2+list[i]+"drillholes_drawn"); //save labelled drill original image
	
		close("*rill*"); //close all windows containing "rill" in the name

		selectWindow("Results"); //select results window with drillhole data
		saveAs("Results", dir2+"drill_measurements.csv"); //save as csv 
		close("Results"); //close drill results
	}	

	selectWindow("PrelimResults"); //select preliminary results
	IJ.renameResults("Results"); //rename results to interact

////create a copy of original shells on a solid black background
	runMacro(macro_file + "CleanOriginal.ijm"); 

////place new scale bars on produced image
	selectWindow("origCopy"); //select the copy of the original
	runMacro(macro_file + "SetScale.ijm"); //collects location of mouse click
	run("Scale Bar...", "width="+1 +" height=16 font=56 color=White background=None location=[At Selection] bold"); //ImageJ function - scale bar. Appearance is set here.
	run("Select None"); //ensure nothing is selected
	//selectWindow("Unrotated");
	//run("Select None");
	close("Results");

	saveAs("Jpeg", dir2+list[i]+"_original_edited"); //save image with cleaned background
	close(); //close the image

////collection of shell measurements

//rename image as original image name for easy data tracking
selectWindow("RotatedCopy"); //select the window to rename
	rename(list[i]); //rename from the filelist array
	
	//set the measurements for actual shell data collection
	run("Set Measurements...", "area centroid bounding feret's display redirect=None decimal=3");
	selectWindow(list[i]); //select rotated masks to work on

	//for the first image in the batch
	if (i == 0){
		run("Analyze Particles...", "size=0.25-Infinity show=Nothing exclude clear include display record"); //data collection //clear to ensure a clean start to data collection

		//for every object in the image
		for (k=0; k < nResults; k++){
			setResult("Shell", k, k+1);  //set the shell number in the results table
		}	
		
	//for all sequential images
	} else{
		selectWindow("shellmeasurements"); //select shell measurement data
		IJ.renameResults("Results"); //rename as results for interaction
		run("Analyze Particles...", "size=0.25-Infinity show=Nothing exclude include display record"); //data collection //clear is removed to retain all data

		//for every object in the image
		for (k=0; k < shells; k++){
			setResult("Shell", total_shell+k, k+1);//set the shell number in the results table
		}		
	}

	//if broken shells are present
	if (br > 0){
		for (k=0; k<brokenx.length; k++){ //for each broken shell
			for (j=total_shell; j<nResults; j++){ //for each shell
				//collect bounding box coord descriptors
				x1 = getResult("BX", j);
         		x2 = x1 + getResult("Width", j);
         		y1 = getResult("BY", j);
				y2 = y1 + getResult("Height", j);

				X = brokenx[k]; //x location of broken shell centroid
				Y = brokeny[k]; //y location of broken shell centroid

				toScaled(X,Y); //convert to scaled coordinates

				if(X > x1 && X < x2 && Y > y1 && Y < y2 ){ //if the centroid of broken shell lies within shell bounding box
					setResult("Broken", j, 1); //mark as broken in the data
				}
			} 
		}
	} else {
			setResult("Broken", total_shell, 0); //if not broken, mark as complete in the data
	}

	total_shell = shells+total_shell; //update the shell counter
	IJ.renameResults("shellmeasurements"); //rename shell data to preserve

	selectWindow(list[i]); //select rotated masks window

//draw ferets diameter and bounding box for measurement verification images
	runMacro(macro_file + "DrawFeretsDiameter.ijm"); //calculates and draws ferets diamter for each object in image
	
	selectWindow(list[i]); //select rotated clean mask window 
	run("Analyze Particles...", "size=0.25-Infinity show=Nothing exclude clear display record"); //measure data

	selectWindow(list[i]); //select rotated mask window
	runMacro(macro_file + "DrawBoundingBox.ijm"); //calculates and draws boundign box for each object
	close("Results"); //close the results table
	run("Select None"); //encure nothing is selected

////place new scale bars on produced image
	runMacro(macro_file + "SetScale.ijm"); //colects location of mouse click
	run("Scale Bar...", "width="+1 +" height=16 font=56 color=Black background=None location=[At Selection] bold");
	run("Select None"); //ensure nothing is selected
	saveAs("Jpeg", dir2+list[i]+"shell_measurements"); //save measurement verification image
	close(); //close window

////identify valve chiarality
	runMacro(macro_file + "ValveChirality.ijm"); //identifies if shell is left or rigt valve based on umbo position
	saveAs("Jpeg", dir2+list[i]+" valve_chirality"); //save valve chirality
	run("Select None"); //ensure nothing is selected
	close("*"); //close all open image windows
}

selectWindow("shellmeasurements"); //select shell measurements data
IJ.renameResults("Results"); //rename as results for interaction
saveAs("Results", dir2+"shell_measurements.csv"); //save results as csv file
close("Results"); //close results window


if (isOpen("Log")) {  //if the log is open
		selectWindow("Log"); //select the log
    	run("Close");  //close
} 

if (isOpen("ROI Manager")) { //if the roi manager is open
	selectWindow("ROI Manager");  //select roi manager
    run("Close"); //close
} 


