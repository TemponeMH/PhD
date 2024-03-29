//This macro converts multichannel ZVI files (BioImages)
//into single channel tif images
//The set up is made for green and red channels
//You can select the experiment folder and it will work



setBatchMode(true);

/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

// See also Process_Folder.py for a version of this code
// in the Python scripting language.



processFolder(input);

print("Done!");
beep();

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
	
	
	
		//open the file
	open (input + File.separator + file);

	
	////red channel////
	selectWindow(File.separator + file + "  Ch1");  
	red = getTitle();
	run("8-bit");
	saveAs("Tiff", input + File.separator + red);
	run("Close");
	
	////green channel////
	selectWindow(File.separator+ file + "  Ch0"); 
	green = getTitle();
	run("8-bit");
	saveAs("Tiff", input + File.separator + green);
	run("Close");
	
	// Leave the print statements until things work, then remove them.
	print("Processing: " + input + File.separator + file);
	print("Saving to: " + input);
}
