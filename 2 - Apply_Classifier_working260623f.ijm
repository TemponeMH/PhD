
//This macro applies a WEKA segmentation classifier to your images
//Choose your treatment group folder OR Choose the folder containing your duplicates folders
//It will create a new folder named "classified + original folder name"
//and the classified images will be saved as tif
//
//If you are going to use the same classifier in another folder, 
//remember to deactivated the classifier loading by adding "//" before it on line 39
//since it is the most time consuming 

print("\\Clear");

//Ask for input

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Classifier model", style = "file") model
#@ String (label = "File suffix", value = ".tif") suffix
#@ String (label = "Choose channel (based on file name)", value ="c0") chan
classified = "classified ";

//Run script

openPlugin();
processFolder(input);



/// function to open plugin

function openPlugin() {
	if ((isOpen("Trainable Weka Segmentation v3.3.2")) == false) {
	open("C:/Users/mathe/OneDrive/Área de Trabalho/Teste WEKA 270523/Treino Green/Output PeB/P1C7F -0290-Image Export-81_c1-2.tif (green).jpg");
	run("Trainable Weka Segmentation");
// wait for the plugin to load		
	wait(5000);
//select colors
	call("trainableSegmentation.Weka_Segmentation.changeClassColor", "0", "#ffffff");
	call("trainableSegmentation.Weka_Segmentation.changeClassColor", "1", "#000000");
	}

//Load model (deactivate if it is already loaded)
//(reactivate if you need to change the classifier)
	call("trainableSegmentation.Weka_Segmentation.loadClassifier", model);

}


/// Function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			outputname = input + File.separator + "classified " + list[i];
			outputpath = outputname + File.separator;
		if(indexOf(list[i], classified) < 0)
			File.makeDirectory(outputpath);
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
		if(indexOf(list[i], chan) >= 0)
			processFile(input, outputpath, list[i]);
	}
}

/// Function to apply classifier in all files in a folder

function processFile(input, outputpath, file) {
// Do the processing here by adding your own code.
// Leave the print statements until things work, then remove them.
	//print("Processing: " + input + File.separator + file);
	//print("Saving to: " + output);
		
//Aply model on images

call("trainableSegmentation.Weka_Segmentation.applyClassifier", input, file, "showResults=false", "storeResults=true", "probabilityMaps=false", outputpath);

}	

//End script

print("Done");
beep();