//DRILLHOLES MACRO
//Updated 12/06/2018
//commented 23-24/06/2019


////gather information about drillholes present

selectWindow("origCopy"); //select window containing the copy of the original

ans=0; //set global variable for safety feature
//while, runs block until ans /= 0
while (ans == 0){
	Dialog.create("Drillholes"); //create dialog for drillhole information
	Dialog.addNumber("How many drillholes present (total, complete and incomplete)?", 0); //user input value # drillholes, preset 0
	Dialog.addNumber("How incomplete drillholes are present?", 0);//user input value # incomplete drillholes, preset 0
	Dialog.show(); //display dialog
	n = Dialog.getNumber(); //retrive number of drillholes
	id = Dialog.getNumber(); //retrive number of incomplete drillholes
	
	ans = getBoolean("Drillholes =" + n + " and Incomplete= "+id+". Is this correct?"); //check data is correct
}

selectWindow("PrelimResults"); //select preliminary results table
IJ.renameResults("Results"); //rename as results for interaction
shells = nResults; //count #results in the table, number of shells
IJ.renameResults("PrelimResults"); //rename to preserve

////if drillholes are present, user selects and a record image is produced
if (n > 0){
	selectWindow("origCopy"); //select copy of original
	run("Duplicate...", "title=Drill"); //copy of original data, to print drillholes onto
	run("Set Measurements...", "area bounding centroid feret's display redirect=None decimal=3");  //ImageJ function "Set Measurements", lists measurements taken:area (mm^2) boundingbox objectcentroid feretsdiameter  , display - show measurements, redirect -?, decimal - #decimal places  

	setTool("ellipse"); //select ellipse tool, for drawing drillholes
	setForegroundColor(255,255,255); //set foreground colour to white
	setLineWidth(6); //set line width (px)

	selectWindow("Drill"); //select the drills window
	//for every drillhole in drill image print the drawn drillhole
	for (j=0; j<n; j++){
		waitForUser("Draw drillhole no." + (j+1) + " then click OK"); //display instruction message and wait for user input (draw drillholes)
		roiManager("add & draw"); //adds selection to ROI manager and draws selection in image
		run("Select None"); //ensure nothing is selected
	}

	run("Select None"); //ensure nothing is selected

////incomplete drillhole identification
	if (id>0){
		ans1=0; //global variable for safety feature

		//while, runs block until ans1 /= 0
		while (ans1 == 0){
			run("Select None"); //ensure nothing is selected
			setTool("multipoint"); //select multipoint tool
			waitForUser("Click on incomplete drillholes, then click OK"); //display instruction message and wait for user input (incomplete drillhole selection)
			getSelectionCoordinates(incompx, incompy); //retrieve coordinates of incomplete drillholes
			run("Select None"); //ensure nothing is selected

			//check that selected number matches the input number
			if (incompx.length != id){
				showMessage("Error","Number of incomplete drills does not match expected"); //if criteria not met, display error and reset
			} else {
				ans1=1;
			} 
		}
	}

	setBatchMode(true); //turn on batch mode, hides all images except active

////create an image to display drillholes measured
	selectWindow("Unrotated"); //select unrotated shells window
	run("Select None"); //ensure nothing is selected
	run("Duplicate...", "title=Drills"); //duplicate unrotated and rename as "Drills"
	setForegroundColor(255, 255, 255); //set foreground colour white
	roiManager("fill"); //paint all ROI from the manager (drawn drillholes) onto the shells

////drillhole measurements - paste holes only onto page and measure, not seen by user
	selectWindow("Unrotated"); //select unrotated window
	run("Duplicate...", "title=Drill2"); //duplicate unrotated and rename as "Drill2"
	setBackgroundColor(255,255,255); //set background colour as white
	run("Select All"); //select whole window
	run("Clear"); //clear window, leaving white image
	setForegroundColor(0,0,0); //set foreground colour as black
	roiManager("fill"); //paint all ROI from the manager (drawn drillholes) onto the shells

////drillhole measurements are collected
	if  (isOpen("Drillholes")){ //check drillhole data named results for interaction
		selectWindow("Drillholes"); //select the window to collect data from
		IJ.renameResults("Results"); //rename results table for input
	}

	//collect measurements
	run("Analyze Particles...", "size=0.01-Infinity show=Nothing exclude display record");  //ImageJ function "Analyze Particles", size - size range in mm^2, show - , clear - , record - 

	roiManager("reset"); //clear the ROI manager 

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
 	area=newArray(shells); //area, for internal/external drillhole identification
		
 	m = 0; //create global variable for counter in loop, could use the k?

 	//for every shell, put bounding box corner coordinates into arrays
 	for (k=0;k<nResults; k++){
 			
       	x1[m] = getResult("BX", k); //retrive and store bounding box x1 (upper left x)
       	x2[m] = x1[m] + getResult("Width", k); //caluclate and store bounding box x2 (upper right x)
       	y1[m] = getResult("BY", k); //retrive and store bounding box y1 (upper left y)
		y2[m] = y1[m] + getResult("Height", k); //calculate and store bounding box y2 (lower left y)
		area[m] = getResult("Area", k); //area, for internal/external drillhole identification
		
		m= m+1; //counter
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
		setResult("Name", j, "D" +(j+1)); //set name column to drillhole number
		setResult("Label", j, lab); //set the label column to the image name

		X = getResult("X", j); //x coord, centroid of drillhole
		Y = getResult("Y", j); //y coord, centroid of drillhole

////internal or edge drilling determination
	//for every shell, if the centroid of the drill lands within the shell
	for (k=0; k<x1.length; k++){
		if(X > x1[k] && X < x2[k] && Y > y1[k] && Y < y2[k] ){
			setResult("Shell", j, (k+1)); //label drillhole with the shell it belongs to
			s[j-drill] = k+1;	

			selectWindow("Unrotated"); //select the window with unrotated objects
			run("Duplicate...", "title=temp1"); //duplicate and rename as temp1, 

			//isolate the coordinates of shell bounding box
			x_s = x1[k]; 
			y_s = y1[k]; 
			w_s= x2[k]-x1[k]; 
			h_s = y2[k]-y1[k];
			
			toUnscaled(x_s, y_s); //convert scaled coord to pixel coord
			toUnscaled(w_s, h_s); //convert scaled coord to pixel coord
			makeRectangle(x_s, y_s, w_s, h_s); //make rectangle with coordinates around shell
			run("Clear Outside"); //clears everything outside of the rectangle, retaining one shell
			run("Select None"); //ensure nothing is selected
			
			selectWindow("Drill2"); //select "Drill2" window, containing drillholes only
			run("Duplicate...", "title=temp2"); //duplicate and rename "temp2"
			makeRectangle(x_s, y_s, w_s, h_s); //make rectangle selection with coords around drillhole
			run("Clear Outside"); //clears everything outside of the rectangle, retaining one drillhole
			run("Select None"); //ensure nothing is selected

			imageCalculator("AND create", "temp1","temp2"); //ImageJ function image calculator, retains pixels present in both. temp1- blank shells, temp2 - drillholes only	
				
			IJ.renameResults("Drillholes"); //rename results as drillholes
			run("Analyze Particles...", "size=0.01-Infinity show=Nothing exclude clear display");

			area_temp = getResult("Area", 0); //retrive the area from the top row of results, drillhole area
			close("Results"); //close results 
			close("*temp*"); //close windows containing "temp"

			selectWindow("Drillholes"); //select drillhole data for input
			IJ.renameResults("Results"); //rename as results for interaction

			//set edge or internal into drillhole data
			if(area_temp > area[k]){
				setResult("Type", j, "Edge");
			} else {setResult("Type", j, "Internal");}
			}
			
		}
	}

	//drillhole completeness marked in data
	for (j=drill; j<nResults; j++) {
	
		//if incomplete drillholes are present
		if (id > 0){
			for (k=0; k<incompx.length; k++){ //for each drillhole
	
					//bounding box coordinates
					x1 = getResult("BX", j);
	         		x2 = x1 + getResult("Width", j);
	         		y1 = getResult("BY", j);
					y2 = y1 + getResult("Height", j);
	
					X = incompx[k]; //coordinate for x of incomplete (from user selection)
					Y = incompy[k]; //coordinate for y of incomplete (from user selection)
	
					toScaled(X,Y); //from pixel to scaled coordinates
	
					//if coordinates of incomplete land within drill bounding box
					if(X > x1 && X < x2 && Y > y1 && Y < y2 ){ 
						setResult("Incomplete", j, 1); //mark incomplete with 1 in drillhole data
					}
				
				} 
		} else {setResult("Incomplete", j, 0);} //mark complete as 0 in drillhole data
	}

////
	
	IJ.renameResults("Drillholes"); //rename drillhole data
	
	selectWindow("PrelimResults"); //select preliminary results
	IJ.renameResults("Results"); //rename as results for interaction
	
	ang = newArray(n); //new array (for what?)
	
	//for every drillhole (?)
	for (j=0; j < n; j++){
		l = s[j] -1;
		ang[j] = getResult("FeretAngle", l); //angle of ferets diamter from horizontal(?)
		
	}
	
	selectWindow("Results"); //select the active results
	IJ.renameResults("PrelimResults"); //rename as preliminary
	
	selectWindow("Drillholes"); //select drillhole data
	IJ.renameResults("Results"); //rename as results for interaction
	
	//242 - 243, noted out 23/06/19 check if needed then remove
		//selectWindow("Drills"); //remove if loop works (old note, investigate)					//
		//run("Duplicate...", "title=NewDrills"); //duplicate window with drills printed on shells and rename
	
	//label drillholes in images, for every drillhole
	for (j=drill; j<nResults; j++){
				
			xx = getResult("X", j); //centroid of drill, x
			yy = getResult("Y", j); //centroid of drill, y 
			name = getResultString("Name", j); //extract drill number from data
			
			setLineWidth(4); //set line thickness (px)
			setFont("SansSerif", 50, "bold"); //set font type, size and style
			toUnscaled(xx,yy); //convert coords to pixel coordinates
			
			selectWindow("Drills"); //select the window with drills printed on shells 
			setForegroundColor(0,0,0); //set foreground colour to black
			drawString(name, xx-30, yy); //print drill label onto image
	
			selectWindow("Drill"); //select the window with drillholes drawn on orig shell image
			setForegroundColor(255,255,255); //set foreground colour to white
			drawString(name, xx-30, yy); //print drill label onto image
	}	
	
	//user verification of internal/edge identifications
	selectWindow("Drill"); //select window to make visible to user for verification
	Dialog.create("Drill Hole Type"); //create dialog
	choices = newArray("Internal", "Edge"); //options for dialog, for user verification of calculations
	
	//for each drillhole
	for (j=drill; j<nResults; j++){
	Dialog.addChoice(getResultString("Name", j), choices, getResultString("Type",j));
	} //create dialog choices for dropdown
	Dialog.show(); //show verification dialog
	
	//for each drillhole
	for (j=drill; j<nResults; j++){
		type = Dialog.getChoice(); //get user verified type from dialog
		setResult("Type", j, type); //update results table
	}
	
	roiManager("reset"); //clear the ROI manager
	selectWindow("ROI Manager"); //select the ROI manager
	run("Close"); //close window
	
	selectWindow("Results"); //select the drillhole data 
	IJ.renameResults("Drillholes"); //rename as drillholes
	
} 

