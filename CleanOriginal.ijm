//Label Original Photo	
//commented 24/06/2019

setBatchMode("hide"); //hide the active image and start batch mode
selectWindow("Unrotated"); //select the unrotated mask window
run("Create Selection"); //select the shell mask
	
	selectWindow("origCopy"); //select the copy of the original image
	run("Restore Selection"); //restore the selection from the unrotated mask window
	run("Make Inverse"); //select the background
	setForegroundColor(0, 0, 0); //set foreground colour to black
	run("Fill", "slice"); //colour in the background around the shell

	run("Select None"); //ensure nothing is selected
	
	setFont("SansSerif", 50, "bold"); //set font: type, size (px), emphasis

	//print specimen number on image
	for (k=0; k<nResults; k++) {	
		x = getResult("BX", k); //retrieve the bounding box upper left corner x
		y = getResult("BY", k); //retrive the bounding box upper left corner y
		toUnscaled(x,y); //convert xy coords to unscaled pixel values

		setForegroundColor(255,255,255); //set foreground colour to white
		drawString(k+1, x, y); //draw string (number of the shell) 
	}
	
selectWindow("Unrotated"); //select unrotated window
run("Select None"); //ensure nothing is selected
setBatchMode("exit and display"); //exit batch mode and display hidden images


