# Conodont-Measuring

Adapted version of FossilJ for measuring coniform conodonts using basic lines between landmarks
Creates verification images of measurements, with specimen number allocation
CSV files containing measurements with specimen and measurement references

Install FIJI distribution of ImageJ
Download and place ijm file in a convinient location.

- Requires blue scalebars (rgb : 0,0,255)
- Units can be um or mm, all are converted to mm
- Results are better if the screen is bigger
- Image windows can be maximised for interaction
- Process up to 15 images in one go, but no more as if something goes wrong the data is comprimised and you have to start over

1. Create input directory for images to be batch processed. 
2. Create output directory to store output verification images and data
3. Open FIJI
4. Plugins --> Macros --> Run --> Select the downloaded ijm file
5. The plugin will start, follow the provided instructions.

Things to note

5a. to calibrate the scale click once on both ends

5b. drawing lines
- click and hold to draw line
- just release and draw again to correct/make new
- specimen order on the page doesn't matter, but do the lines on each specimen in the same order (this will make data processing easier)
               
6. Next image will open, repeat process
7. After all images are processed, results will be saved in the output folder

7a. In the csv file 
- each measurement is given a line number
- each specimen is given a number
- line length is called "length", 3rd to last column

7b. In measurement images
- each line measured is drawn in red
- line number is printed in green on the line
- specimen number is printed in the upper left hand corner

8. Move data into a folder denoting the first run, with original and measured images alongside the data
9. Place the new set of images into the input folder, check output folder is empty
10. Repeat from step 4 until all images are processed
