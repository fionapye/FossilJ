# FossilJ is a plugin for fossil data acquisition by image analysis, using ImageJ.

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3336200.svg)](https://doi.org/10.5281/zenodo.3336200)

The plugin provides free, open source tools for semi-automated measurements of fossils, with this first version optimised for bivalve shells with or without predatory drillholes. 

FossilJ v0.2.1 was built in the FIJI distribution of ImageJ v1.52n.<br> 
FIJI is available to download and explore here: https://fiji.sc/ <br><br>
ImageJ is an open source Java image processing program designed by the National Institute for Health (NIH). <br>
FIJI is Just ImageJ, which comes with many scientific image analysis plugins included and is built on ImageJ2. <br>
For more information about ImageJ, including the macro language, visit https://imagej.nih.gov/ij/index.html and https://imagej.net/ImageJ

Cite as: Fiona Pye, & Nussaibah Raja-Schoob. (2019, July 15). FossilJ (Version v0.2.1). Zenodo. http://doi.org/10.5281/zenodo.3336200 <br>
Alongside the ImageJ software you used (see https://imagej.net/Citing).

FossilJ is licensed under a [AGPLv3 License](https://tldrlegal.com/license/gnu-affero-general-public-license-v3-(agpl-3.0)#summary).

The documentation for the plugin is available below:
----------------------------------------------
<b>FossilJ Summary: </b>
<ul>
  <li>FossilJ semi automatically collects morphometric data from images of bivalves. </li>
  <li>The measurements are collected in mm and are: </li>
  <ul style="list-style-type:disc;">
      <li>width (anterio-posterior) </li>
      <li>height (dorso-ventral) </li>
      <li>broken/complete specimen </li>
      <li>number of drillholes per specimen </li>
      <li>drillhole diameter </li>
      <li>incomplete/complete drillhole </li>
      <li>internal or edge drilling </li>
    </ul>
  <li>Collected measurements are shown in verification images, which can be cross referenced with the data. This data is produced as two CSV files, general specimen data and drillhole data.</li>
  <li>All specimens and drillholes are given numbers which are unique when used in combination with the image name. </li>
</ul>  
<hr>
<b>Inputs: </b>
<ul>
  <li>Input directory containing images with: </li>
  <ul style="list-style-type:disc;">
    <li>A <b> high contrast </b> between object and background (pale object, dark background). </li>
    <li><b>Blue scale bar </b> (rgb (0,0,255)) with units of <b>mm or &micro;m</b> (all converted to mm). </li>
    <li><b>Space</b> between specimens and the edge of the image at ~&frac13; of specimen size </li>
    <li><b>Bivalve</b> shells approximately umbo <b>upwards in the image</b> for chirality determination </li>
  </ul>
  <li>Output directory (empty) </li>
</ul>

<b>Outputs:</b>
<ul>
  <li>CSV data </li>
    <ul style="list-style-type:disc;">
      <li> "shell_measurements.csv" </li>
      <ul style="list-style-type:none;">
      <li>Label - Image name </li> 
      <li>Width - Anterio-posterior </li> 
      <li>Height - Dorso-vental </li> 
      <li>Shell - Specimen number (unique per image) </li> 
      <li>Broken - Broken shell = 1, complete shell = 0 </li>
      <li>Valve - chirality left/right </li>
      </ul>
      <li> "drill_measurements.csv" </li>
      <ul style="list-style-type:none;">
      <li>Label - Image name </li> 
      <li>Name - Drillhole reference </li> 
      <li>Shell - Specimen number (unique per image, same as in "shellmeasurements.csv") </li> 
      <li>Type - Internal or edge drill </li> 
      <li>Feret - Drillhole diameter </li>
      <li>Incomplete - Incomplete drill = 1, complete drill = 0 </li>
      </ul>
  </ul><br>
  <li>Verification Images ("*" indicates where image name is appended) </li>
  Images contain scalebars and specimen numbers
    <ul style="list-style-type:disc;">
      <li>*measurements - displays length and width measurements </li>
      <li>*valve - shows allocated chirality </li>
      <li>*original_edited - copy of original image with a cleaned black background </li>
      <li>*drillholes - specimens with printed drillhole masks </li>
      <li>*drillholes_drawn - original image with the drillholes as drawn by user </li>
  </ul>
</ul>  
<hr>
<b>Setup:</b> <br>
<i>We are currently having issues installing FossilJ as a Plugin, so for now please install it as a Macro (see below). </i> <br> <br>
<ol>
  <li>Install FIJI distribution of ImageJ https://fiji.sc/ </li>
  <li>Download the "FossilJ.ijm" file and the "Macros" folder </li>
  <li>Place the <b>"FossilJ.ijm"</b> file in the <b>"~Fiji.app\plugins"</b> folder </li>
  <li>Place the files from the <b>"Macros"</b> folder in the <b>"~Fiji.app\plugins\Macros"</b> folder </li>
  <li>Open ImageJ using the executable file </li>
 <!--  <li>Install the plugin: Plugins tab &rArr; Install PlugIn &rArr; select the <b>"FossilJ.ijm"</b> file </li> --> 
  <li>Install the plugin: Plugins tab &rArr; Macros &rArr; Install &rArr; select the <b>"FossilJ.ijm"</b> file </li>
  <li>Restart ImageJ <!--as instructed--> to finish installation</li>
</ol>
<hr>
<b>Operation:</b><br>
<br>
  General Guidance <ul>
    <li>User interaction has higher accuracy on larger screens. </li>
    <li>Image windows can be maximised for interaction. </li>
    <li>If contrast between object and background is not suffient, the object may not be detected and will create artefacts in data </li>
    <li><b>Process up to 15 images together</b>, but no more as if an error occurs the data could be comprimised and may need to be redone.</li>
    <li>Clear, machine-readable image naming system is optimal (for further data analysis). </li>
    <li>Checks on inputs and user verification ensures data quality. </li>
    <li>Clicking "Cancel" at any stage will end this section of the Plugin, but will not exit completely. <br>
  This may cause erratic behaviour. If this occurs click "Cancel" on the next option that appears and close all windows. 
  </ul>

Repeat the following sequence on every input folder, until all data is processed:
<ol>
  <li><b>Open FIJI </b></li>
  <!--<li><b>Select FossilJ from the Plugins menu </b></li>-->
  <li><b>Open FossilJ </b><br>
    Plugins &rArr; Macros &rArr; FossilJ
  <li><b>Select the input and output folders </b></li>
  <li><b>Scalebar calibration</b></li>
    Length and units <br>
    Click once on each end of the scalebar then click "OK" <br>
    If the scalebar is correctly selected click "Yes" to continue <br>
    Verification - to restart calibration click "No". This returns to the length and units input step.
  <li><b>Broken Specimens </b></li>
    Type the number of broken specimens into the box and click "OK" <br>
    If no broken specimens are present, leave as 0 and click "OK" to move onto the next step <br>
    If broken specimens are present, click on each broken specimen once, then click "OK" <br>
    Verification - selecting "No" returns to the broken specimen number box, resetting this step. <br>
  <li><b>Drillholes </b></li>
    If no drillholes are present leave the default 0 for both options and click "OK" to move onto the next step. <br>
    If drillholes are present, put the total number in the top box (complete and incomplete), and the number of incomplete in the lower box       and click "OK" <br>
    Verification - selecting "No" returns to the drillhole number box, resetting this step. <br>
    Follow the instructions provided and only interact with the image when prompted. <br>
    The order drillholes are drawn is not important. <br>
    Draw the drillhole outer diameter then click "OK". Repeat until all drillholes are outlined, complete and incomplete. <br> 
    If incomplete drillholes are present, for each incomplete drillhole select the area within the outline once, and click "OK". <br>
    Check the identification of the drillhole as edge or internal drilling, which can be edited using the dropdown provided.
  <li><b>New Scalebars </b></li>
    When prompted, click "OK" to add scalebars to verification images. <br>
    Scalebars appear to the right of the click position, and are 1 mm in length. <br>
    Repeat for all prompted images.
  <li><b>Valve Chirality </b></li>
    Check the chirality identification (left/right) and edit using the dropdown provided if required.
  <li><b>Save </b></li>
    The data and images are saved and closed automatically.
</ol>

