//commented 23/06/2019

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

