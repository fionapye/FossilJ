//commented 24/06/2019
//adapted from demo:
//https://imagej.nih.gov/ij/macros/GetCursorLocDemo.txt
//full commenting to be added at later date

////get cursor location 

showMessage("Please click to place scale bar"); //display instruction message for user

shift=1;
ctrl=2; 
rightButton=4;
alt=8;
leftButton=16;
insideROI = 32; // requires 1.42i or later

x2=-1; y2=-1; z2=-1; flags2=-1;
logOpened = false;

j=0;
x_val = newArray(2);
y_val = newArray(2);

while (j<1){
	getCursorLoc(x, y, z, flags);
    if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
              
              if (flags&leftButton!=0) {
				x_val = x;
				y_val = y;
		
				j = j+1;
				
				}
             
              	//logOpened = true;
              	startTime = getTime();
          }
          
          x2=x; y2=y; z2=z; flags2=flags;
          wait(10);
      }

x = x_val; //x coordinate for scalebar
y = y_val; //y coordinate for scalebar

makePoint(x,y); //creates point selection at coordinates