////create image with rotated shell masks
	////align drillholes with rotated shells in image
	
//create blank window
selectWindow("Unrotated"); //select window with unrotated shell masks
run("Duplicate...", "title=Rotated"); //duplicate and rename 
	run("Select All"); //select everything in this window
	setBackgroundColor(255,255,255); //set background colour as black
	run("Clear"); //clear the window to leave the background colour only
	run("Select None"); //ensure nothing is selected

selectWindow("PrelimResults"); //select preliminary results
IJ.renameResults("Results"); //rename for interaction

//for every shell
for (k=0;k<nResults; k++){

	x = getResult("XStart", k); //x coordinate of the start of the particle (from analyzer)
	y = getResult("YStart", k); //y coordinate of the start of the particle (from analyzer)
	
	selectWindow("Unrotated"); //select unrotated shells window
	doWand(x,y); //wand tool at coordinates
	
	selectWindow("Rotated"); //select new blank canvas
	run("Restore Selection"); //restore the wand selection

	angle = getResult("FeretAngle", k); //retrive feret angle, degrees from horizontal

//this needs looking into and checking - below is different? line 374
	if (angle>90 && angle < 120) // for angles in this range
     angle -= 90; // convert to angle from vertical (shorthand subtraction notation)

    if (angle>120) //for large angles
     angle -= 180; //convert to angle from vertical (shorthand subtraction notation)
     
	theta = -angle*PI/180; //convert to theta for trig 
	getBoundingRect(xbase, ybase, width, height); //location and size of the bounding rectangle for the shell
	xcenter=xbase+width/2; ycenter=ybase+height/2; //identify the centre of the bounding rectangle for the shell
	getSelectionCoordinates(x, y); //retrive coordinates of the start of the particle

	//maths, calculate the new position of each shell
	for (i=0; i<x.length; i++) { 
      dx=x[i]-xcenter; dy=ycenter-y[i];
      r = sqrt(dx*dx+dy*dy);
      a = atan2(dy, dx);
      x[i] = xcenter + r*cos(a+theta);
      y[i] = ycenter - r*sin(a+theta);
	}

	
   makeSelection(selectionType, x, y); 
	setForegroundColor(0,0,0); //set foreground colour to black
	run("Fill", "slice"); //paste rotated shell mask into rotated window

} 

