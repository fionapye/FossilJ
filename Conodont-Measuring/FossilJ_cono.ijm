///Updated 05 July 2019 - conodont measure version
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

//macro_file = getDirectory("plugins")+"Macros/"; //macro location path

////for each file (image) in input dir
for (i=0; i<list.length; i++) {  
	showProgress(i+1, list.length); //progress bar for input dir
	open(dir1+list[i]); //open image

////calibrate scale for measurements
	////Calibration
	ans=0; //global variable, for confirmation of correct calibration
	
	while (ans == 0){
		Dialog.create("Calibration"); //create dialog for calibration information
		val = Dialog.addNumber("Enter Scale Value", 2); //user input value scale length, preset value 2
		unit =Dialog.addString("Enter a Unit:", "mm"); //user input unit, preset mm, accepts um (micrometre)
		Dialog.show(); //display dialog for user to input information
	
		val = Dialog.getNumber(); //collect the value from the dialog
		unit = Dialog.getString(); //collect the unit from the dialog
	
			//conversion to mm if input unit is um. Ensures consistent units throughout
		if (val > 1000 && unit == "um"){
			val = val/1000;
			unit = "mm";
	}
	
		run("Select None"); //ensure nothing selected
		setTool("multipoint"); //set point and click tool for scalebar end selection
		waitForUser("Select Scale, then click OK."); //display instruction message and wait for user input (scale end selection)
		ans=getBoolean("Is the scale correct?"); //safety loop for setting the scalebar. if user inputs no, the scalebar selection starts over. if yes, the macro continues. 
		
	}
	
	getSelectionCoordinates(xPoints,yPoints); //get coordinates for the scalebar ends (creates X and Y array)
	x_val = xPoints; //extract x coordinates
	y_val = yPoints; //extract y coordinates
	    
	lx = x_val[0] - x_val[1]; //distance between x coordinates
	ly = y_val[0] - y_val[1]; //distance between y coordinates
	l = sqrt(lx*lx + ly*ly); //use pythagoras to calculate the length of the scalebar
	
	//ImageJ function "Set Scale". Distance - scale length in pix, known - value of scale in length, unit - units of scale, global - set as global
	run("Set Scale...", "distance="+l+" known="+val+" pixel=1 unit="+unit+" global");
	run("Select None"); //ensure nothing selected
	
////object identification
//	setBatchMode(true); //turn on batch mode, hides all images except active
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
	run("Analyze Particles...", "size=0.01-Infinity show=Nothing exclude clear display record"); //ImageJ function "Analyze Particles", size - size range in mm^2, show - , clear - , record - , no display - results not shown

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
	//while (ans == 0){
	//	Dialog.create("Broken Specimens"); //create a dialog for user input
	//	Dialog.addNumber("Number of broken specimens present", 0); //user input value - number of broken shells, preset value = 0
	//	Dialog.show(); //display dialog
	//	br = Dialog.getNumber(); // extract value (no. broken shells) from dialog
	
		//if broken shells present, identify them
	//	if (br>0){
	//		waitForUser("Select broken specimens, then click OK"); //display instruction message and wait for user input (select broken shells)
	//		getSelectionCoordinates(brokenx, brokeny); //retrieve coordinates of broken shells
	//		run("Select None"); //ensure nothing is selected
	
			//check selected number of objects is the same as input value. If not, display error and reset.
	//		if (brokenx.length != br){ 
	//			showMessage("Error","Selected number of specimens does not match expected");
	//		} else {
	//			ans=getBoolean("Broken specimens =" + br + ". Is this correct?");
	//		} 
	//	} else {
	//		ans=getBoolean("Broken specimens =" + br + ". Is this correct?");
	//	}
//	}
	
	shells = nResults; //keep track of the number of results for data compliation

	//change shell label to the original image name, to keep track of data
	for (j=0; j < nResults; j++){
	setResult("Label", j, list[i]);
	//setResult("label", j, "conodont.png");
	}

		//if broken shells are present
	//if (br > 0){
	//	for (k=0; k<brokenx.length; k++){ //for each broken shell
		//	for (j=0; j<nResults; j++){ //for each shell
//				//collect bounding box coord descriptors
		//		x1 = getResult("BX", j);
       // 		x2 = x1 + getResult("Width", j);
       // 		y1 = getResult("BY", j);
		//		y2 = y1 + getResult("Height", j);

		//		X = brokenx[k]; //x location of broken shell centroid
		//		Y = brokeny[k]; //y location of broken shell centroid

		//		toScaled(X,Y); //convert to scaled coordinates

		//		if(X > x1 && X < x2 && Y > y1 && Y < y2 ){ //if the centroid of broken shell lies within shell bounding box
		//			setResult("Broken", j, 1); //mark as broken in the data
		//		}
		//	} 
	//	}
//	} else {
//			setResult("Broken", total_shell, 0); //if not broken, mark as complete in the data
//	}
	
	IJ.renameResults("PrelimResults"); //rename results to prevent overwriting

////gather specimen measurement data
	//runMacro(macro_file + "DrillholeMeasurement.ijm"); //run Drillhole Measurement macro. Measures drillholes, produces reference numbers and labelled verification images
	//DRILLHOLES MACRO
//Updated 12/06/2018
//commented 23-24/06/2019


////gather information about drillholes present

//selectWindow("origCopy"); //select window containing the copy of the original
//might need n but how to collect?
//n = Dialog.getNumber(); //retrive number of drillholes


//ans=0; //set global variable for safety feature
//while, runs block until ans /= 0
//while (ans == 0){
//	Dialog.create("Drillholes"); //create dialog for drillhole information
//	Dialog.addNumber("How many drillholes present (total, complete and incomplete)?", 0); //user input value # drillholes, preset 0
//	Dialog.addNumber("How incomplete drillholes are present?", 0);//user input value # incomplete drillholes, preset 0
//	Dialog.show(); //display dialog
//	n = Dialog.getNumber(); //retrive number of drillholes
//	id = Dialog.getNumber(); //retrive number of incomplete drillholes
	
//	ans = getBoolean("Drillholes =" + n + " and Incomplete= "+id+". Is this correct?"); //check data is correct
//}

//selectWindow("PrelimResults"); //select preliminary results table
//IJ.renameResults("Results"); //rename as results for interaction
//shells = nResults; //count #results in the table, number of shells
//IJ.renameResults("PrelimResults"); //rename to preserve


////no loop needed, always require
////if drillholes are present, user selects and a record image is produced
////landmarks (measurement points)

	selectWindow("origCopy"); //select window with copy of the original
	run("Duplicate...", "title=Landmarks");
	run("Set Measurements...", "area bounding centroid feret's display redirect=None decimal=3");  //ImageJ function "Set Measurements", lists measurements taken:area (mm^2) boundingbox objectcentroid feretsdiameter  , display - show measurements, redirect -?, decimal - #decimal places  
	run("RGB Color");
	setTool("line"); //select line tool
	setForegroundColor(255,0,0); //set foreground colour to red

	//for every specimen in image draw the landmarks //needs safety feature
	selectWindow("Landmarks");
	for (j=0; j<shells; j++){
		for(k=0; k<3; k++){	
		waitForUser("Draw line " + (k+1) + " on specimen " + (j+1) + " then click OK"); //display instruction message and wait for user input (draw drillholes)
		roiManager("add & draw"); //adds selection to ROI manager and draws selection in image
		run("Select None"); //ensure nothing is selected
		}
	}



//if (n > 0){
	//selectWindow("origCopy"); //select copy of original
	//run("Duplicate...", "title=Drill"); //copy of original data, to print drillholes onto
	//run("Set Measurements...", "area bounding centroid feret's display redirect=None decimal=3");  //ImageJ function "Set Measurements", lists measurements taken:area (mm^2) boundingbox objectcentroid feretsdiameter  , display - show measurements, redirect -?, decimal - #decimal places  

	//setTool("ellipse"); //select ellipse tool, for drawing drillholes
	//setForegroundColor(255,255,255); //set foreground colour to white
	//setLineWidth(6); //set line width (px)

	//selectWindow("Drill"); //select the drills window
	//for every drillhole in drill image print the drawn drillhole
	//for (j=0; j<n; j++){
	//	waitForUser("Draw drillhole no." + (j+1) + " then click OK"); //display instruction message and wait for user input (draw drillholes)
	//	roiManager("add & draw"); //adds selection to ROI manager and draws selection in image
	//	run("Select None"); //ensure nothing is selected
//	}

	//run("Select None"); //ensure nothing is selected

////incomplete drillhole identification
	//if (id>0){
	//	ans1=0; //global variable for safety feature

		//while, runs block until ans1 /= 0
		//while (ans1 == 0){
			//run("Select None"); //ensure nothing is selected
			//setTool("multipoint"); //select multipoint tool
			//waitForUser("Click on incomplete drillholes, then click OK"); //display instruction message and wait for user input (incomplete drillhole selection)
			//getSelectionCoordinates(incompx, incompy); //retrieve coordinates of incomplete drillholes
			//run("Select None"); //ensure nothing is selected

			//check that selected number matches the input number
			//if (incompx.length != id){
			//	showMessage("Error","Number of incomplete drills does not match expected"); //if criteria not met, display error and reset
			//} else {
			//	ans1=1;
			//} 
		//}
	//}

	//setBatchMode(true); //turn on batch mode, hides all images except active

////create an image to display drillholes measured
	//selectWindow("Unrotated"); //select unrotated shells window
	//run("Select None"); //ensure nothing is selected
	//run("Duplicate...", "title=Drills"); //duplicate unrotated and rename as "Drills"
	//setForegroundColor(255, 255, 255); //set foreground colour white
	//roiManager("fill"); //paint all ROI from the manager (drawn drillholes) onto the shells

////dont think we need
////drillhole measurements - paste holes only onto page and measure, not seen by user
	//selectWindow("Unrotated"); //select unrotated window
	//run("Duplicate...", "title=Drill2"); //duplicate unrotated and rename as "Drill2"
	//setBackgroundColor(255,255,255); //set background colour as white
	//run("Select All"); //select whole window
	//run("Clear"); //clear window, leaving white image
	//setForegroundColor(0,0,0); //set foreground colour as black
	//roiManager("fill"); //paint all ROI from the manager (drawn drillholes) onto the shells
	//for the first image in the batch
	if (i == 0){
		//run("Analyze Particles...", "size=0.25-Infinity show=Nothing exclude clear include display record"); //data collection //clear to ensure a clean start to data collection
		roiManager("measure"); //measure all the lines drawn
		n = nResults;

		//for every object in the image
	for (k=0; k < nResults; k++){
		setResult("Line", k, "L"+k+1);  //set the shell number in the results table
		}	
		
	//for all sequential images
	} else{
		selectWindow("Drillholes"); //select shell measurement data
		IJ.renameResults("Results"); //rename as results for interaction
		//run("Analyze Particles...", "size=0.25-Infinity show=Nothing exclude include display record"); //data collection //clear is removed to retain all data
		roiManager("measure"); //measure all the lines drawn
		n = roiManager("count"); //count roi# in manager
		//for every object in the image
		for (k=0; k < n; k++){
			setResult("Line", total_drill+k, "L"+(k+1));//set the shell number in the results table
		
		}		
	}
////drillhole measurements are collected
	//if  (isOpen("Drillholes")){ //check drillhole data named results for interaction
	//	selectWindow("Drillholes"); //select the window to collect data from
	//	IJ.renameResults("Results"); //rename results table for input
	//}

	//collect measurements
	//run("Analyze Particles...", "size=0.01-Infinity show=Nothing exclude display record");  //ImageJ function "Analyze Particles", size - size range in mm^2, show - , clear - , record - 
	//roiManager("measure"); //measure all the lines drawn
	// n = nResults;
	roiManager("reset"); //clear the ROI manager 

	selectWindow("Results");
	IJ.renameResults("Drillholes"); //rename results (containing drillhole data) as drillholes

////assign labels in images and data to drillholes
	selectWindow("PrelimResults"); //select preliminary results
	IJ.renameResults("Results"); //rename prelimanary results as results for interaction

	lab = getResultLabel(0); //retrieve label (image name) from the first row of result

	//create arrays to store coordinates of shell bounding rectangle
	x1=newArray(shells); //bounding box x1 (upper left x)
 	x2=newArray(shells); //bounding box x2 (upper right x)
 	y1=newArray(shells); //bounding box y1 (upper left y)
 	y2=newArray(shells); //bounding box y2 (lower left y)
 	//area=newArray(shells); //area, for internal/external drillhole identification
		
 	//m = 0; //create global variable for counter in loop, could use the k?

 	//for every shell, put bounding box corner coordinates into arrays
 	for (k=0;k<nResults; k++){
 			
       	x1[k] = getResult("BX", k); //retrive and store bounding box x1 (upper left x)
       	x2[k] = x1[k] + getResult("Width", k); //caluclate and store bounding box x2 (upper right x)
       	y1[k] = getResult("BY", k); //retrive and store bounding box y1 (upper left y)
		y2[k] = y1[k] + getResult("Height", k); //calculate and store bounding box y2 (lower left y)
		//area[m] = getResult("Area", k); //area, for internal/external drillhole identification
		
	//	m= m+1; //counter
    } 

	selectWindow("Results"); //select shell data
	IJ.renameResults("PrelimResults"); //rename as preliminary

	selectWindow("Drillholes"); //select drillhole data
	IJ.renameResults("Results"); // rename as results for input

	total_drill=nResults; //total number of drills (all data,across images) from results table
	drill = total_drill - n; //selection of starting row for drillhole data input

	s = newArray(n); //new array, with the length of the number of drillholes (for what?)

	//for each drillhole in drillhole data
	for (j=drill; j<total_drill; j++) {
		//setResult("Line", j, "L" +(j+1)); //set name column to drillhole number
		setResult("Label", j, lab); //set the label column to the image name

		X = getResult("X", j); //x coord, centroid of drillhole
		Y = getResult("Y", j); //y coord, centroid of drillhole

////internal or edge drilling determination
		//for every shell, if the centroid of the drill lands within the shell
		for (k=0; k<x1.length; k++){
			if(X > x1[k] && X < x2[k] && Y > y1[k] && Y < y2[k] ){
				setResult("Specimen", j, (k+1)); //label drillhole with the shell it belongs to
				s[j-drill] = k+1;	
			}
		}
	}	

////broken shell input here?
		//if broken shells are present
	//if (br > 0){
	//	for (k=0; k<brokenx.length; k++){ //for each broken shell
	//		for (j=total_shell; j<nResults; j++){ //for each shell
	//			//collect bounding box coord descriptors
	//			x1 = getResult("BX", j);
    //     		x2 = x1 + getResult("Width", j);
    //     		y1 = getResult("BY", j);
	//			y2 = y1 + getResult("Height", j);

	//			X = brokenx[k]; //x location of broken shell centroid
	//			Y = brokeny[k]; //y location of broken shell centroid

	//			toScaled(X,Y); //convert to scaled coordinates
//
	//			if(X > x1 && X < x2 && Y > y1 && Y < y2 ){ //if the centroid of broken shell lies within shell bounding box
	//				setResult("Broken", j, 1); //mark as broken in the data
	//			}
	//		} 
	//	}
	//} else {
	//		setResult("Broken", total_shell, 0); //if not broken, mark as complete in the data
	//}

		//	selectWindow("Unrotated"); //select the window with unrotated objects
		//	run("Duplicate...", "title=temp1"); //duplicate and rename as temp1, 

			//isolate the coordinates of shell bounding box
		//	x_s = x1[k]; 
		//	y_s = y1[k]; 
		//	w_s= x2[k]-x1[k]; 
		//	h_s = y2[k]-y1[k];
			
		//	toUnscaled(x_s, y_s); //convert scaled coord to pixel coord
		//	toUnscaled(w_s, h_s); //convert scaled coord to pixel coord
		//	makeRectangle(x_s, y_s, w_s, h_s); //make rectangle with coordinates around shell
		//	run("Clear Outside"); //clears everything outside of the rectangle, retaining one shell
		//	run("Select None"); //ensure nothing is selected
			
		//	selectWindow("Drill2"); //select "Drill2" window, containing drillholes only
		//	run("Duplicate...", "title=temp2"); //duplicate and rename "temp2"
		//	makeRectangle(x_s, y_s, w_s, h_s); //make rectangle selection with coords around drillhole
		//	run("Clear Outside"); //clears everything outside of the rectangle, retaining one drillhole
		//	run("Select None"); //ensure nothing is selected

		//	imageCalculator("AND create", "temp1","temp2"); //ImageJ function image calculator, retains pixels present in both. temp1- blank shells, temp2 - drillholes only	
				
		//	IJ.renameResults("Drillholes"); //rename results as drillholes
		//	run("Analyze Particles...", "size=0.01-Infinity show=Nothing exclude clear display");

		//	area_temp = getResult("Area", 0); //retrive the area from the top row of results, drillhole area
		//	close("Results"); //close results 
		//	close("*temp*"); //close windows containing "temp"

		//	selectWindow("Drillholes"); //select drillhole data for input
		//	IJ.renameResults("Results"); //rename as results for interaction

			//set edge or internal into drillhole data
		//	if(area_temp > area[k]){
		//		setResult("Type", j, "Edge");
		//	} else {setResult("Type", j, "Internal");}
		//	}
			
		//}
	//}

	//drillhole completeness marked in data
	//for (j=drill; j<nResults; j++) {
	
		//if incomplete drillholes are present
		//if (id > 0){
			//for (k=0; k<incompx.length; k++){ //for each drillhole
	
					//bounding box coordinates
				//	x1 = getResult("BX", j);
	         	//	x2 = x1 + getResult("Width", j);
	         	//	y1 = getResult("BY", j);
				//	y2 = y1 + getResult("Height", j);
	
				//	X = incompx[k]; //coordinate for x of incomplete (from user selection)
				//	Y = incompy[k]; //coordinate for y of incomplete (from user selection)
	
				//	toScaled(X,Y); //from pixel to scaled coordinates
	
					//if coordinates of incomplete land within drill bounding box
				//	if(X > x1 && X < x2 && Y > y1 && Y < y2 ){ 
				//		setResult("Incomplete", j, 1); //mark incomplete with 1 in drillhole data
				//	}
				
				//} 
		//} else {setResult("Incomplete", j, 0);} //mark complete as 0 in drillhole data
	//}

////
	
	//IJ.renameResults("Drillholes"); //rename drillhole data
	
	//selectWindow("PrelimResults"); //select preliminary results
	//IJ.renameResults("Results"); //rename as results for interaction
	
	//ang = newArray(n); //new array (for what?)
	
	//for every drillhole (?)
	//for (j=0; j < n; j++){
	//	l = s[j] -1;
	//	ang[j] = getResult("FeretAngle", l); //angle of ferets diamter from horizontal(?)
		
	//}
	
	//selectWindow("Results"); //select the active results
	//IJ.renameResults("PrelimResults"); //rename as preliminary
	
	//selectWindow("Drillholes"); //select drillhole data
	//IJ.renameResults("Results"); //rename as results for interaction
	
	//242 - 243, noted out 23/06/19 check if needed then remove
		//selectWindow("Drills"); //remove if loop works (old note, investigate)					//
		//run("Duplicate...", "title=NewDrills"); //duplicate window with drills printed on shells and rename
	
	//label drillholes in images, for every drillhole
	for (j=drill; j<nResults; j++){
				
			xx = getResult("X", j); //centroid of drill, x
			yy = getResult("Y", j); //centroid of drill, y 
			name = getResultString("Line", j); //extract drill number from data
			
			setLineWidth(4); //set line thickness (px)
			setFont("SansSerif", 15, "bold"); //set font type, size and style
			toUnscaled(xx,yy); //convert coords to pixel coordinates
			
			selectWindow("Landmarks"); //select the window with drills printed on shells 
			setForegroundColor(0, 255, 0); //green
			drawString(name, xx, yy); //print drill label onto image
	
			//selectWindow("Drill"); //select the window with drillholes drawn on orig shell image
			//setForegroundColor(255,255,255); //set foreground colour to white
			//drawString(name, xx-30, yy); //print drill label onto image
	}	
	
	//user verification of internal/edge identifications
	//selectWindow("Drill"); //select window to make visible to user for verification
	//Dialog.create("Drill Hole Type"); //create dialog
	//choices = newArray("Internal", "Edge"); //options for dialog, for user verification of calculations
	
	//for each drillhole
	//for (j=drill; j<nResults; j++){
	//Dialog.addChoice(getResultString("Name", j), choices, getResultString("Type",j));
	///} //create dialog choices for dropdown
	//Dialog.show(); //show verification dialog
	
	//for each drillhole
	//for (j=drill; j<nResults; j++){
	//	type = Dialog.getChoice(); //get user verified type from dialog
	//	setResult("Type", j, type); //update results table
	//}
	
	//roiManager("reset"); //clear the ROI manager
	selectWindow("ROI Manager"); //select the ROI manager
	run("Close"); //close window
	
	selectWindow("Results"); //select the drillhole data 
	IJ.renameResults("Drillholes"); //rename as drillholes
	


////create image with rotated shell masks
	////align drillholes with rotated shells in image
	
//create blank window
//selectWindow("Unrotated"); //select window with unrotated shell masks
//run("Duplicate...", "title=Rotated"); //duplicate and rename 
	//run("Select All"); //select everything in this window
	//setBackgroundColor(255,255,255); //set background colour as black
	//run("Clear"); //clear the window to leave the background colour only
	//run("Select None"); //ensure nothing is selected

//selectWindow("PrelimResults"); //select preliminary results
//IJ.renameResults("Results"); //rename for interaction

//for every shell
//for (k=0;k<nResults; k++){

	//x = getResult("XStart", k); //x coordinate of the start of the particle (from analyzer)
	//y = getResult("YStart", k); //y coordinate of the start of the particle (from analyzer)
	
	//selectWindow("Unrotated"); //select unrotated shells window
	//doWand(x,y); //wand tool at coordinates
	
	//selectWindow("Rotated"); //select new blank canvas
	//run("Restore Selection"); //restore the wand selection

//	angle = getResult("FeretAngle", k); //retrive feret angle, degrees from horizontal

//this needs looking into and checking - below is different? line 374
//	if (angle>90 && angle < 120) // for angles in this range
 //    angle -= 90; // convert to angle from vertical (shorthand subtraction notation)

//    if (angle>120) //for large angles
//     angle -= 180; //convert to angle from vertical (shorthand subtraction notation)
     
//	theta = -angle*PI/180; //convert to theta for trig 
//	getBoundingRect(xbase, ybase, width, height); //location and size of the bounding rectangle for the shell
///	xcenter=xbase+width/2; ycenter=ybase+height/2; //identify the centre of the bounding rectangle for the shell
//	getSelectionCoordinates(x, y); //retrive coordinates of the start of the particle

	//maths, calculate the new position of each shell
//	for (i=0; i<x.length; i++) { 
//      dx=x[i]-xcenter; dy=ycenter-y[i];
//      r = sqrt(dx*dx+dy*dy);
 //     a = atan2(dy, dx);
 //     x[i] = xcenter + r*cos(a+theta);
 //     y[i] = ycenter - r*sin(a+theta);
//	}

	
//   makeSelection(selectionType, x, y); 
//	setForegroundColor(0,0,0); //set foreground colour to black
//	run("Fill", "slice"); //paste rotated shell mask into rotated window

//} 

////create rotated mask windows for further use
//selectWindow("Rotated"); //select window with rotated masks
//run("Select None"); //ensure nothing is selected
//run("Duplicate...", "title=RotatedCopy"); //duplicate and rename
//selectWindow("Rotated"); //select window with rotated masks
//run("Duplicate...", "title=Valve"); //duplicate and rename

////place rotated drillholes onto rotated shell masks

//selectWindow("Results"); //select results
//IJ.renameResults("PrelimResults"); //rename results as preliminary to preserve
//run("Select None"); //ensure nothing is selected

//if there are drillholes
//if (n > 0){
//	selectWindow("Drillholes"); //select the drillhole data window
//	IJ.renameResults("Results"); //rename as results for interaction
	
	//for every new drillhole
//	for (k=drill;k<total_drill; k++){ 
	
//		x = getResult("XStart", k); //x coordinate of the start of the particle (from analyzer)
//		y = getResult("YStart", k); //y coordinate of the start of the particle (from analyzer)
	
//		selectWindow("Rotated"); //select the rotated shells window containing rotated shell masks
//		doWand(x,y); //wand tool at coordinates of particle
	
//		angle = ang[k-drill]; //what is this?
//		
//		if (angle>90)
//	     angle -= 180; //convert to angle from vertical (shorthand subtraction notation)
//	     
//		theta = -angle*PI/180; //convert to theta for trig 
//		getBoundingRect(xbase, ybase, width, height); //get bounding rectangle for the selection
//		xcenter=xbase+width/2; ycenter=ybase+height/2; //calculate the centre of the bounding rectangle
		
//		selectWindow("Drill2"); //select window with drillholes only
//			doWand(x,y); //wand tool at coordinates for the start of the particle
			
//		selectWindow("Rotated"); //select the rotated window containing rotated shell masks 
//			run("Restore Selection"); //restore wand selection from Drill2, drillholes only
				
//		getSelectionCoordinates(x, y); //retrive the coordinates of the selection

		//maths, caluclate the new position of the drillhole
//	 	for (i=0; i<x.length; i++) {
//			dx=x[i]-xcenter; dy=ycenter-y[i];
//			r = sqrt(dx*dx+dy*dy);
//			a = atan2(dy, dx);
//			x[i] = xcenter + r*cos(a+theta);
//			y[i] = ycenter - r*sin(a+theta);
//		}

		
//		makeSelection(selectionType, x, y);
//			setForegroundColor(255,255,255); //set foreground colour to white
//			run("Fill", "slice"); //paste rotated drillholes onto shells
//			run("Select None"); //ensure nothing is selected
//	} 
//}

//close("Rotated");
//setBatchMode("exit and display"); //exit batch mode and display hidden windows


////save drill data and images then remove from the workspace
	//if(isOpen("Drill")){ //if the labelled drill original image is open
		//selectWindow("origCopy"); //select the rotated shell mask and drillholes image
		//run("Select None"); //ensure nothing is selected
	//place scalebar in the new image
		//place scalebar
		//runMacro(macro_file + "SetScale.ijm"); //collects location of mouse click
		//run("Scale Bar...", "width="+1 +" height=16 font=56 color=White background=None location=[At Selection] bold"); //ImageJ function - scale bar. Appearance is set here.
		//saveAs("Jpeg", dir2+list[i]+"landmarks"); //save rotated rotated mask and drillholes image
		
		//selectWindow("Drill"); //select labelled drill original image
		//saveAs("Jpeg", dir2+list[i]+"drillholes_drawn"); //save labelled drill original image
	
		//close("*rill*"); //close all windows containing "rill" in the name

		//selectWindow("Drillholes"); //select results window with drillhole data
		//saveAs("Results", dir2+"landmark_measurements.csv"); //save as csv 
		//close("Results"); //close drill results
	//}


	selectWindow("PrelimResults"); //select preliminary results
	IJ.renameResults("Results"); //rename results to interact

////create a copy of original shells on a solid black background
	//runMacro(macro_file + "CleanOriginal.ijm"); 
		
	//setBatchMode("hide"); //hide the active image and start batch mode
	selectWindow("Unrotated"); //select the unrotated mask window
	run("Create Selection"); //select the shell mask
		
		selectWindow("origCopy"); //select the copy of the original image
		run("Restore Selection"); //restore the selection from the unrotated mask window
		run("Make Inverse"); //select the background
		setForegroundColor(0, 0, 0); //set foreground colour to black
		run("Fill", "slice"); //colour in the background around the shell
	
		run("Select None"); //ensure nothing is selected
		
		setFont("SansSerif", 25, "bold"); //set font: type, size (px), emphasis
	
		//print specimen number on image
		for (k=0; k<nResults; k++) {	
			x = getResult("BX", k); //retrieve the bounding box upper left corner x
			y = getResult("BY", k); //retrive the bounding box upper left corner y
			toUnscaled(x,y); //convert xy coords to unscaled pixel values
			
			setForegroundColor(0, 255, 0); //green
			drawString(k+1, x, y); //draw string (number of the shell) 
			selectWindow("Landmarks"); //select the window with drills printed on shells 
			drawString(k+1, x, y); //draw string (number of the shell) 
		}

	//save image
	selectWindow("Landmarks");
	saveAs("Jpeg", dir2+list[i]+"_landmarks"); //save

		
	selectWindow("Unrotated"); //select unrotated window
	run("Select None"); //ensure nothing is selected
	//setBatchMode("exit and display"); //exit batch mode and display hidden images
	


////place new scale bars on produced image
	//selectWindow("origCopy"); //select the copy of the original
	//runMacro(macro_file + "SetScale.ijm"); //collects location of mouse click
	////get cursor location 
	
	//showMessage("Please click to place scale bar"); //display instruction message for user
	
	//shift=1;
	//ctrl=2; 
	//rightButton=4;
//	alt=8;
//	leftButton=16;
//	insideROI = 32; // requires 1.42i or later
	
//	x2=-1; y2=-1; z2=-1; flags2=-1;
//	logOpened = false;
	
//	j=0;
//	x_val = newArray(2);
//	y_val = newArray(2);
	
//	while (j<1){
//		getCursorLoc(x, y, z, flags);
//	    if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
	              
//	              if (flags&leftButton!=0) {
//					x_val = x;
//					y_val = y;
			
//					j = j+1;
					
//					}
	             
	//              	//logOpened = true;
//	              	startTime = getTime();
//	          }
	          
//	          x2=x; y2=y; z2=z; flags2=flags;
//	          wait(10);
//	      }
	
//	x = x_val; //x coordinate for scalebar
///	y = y_val; //y coordinate for scalebar
	
//	makePoint(x,y); //creates point selection at coordinates
	
//	run("Scale Bar...", "width="+1 +" height=16 font=56 color=White background=None location=[At Selection] bold"); //ImageJ function - scale bar. Appearance is set here.
//	run("Select None"); //ensure nothing is selected
	//selectWindow("Unrotated");
	//run("Select None");
//	close("Results");

//	saveAs("Jpeg", dir2+list[i]+"_original_clean"); //save image with cleaned background
//	close(); //close the image

////collection of shell measurements

//rename image as original image name for easy data tracking
//selectWindow("RotatedCopy"); //select the window to rename
///	rename(list[i]); //rename from the filelist array
	
	//set the measurements for actual shell data collection
//	run("Set Measurements...", "area centroid bounding feret's display redirect=None decimal=3");
//	selectWindow(list[i]); //select rotated masks to work on

	//for the first image in the batch
	//if (i == 0){
	//	run("Analyze Particles...", "size=0.25-Infinity show=Nothing exclude clear include display record"); //data collection //clear to ensure a clean start to data collection

		//for every object in the image
	//for (k=0; k < nResults; k++){
	//	setResult("Shell", k, k+1);  //set the shell number in the results table
	//	}	
		
	//for all sequential images
//	} else{
//		selectWindow("shellmeasurements"); //select shell measurement data
//		IJ.renameResults("Results"); //rename as results for interaction
//		run("Analyze Particles...", "size=0.25-Infinity show=Nothing exclude include display record"); //data collection //clear is removed to retain all data

		//for every object in the image
	//	for (k=0; k < shells; k++){
	//		setResult("Shell", total_shell+k, k+1);//set the shell number in the results table
// }		
//	}

	//if broken shells are present
//	if (br > 0){
//		for (k=0; k<brokenx.length; k++){ //for each broken shell
//			for (j=total_shell; j<nResults; j++){ //for each shell
//				//collect bounding box coord descriptors
//				x1 = getResult("BX", j);
 //        		x2 = x1 + getResult("Width", j);
 //        		y1 = getResult("BY", j);
//				y2 = y1 + getResult("Height", j);

//				X = brokenx[k]; //x location of broken shell centroid
//				Y = brokeny[k]; //y location of broken shell centroid

//				toScaled(X,Y); //convert to scaled coordinates

//				if(X > x1 && X < x2 && Y > y1 && Y < y2 ){ //if the centroid of broken shell lies within shell bounding box
//					setResult("Broken", j, 1); //mark as broken in the data
//				}
//			} 
//		}
//	} else {
//			setResult("Broken", total_shell, 0); //if not broken, mark as complete in the data
//	}

	total_shell = shells+total_shell; //update the shell counter
//	IJ.renameResults("shellmeasurements"); //rename shell data to preserve

	//selectWindow(list[i]); //select rotated masks window

//draw ferets diameter and bounding box for measurement verification images
	//runMacro(macro_file + "DrawFeretsDiameter.ijm"); //calculates and draws ferets diamter for each object in image
	
	//selectWindow(list[i]); //select rotated clean mask window 
	//run("Analyze Particles...", "size=0.25-Infinity show=Nothing exclude clear display record"); //measure data

	//selectWindow(list[i]); //select rotated mask window
	//runMacro(macro_file + "DrawBoundingBox.ijm"); //calculates and draws boundign box for each object
	//close("Results"); //close the results table
	//run("Select None"); //encure nothing is selected

////place new scale bars on produced image
	//runMacro(macro_file + "SetScale.ijm"); //colects location of mouse click
	//run("Scale Bar...", "width="+1 +" height=16 font=56 color=Black background=None location=[At Selection] bold");
	//run("Select None"); //ensure nothing is selected
	//saveAs("Jpeg", dir2+list[i]+"shell_measurements"); //save measurement verification image
	//close(); //close window

////identify valve chiarality
	//runMacro(macro_file + "ValveChirality.ijm"); //identifies if shell is left or rigt valve based on umbo position
	//saveAs("Jpeg", dir2+list[i]+" valve_chirality"); //save valve chirality
	//run("Select None"); //ensure nothing is selected
	close("*"); //close all open image windows
}

selectWindow("Drillholes"); //select shell measurements data
IJ.renameResults("Results"); //rename as results for interaction
saveAs("Results", dir2+"landmark_measurements.csv"); //save results as csv file
close("Results"); //close results window


if (isOpen("Log")) {  //if the log is open
		selectWindow("Log"); //select the log
    	run("Close");  //close
} 

if (isOpen("ROI Manager")) { //if the roi manager is open
	selectWindow("ROI Manager");  //select roi manager
    run("Close"); //close
} 


