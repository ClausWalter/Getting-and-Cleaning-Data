Getting and Cleaning Data – Programming Assignment
=====================================
Claus Walter


Project Assignment Summary
--------------------------

> The following steps need to be fulfilled to meet the assignment requirements:

> 1. Merges the training and the test sets to create one data set.
> 2. Extracts only the measurements on the mean and standard deviation for each measurement.
> 3. Uses descriptive activity names to name the activities in the data set
> Appropriately labels the data set with descriptive variable names.
> 4. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
> 5. Tidy data set: data set that is the result of running Run_analysis.R
> 
> One of the most exciting areas in all of data science right now is 


Deliverables produced
---------------------
* R script ‘run_analysis.r’;
* README.md (this file);
* Tidy dataset file ‘TidyData.txt’;
* Codebook file ‘codebook.md’.


How the R-script works
----------------------
The R script works as specified in the assignment. Should you open the scritp in e.g. R, R Studio or a simple text editor, you will see that basically, the following steps are performed:
Load and extract data;
> 1. Load and unzip data;
> 2. Prepare and fill internal tables with the relevant data;
> 3. Merging data;
> 4. Eliminating data not needed (till that step, full data was used);
> 5. Changing column and acitivty names to something descriptive;
> 6. Preparing the output data;
> 7. Create the output file ‘TidyData.txt’.


Please note the following: if you run the script as-is, your working directory will be used for the file operations. Can be changed if you e.g. change the working directory directly in the script. While the script runs, it produces console outputs per processing block. I entered that because I don’t like programs that run for a longer time without any feedback. Same applies to the final step, where I have the head and tail of the data produced displayed on the console. That allows me not to open the file for a check, but to have a sense-check directly on the console. I also didn’t see why I should have this as a separate script, to I put all this into one larger script. I think it does it perfectly all right, so why complicate things ;o)