////create rotated mask windows for further use
selectWindow("Rotated"); //select window with rotated masks
run("Select None"); //ensure nothing is selected
run("Duplicate...", "title=RotatedCopy"); //duplicate and rename
selectWindow("Rotated"); //select window with rotated masks
run("Duplicate...", "title=Valve"); //duplicate and rename

////place rotated drillholes onto rotated shell masks

selectWindow("Results"); //select results
IJ.renameResults("PrelimResults"); //rename results as preliminary to preserve
run("Select None"); //ensure nothing is selected

//if there are drillholes
if (n > 0){
	selectWindow("Drillholes"); //select the drillhole data window
	IJ.renameResults("Results"); //rename as results for interaction
	
	//for every new drillhole
	for (k=drill;k<total_drill; k++){ 
	
		x = getResult("XStart", k); //x coordinate of the start of the particle (from analyzer)
		y = getResult("YStart", k); //y coordinate of the start of the particle (from analyzer)
	
		selectWindow("Rotated"); //select the rotated shells window containing rotated shell masks
		doWand(x,y); //wand tool at coordinates of particle
	
		angle = ang[k-drill]; //what is this?
		
		if (angle>90)
	     angle -= 180; //convert to angle from vertical (shorthand subtraction notation)
	     
		theta = -angle*PI/180; //convert to theta for trig 
		getBoundingRect(xbase, ybase, width, height); //get bounding rectangle for the selection
		xcenter=xbase+width/2; ycenter=ybase+height/2; //calculate the centre of the bounding rectangle
		
		selectWindow("Drill2"); //select window with drillholes only
			doWand(x,y); //wand tool at coordinates for the start of the particle
			
		selectWindow("Rotated"); //select the rotated window containing rotated shell masks 
			run("Restore Selection"); //restore wand selection from Drill2, drillholes only
				
		getSelectionCoordinates(x, y); //retrive the coordinates of the selection

		//maths, caluclate the new position of the drillhole
	 	for (i=0; i<x.length; i++) {
			dx=x[i]-xcenter; dy=ycenter-y[i];
			r = sqrt(dx*dx+dy*dy);
			a = atan2(dy, dx);
			x[i] = xcenter + r*cos(a+theta);
			y[i] = ycenter - r*sin(a+theta);
		}

		
		makeSelection(selectionType, x, y);
			setForegroundColor(255,255,255); //set foreground colour to white
			run("Fill", "slice"); //paste rotated drillholes onto shells
			run("Select None"); //ensure nothing is selected
	} 
}

close("Rotated");
setBatchMode("exit and display"); //exit batch mode and display hidden windows