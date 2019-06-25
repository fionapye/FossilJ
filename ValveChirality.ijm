//commented 24/06/2019

selectWindow("Valve"); //select the rotated shell mask window named valve

run("Analyze Particles...", "size=0.25-Infinity show=Nothing exclude clear include record"); //analyze particles to gather data
n = nResults; //#shells to be tested

valve = newArray(n); //new array to store valve data

for (i=0; i<nResults; i++) { //for every shell
        x = getResult('XStart', i); //retrive the x coord of the object start

		//retrive bounding box coordinates
     	x1 = getResult("BX",i);
		x2 = x1 + getResult("Width", i);
		y1 = getResult("BY", i);
		y2 = y1 + getResult("Height", i);

		toUnscaled(x1,y1); //convert coords to unscaled pixel values
		toUnscaled (x2, y2); //convert coords to unscaled pixel values

		setForegroundColor(255,255,255); //set foreground colour to white
		setLineWidth(2); //set line width (px)
		drawLine(x,y1,x,y2); //draw line using coords

		setForegroundColor(0,0,0); //set foreground colour to black
		setLineWidth(2); //set line width (px)
		drawLine(x1,y1,x2,y1); //draw line using coords
		setFont("SansSerif", 50, "bold"); //set font style, size (px) and emphasis
		drawString(i+1, x1-5, y1); //print specimen numbers
		
		l1 = x - x1; //left part
		l2 = x2 - x; //right part

		//identify which valve based on umbo position
		if (l1 > l2) {
			valve[i] = "Right";
		}
		
		if (l1 < l2) {
			valve[i] = "Left";
		}
}

close("Results"); //close results window

selectWindow("shellmeasurements"); //select shell measurements window
IJ.renameResults("Results"); //rename as results for interaction

n1 = nResults - n;

for (i=n1; i<nResults; i++) {
	setResult("Valve", i, valve[i-n1]); //set valve chirality in data table
}

choices = newArray("Left", "Right", "NA"); //options for user verification

Dialog.create("Valve Chirality"); //create dialog 
for (j=n1; j<nResults; j++){
Dialog.addChoice("Shell " + getResultString("Shell", j), choices, getResultString("Valve",j)); //display options in dropdown for user corrections
}
Dialog.show(); //display dialog

for (j=n1; j<nResults; j++){
	type = Dialog.getChoice(); //retrive user verified chirality data
	setResult("Valve", j, type); //update results
}

for (k=n1; k<nResults; k++) { //for each shell
	//retrive bounding box characteristic coordinates
	x1 = getResult("BX", k); 
	x2 = x1 + getResult("Width", k);
	y1 = getResult("BY", k);
	y2 = y1 + getResult("Height", k);
	valve = getResultString("Valve", k); //retrive valve chirality

	setForegroundColor(0,0,0); //set foreground colour to black
	setLineWidth(4); //set line width (px)

	toUnscaled(x1,y1); //convert to unscaled pixel coords
	toUnscaled (x2, y2); //convert to unscaled pixel coords

	setFont("SansSerif", 40, "bold"); //set font type, size (px) and emphasis
	
	selectWindow("Valve"); //select the valve window
	drawString(valve, x2-70, y1); //label valve in diagram
}

IJ.renameResults("shellmeasurements"); //rename results for preservation

