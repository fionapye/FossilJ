//Draw bounding box
//Updated 22 May 2018
//commented 24/06/2019

setFont("SansSerif", 50, "bold"); //set font style, size (px) and emphasis

for (k=0; k<nResults; k++) { //for each object

	//retrive bounding box coordinates
	x1 = getResult("BX", k); 
	x2 = x1 + getResult("Width", k);
	y1 = getResult("BY", k);
	y2 = y1 + getResult("Height", k);

	setForegroundColor(0,0,0); //set foreground colour to black
	setLineWidth(4); //set line width (px)

	toUnscaled(x1, y1); //convert to unscaled pixel coordinates
	toUnscaled (x2, y2); //convert to unscaled pixel coordinates

	//draw lines to construct bounding box using coordinates
	drawLine(x1, y1, x2, y1); //draw top line
	drawLine(x1, y1, x1, y2); //draw left line
	drawLine(x2, y1, x2, y2); //draw right line
	drawLine(x1, y2, x2, y2); //draw bottom line

	drawString(k+1, x1-5, y1); //print specimen number in the top left of the bounding box
}