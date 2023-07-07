
//This script quantifies the number of live and dead cells after segmentation
//It will create a image of the segmentation analysis 
//and save the ROIs of live (green) and dead (red) cells
//The quantification results will be saved as a csv file
//Choose the folder containing the segmented images



print("\\Clear");

dir1 = getDirectory("Source");
Headings = newArray ("File", "Live", "Dead", "Total", "Porcentagem");
print(dir1);
Array.print(Headings);


list = getFileList(dir1);
Array.sort(list);
setBatchMode(true);

// Create the arrays first
green = newArray(0);
red = newArray(0);

// Get the green and red channel names
//Attention for the file name, look for the prefix and suffix
for (i = 0; i < list.length; i++) {
   file = list[i];
   if (startsWith(file, "#41")) {
      if (endsWith(file, "Ch0.tif")) {
         green = Array.concat(green, file); 
      } else if (endsWith(file, "Ch1.tif")) { 
         red = Array.concat(red, file); 
      }
   } 
}

// A safeguard. If one channel image is missing, we would fail somewhere
if (green.length != red.length) {
   exit("Unequal number of blue and gray channels found");
}

// Loop over the images

for (i = 0; i < green.length; i++) {
	
	roiManager("reset")
   greenChannel = green[i];
   redChannel = red[i];
   open(dir1+greenChannel);
   enhance(getImageID());
   selectImage(greenChannel);
   run("Analyze Particles...", "size=0.0000-Infinity circularity=0.0-1.00 show=Masks include add in_situ");
   liveno=roiManager("count");
   livenoarray = newArray(liveno);
   
  	for (n=0; n<livenoarray.length; n++) {
      livenoarray[n] = n;
  }
	roiManager("select", livenoarray);
	roiManager("Set Color", "green");
	
   open(dir1+redChannel);
   enhance(getImageID());
   selectImage(redChannel);
   run("Analyze Particles...", "size=0.0000-Infinity circularity=0.0-1.00 show=Masks include add in_situ");
   totalno=roiManager("count");
    totalnoarray = newArray(totalno);
  		for (m=0; m<totalnoarray.length; m++) {
      totalnoarray[m] = m;
  }
  	deadnoarray = ArrayDiff(totalnoarray, livenoarray);
	roiManager("select", deadnoarray);
	roiManager("Set Color", "red");
   deadno = totalno-liveno;
   Porcentagem = 100*(liveno/totalno);
   PorcentagemF = d2s(Porcentagem, 0);
  
  
   // Using the "&" string expansion option within command arguments
   run("Merge Channels...", "c1=&redChannel c2=&greenChannel create");
   fileName = substring(greenChannel, 0, lastIndexOf(greenChannel, "Ch0.tif"))+"_Composite";
   saveAs("Jpeg", dir1 + fileName);
   print(fileName + "," + liveno + "," + deadno + "," + totalno + "," + PorcentagemF);
   roiManager("Save", dir1 + fileName + ".zip");
   close();
    
}

// F U N C T I O N S .....................................................

// All common image processing tasks in here
function enhance(imageID) {
   selectImage(imageID);
  
 	run("8-bit");
	run("Erode");
	run("Dilate");
	run("Watershed");
}

//Array functions
//Array Union

function ArrayUnion(array1, array2) {
	unionA = newArray();
	for (i=0; i<array1.length; i++) {
		for (j=0; j<array2.length; j++) {
			if (array1[i] == array2[j]){
				unionA = Array.concat(unionA, array1[i]);
			}
		}
	}
	return unionA;
}
// Array Difference

function ArrayDiff(array1, array2) {
	diffA	= newArray();
	unionA 	= newArray();	
	for (i=0; i<array1.length; i++) {
		for (j=0; j<array2.length; j++) {
			if (array1[i] == array2[j]){
				unionA = Array.concat(unionA, array1[i]);
			}
		}
	}
	c = 0;
	for (i=0; i<array1.length; i++) {
		for (j=0; j<unionA.length; j++) {
			if (array1[i] == unionA[j]){
				c++;
			}
		}
		if (c == 0) {
			diffA = Array.concat(diffA, array1[i]);
		}
		c = 0;
	}
	for (i=0; i<array2.length; i++) {
		for (j=0; j<unionA.length; j++) {
			if (array2[i] == unionA[j]){
				c++;
			}
		}
		if (c == 0) {
			diffA = Array.concat(diffA, array2[i]);
		}
		c = 0;
	}	
	return diffA;
}

//Save table results

ResultsLD = getInfo("log");
ResultsFile = File.getName(dir1);
File.saveString(ResultsLD, dir1 + File.separator + ResultsFile + ".csv");
setBatchMode(false);
print("Done");
beep();