/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

// See also Process_Folder.py for a version of this code
// in the Python scripting language.

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	//print("Processing: " + input + File.separator + file);
	//print("Saving to: " + output);
	

	//// this macro caluclates live and dead cells 
	////and % of live cells from live/dead assay using single RGB image.
	
	//Set measuraments
	run("Set Measurements...", "area shape redirect=None decimal=3");
	

	//open the file
	open (input + File.separator + file);
	file = getTitle();
	close("\\Others");
	

	//close non RGB files
	
	if (bitDepth() != 24) {
	close();
}	
	else {
	
	
	//set initial number of live and dead cells to 0
	liveno=0;
	deadno=0;

	originalTitle = getTitle(); 
	run("Split Channels");
	selectWindow(originalTitle + " (blue)");
	run("Close"); 
	
	////red channel////
	selectWindow(originalTitle + " (red)");  
	run("8-bit");
	
	//Adjust brightness and contrast
	run("Enhance Contrast", "saturated=0.35");
	
	//Reduce the noise
	run("Smooth");
	
	//Clear background
	run("Subtract Background...", "rolling=25");
	
	//Set threshould
	setAutoThreshold("IsoData dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	
	//Remove single pixels
	run("Erode");
	run("Dilate");
	
	//Separete touching cells
	run("Watershed");
	
	//Count particles
	run("Analyze Particles...", "size=0.0-Infinity circularity=0.00-1.00 show=Nothing include add in_situ");
	
	
	deadno=roiManager("count");
	if (deadno>0) {
	
	roiManager("Show All with labels");
	roiManager("Show All");
	array1 = newArray("0");
	for (i=1;i<roiManager("count");i++){
		array1 = Array.concat(array1,i);
	}
	roiManager("select", array1);
	roiManager("Delete");
	}
	
	////green channel////
	selectWindow(originalTitle + " (green)"); 
	run("8-bit");
	
	//Adjust the brightness and contrast
	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT");
	
	// Reduce the noise
	run("Smooth");
	
	//Clear background
	run("Subtract Background...", "rolling=25");
	
	
	//Set Threshold
	setAutoThreshold("Moments dark");
	run("Convert to Mask");
	run("Erode");
	run("Dilate");
	run("Watershed");
	
	//Count particles
	run("Analyze Particles...", "size=0.001-Infinity circularity=0.00-1.00 show=Nothing include add in_situ");

	
	liveno=roiManager("count");
	if (liveno>0) {
	roiManager("Show All with labels");
	roiManager("Show All");
	array1 = newArray("0");
	for (i=1;i<roiManager("count");i++){
		 array1 = Array.concat(array1,i);
		}
	
	roiManager("select", array1);
	roiManager("Delete");
	}
	
	//prints results
	//print("File: ", file, "; live: ", liveno , "; dead: ", deadno , "; total: ", liveno+deadno, "; 
	print("%live: ", liveno/(liveno+deadno));
}	
}			