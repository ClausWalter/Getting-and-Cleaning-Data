tidyData<-function(){
  ## OK, first some prep work (loading libraries, setting paths etc.)
  print("Prep work")
  
  library(reshape2)
  library(data.table)
  path<-getwd()
  pathIn <- file.path(path, "UCI HAR Dataset")
  
  ## Just needed for unit testing until the full script works as it should:
  ## Please note that I am using Windows, so I could test with this only. 
  ##  Should you be Apple user, it might not work. Apologies in case that happens. 
  ## Load the file and unzip. Since it is a large file, check first if it already exists (name check only). 
  ## Simplifying assumption: working directory in combination with file name is used
  ## for this assignment only, so only file name is checked, but not e.g. file size for being sure 
  ## the target file is identical to the one being loaded.
  ## As you can see, I use the R-internal unzip function. Assumption here: unzip into the the 
  ## directory the zip-file got loaded into is all right. Here, I was a little lazy - setting any other path
  ## would certainly be easily achieveable. I also don't check if it has already been unzipped
  ## in a previous try, just in case the old version may be incomplete or altered. So why not have 
  ## a fresh try with the original data... ;-)
  
  print("Data loading and unzipping")
  url <-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  filename<- "Dataset.zip"
  filenameNpath<-file.path(path, filename)
  if (!file.exists(path)) {dir.create(path)}
  if (!file.exists(filenameNpath)){download.file(url, destfile = filenameNpath, mode = "wb")}
  unzip(file.path(path, filename), files = NULL, list = FALSE, overwrite = TRUE, junkpaths = FALSE, exdir = ".", unzip = "internal", setTimes = FALSE)
  
  ## After the above, the data should be unzipped with the original folder structure 
  ## in the working directory.
  ## Next step is reading the relevant data (took me a while to find out which files to read etc.).
  ## To not be forced to work with the long paths of the unzipped original data, I set the 
  ## path accordingly in varialbe «pathUnzippedData».
  ## The data to be read are the subject and activity files, divided into training and test. Data is then
  ## transferred into tables, tables are merged using the merge() function, and useful column
  ## names are given using the setnames() function:
  
  print("Internal data preparation start")
  dataSubjectTrain <- fread(file.path(pathIn, "train", "subject_train.txt"))
  dataSubjectTest  <- fread(file.path(pathIn, "test" , "subject_test.txt" ))
  dataActivityTrain <- fread(file.path(pathIn, "train", "Y_train.txt"))
  dataActivityTest  <- fread(file.path(pathIn, "test" , "Y_test.txt" ))
  dataTrain <- fread(file.path(pathIn, "train", "X_train.txt"))
  dataTest <- fread(file.path(pathIn, "test" , "X_test.txt" ))
  
  ## Now the merging:
  print("Now the merging ")
  
  dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
  setnames(dataSubject, "V1", "subject")
  dataActivity <- rbind(dataActivityTrain, dataActivityTest)
  setnames(dataActivity, "V1", "activityNum")
  data <- rbind(dataTrain, dataTest)
  data<-cbind(dataSubject, dataActivity, data)
  setkey(data, subject, activityNum)
  
  ## Getting rid of data not needed:
  print("Getting rid of data not needed")
  
  dataFeatures <- fread(file.path(pathIn, "features.txt"))
  setnames(dataFeatures, names(dataFeatures), c("featureNum", "featureName"))
  dataFeatures <- dataFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]
  
  ## Convert the column numbers to a vector of variable names matching columns in DataCombined.
  print("Convert the column numbers to a vector of variable names matching columns in DataCombined ")
  
  dataFeatures$featureCode <- dataFeatures[, paste0("V", featureNum)]
  head(dataFeatures)
  dataFeatures$featureCode
  select <- c(key(data), dataFeatures$featureCode)
  data <- data[, select, with=FALSE]
  
  ## Writing the tidied and cleansed data:
  
  write.table(data, file = "~/CleansedandTidiedData.txt", append = FALSE, quote = TRUE, sep = "\t", eol = "\n", na = "NA", dec = ".", row.names = TRUE, col.names = TRUE, qmethod = c("escape", "double"), fileEncoding = "")
  
  ## Now enriching the activity names:
  print("Now enriching the activity names")
  
  dataActivityNames <- fread(file.path(pathIn, "activity_labels.txt"))
  print(head(data))
  setnames(dataActivityNames, names(dataActivityNames), c("activityNum", "activityName"))
  data <- merge(data, dataActivityNames, by="activityNum", all.x=TRUE)
  setkey(data, subject, activityNum, activityName)
  data <- data.table(melt(data, key(data), variable.name="featureCode"))
  data <- merge(data, dataFeatures[, list(featureNum, featureCode, featureName)], by="featureCode", all.x=TRUE)
  data$activity <- factor(data$activityName)
  data$feature <- factor(data$featureName)

  ## A little helper-function to shorten the remaining code:
  grepspecial <- function (repli) { grepl(repli, data$feature) }
  ## Features with 2 categories
  n <- 2
  y <- matrix(seq(1, n), nrow=n)
  x <- matrix(c(grepspecial("^t"), grepspecial("^f")), ncol=nrow(y))
  data$featDomain <- factor(x %*% y, labels=c("Time", "Freq"))
  x <- matrix(c(grepspecial("Acc"), grepspecial("Gyro")), ncol=nrow(y))
  data$featInstrument <- factor(x %*% y, labels=c("Accelerometer", "Gyroscope"))
  x <- matrix(c(grepspecial("BodyAcc"), grepspecial("GravityAcc")), ncol=nrow(y))
  data$featAcceleration <- factor(x %*% y, labels=c(NA, "Body", "Gravity"))
  x <- matrix(c(grepspecial("mean()"), grepspecial("std()")), ncol=nrow(y))
  data$featVariable <- factor(x %*% y, labels=c("Mean", "SD"))
  ## Features with 1 category
  data$featJerk <- factor(grepspecial("Jerk"), labels=c(NA, "Jerk"))
  data$featMagnitude <- factor(grepspecial("Mag"), labels=c(NA, "Magnitude"))
  ## Features with 3 categories
  n <- 3
  y <- matrix(seq(1, n), nrow=n)
  x <- matrix(c(grepspecial("-X"), grepspecial("-Y"), grepspecial("-Z")), ncol=nrow(y))
  data$featAxis <- factor(x %*% y, labels=c(NA, "X", "Y", "Z"))
  r1 <- nrow(data[, .N, by=c("feature")])
  r2 <- nrow(data[, .N, by=c("featDomain", "featAcceleration", "featInstrument", "featJerk", "featMagnitude", "featVariable", "featAxis")])
  r1 == r2
  setkey(data, subject, activity, featDomain, featAcceleration, featInstrument, featJerk, featMagnitude, featVariable, featAxis)
  dataTidy <- data[, list(count = .N, average = mean(value)), by=key(data)]
  
  ## And now the final output. Lots of console output here, so no need to add another one for this last step.
  
  print(head(dataTidy, 10))
  print(tail(dataTidy, 10))
  print(dim(dataTidy))
  print(summary(dataTidy))
  write.table(dataTidy, file = "~/TidyData.txt", append = FALSE, quote = TRUE, sep = "\t", eol = "\n", na = "NA", dec = ".", row.names = TRUE, col.names = TRUE, qmethod = c("escape", "double"), fileEncoding = "")
}
