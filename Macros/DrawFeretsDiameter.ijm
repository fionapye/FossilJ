//Draw Ferets Diameter
//adapted from demo:
//https://imagej.nih.gov/ij/macros/FeretsDiameter.txt
//Updated 22 May 2018
//commented 24/06/2019

////set up functions
function drawAllFeretsDiameters() { //function to draw multiple ferets diameters
    for (i=0; i<nResults; i++) { //for every object
        x = getResult('XStart', i); //retrive object starting x
        y = getResult('YStart', i); //retrive object starting y
        doWand(x,y); //apply wand tool at object starting coords
        drawFeretsDiameter(); //apply function which draws one ferets diameter
        if (i%5==0) showProgress(i/nResults); //show progress in bar in ImageJ toolbar
   }
    run("Select None"); //ensure nothing is selected
}

function drawFeretsDiameter() { //funtion to draw one feret diameter
     requires("1.29n"); //if the ImageJ version is less than specified, macro is aborted
     run("Line Width...", "line=1"); //
     diameter = 0.0; //set diameter as 0.0
     getSelectionCoordinates(xCoordinates, yCoordinates); //returns arrays of x and y coordinates of the selection from wand tool
 //figure out how to get the xy of both ends of line
     n = xCoordinates.length; //set n as the number of x coordinates in the array
     for (i=0; i<n; i++) { // for every x coordinate in the array
        for (j=i; j<n; j++) {
            dx = xCoordinates[i] - xCoordinates[j]; //distance between x coords
            dy = yCoordinates[i] - yCoordinates[j]; //distance between y coords
            d = sqrt(dx*dx + dy*dy); //pythagoras to work out hypotenuse (diameter)
            if (d>diameter) { //if the size of d is greater than the diameter
                diameter = d; //save the new diameter
	    		i1 = i; //save the corresponding number of the coordinate in the array
                i2 = j; //save the corresponding number of the coordinate in the array
            }
        }
    }
    setForegroundColor(255,255,255); //set foreground colour to white
    setLineWidth(5); //set line width (px)
    drawLine(xCoordinates[i1], yCoordinates[i1],xCoordinates[i2],yCoordinates[i2]); //draw line, feret diamter, using calculated coords
}

////execute drawing of diameter
setBatchMode(true); //set batch mode to hide background objects
run("Set Measurements...", "area centroid bounding feret's display redirect=None decimal=3"); //set up measurements to ensure is correct
run("Analyze Particles...", "size=0.25-Infinity show=Nothing exclude clear include record"); //take measurements
drawAllFeretsDiameters(); //apply function
setBatchMode(false); //close batch mode and display hidden objects