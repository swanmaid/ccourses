library("data.table"); library("reshape2")

path <- setwd("~/")
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fp <- "UCI_HAR_Dataset.zip"
if (!file.exists(path)) {dir.create(path)}
download.file(url,fp, method="curl")
### files <- unzip(fp,list=TRUE)
## read the subject files
dtSubjectTrain <- read.table(unz(description=fp, 
              filename="UCI HAR Dataset/train/subject_train.txt"))
              
dtSubjectTest <- read.table(unz(description=fp, 
              filename="UCI HAR Dataset/test/subject_test.txt"))
              
## read the activity aka label files
dtActivityTrain <- read.table(unz(description=fp, 
              filename="UCI HAR Dataset/train/y_train.txt"))
              
dtActivityTest <- read.table(unz(description=fp, 
              filename="UCI HAR Dataset/test/y_test.txt"))
              
## read the data files
dtTrain <- read.table(unz(description=fp, 
              filename="UCI HAR Dataset/train/X_train.txt"))
dtTest <- read.table(unz(description=fp, 
              filename="UCI HAR Dataset/test/X_test.txt"))
              
## combine the data tables - merge rows
dtSubject <- data.table(rbind(dtSubjectTrain, dtSubjectTest))
setnames(dtSubject, "V1", "subject")
dtActivity <- data.table(rbind(dtActivityTrain, dtActivityTest))
setnames(dtActivity, "V1", "activityNum")
ds <- data.table(rbind(dtTrain, dtTest))
### 1. Merge the training and the test sets to create one data set.
ds <- cbind(dtSubject,dtActivity,ds)

### 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
dtFeatures <- data.table(read.table(unz(description=fp, 
              filename="UCI HAR Dataset/features.txt")))
setnames(dtFeatures,names(dtFeatures),c("featureNum","featureName"))
dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]
dtFeatures$featureCode <- dtFeatures[, paste0("V", featureNum)]

## subset these variables using the variable names
setkey(ds, subject, activityNum)
ds <- ds[,c(key(ds),dtFeatures$featureCode),with=FALSE]

### Uses descriptive activity names to name the activities in the data set
dtActivityName <-  read.table(unz(description=fp, 
              filename="UCI HAR Dataset/activity_labels.txt"))
setnames(dtActivityName, names(dtActivityName), c("activityNum", "activityName"))

ds <- merge(ds, dtActivityName,by="activityNum",all.x=TRUE)

setkey(ds,subject,activityNum,activityName)

ds <- data.table(melt(ds,key(ds),variable.name="featureCode"))
ds <- merge(ds, dtFeatures[, list(featureNum, featureCode, featureName)], 
            by="featureCode", all.x=TRUE)

ds$activity <- factor(ds$activityName)
ds$feature <- factor(ds$featureName)

###4. Appropriately labels the data set with descriptive variable names. 
# function to simply grep through feature labels later
grepi <- function(pattern) {grepl(pattern,ds$feature)}

## Features with 3 levels
y <- matrix(1:3, 3)
x <- matrix(c(grepi("-X"), grepi("-Y"), grepi("-Z")), ncol=nrow(y))
ds$featureAxis <- factor(x %*% y, labels=c(NA, "X", "Y", "Z"))

## features with 1 level
ds$featureJerk <- factor(grepi("Jerk"), labels=c(NA,"Jerk"))
ds$featureMagnitude <- factor(grepi("Mag"), labels=c(NA,"Magnitude"))

## features with 2 levels
y <- matrix(1:2, 2)

x <- matrix(c(grepi("^t"), grepi("^f")), ncol=nrow(y))
ds$featureDomain <- factor(x %*% y, labels=c("Time", "Frequency"))

x <- matrix(c(grepi("mean()"), grepi("std()")), ncol=nrow(y))
ds$featureMeasure <- factor(x %*% y, labels=c("Mean", "SD"))

x <- matrix(c(grepi("Acc"), grepi("Gyro")), ncol=nrow(y))
ds$featureInstrument <- factor(x %*% y, labels=c("Accelerometer", "Gyroscope"))

x <- matrix(c(grepi("BodyAcc"), grepi("GravityAcc")), ncol=nrow(y))
ds$featureAcceleration <- factor(x %*% y, labels=c(NA, "Body", "Gravity"))

setkey(ds, subject, activity, featureDomain, featureAcceleration, featureInstrument, 
        featureJerk, featureMagnitude, featureMeasure, featureAxis)

### From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidyset <- ds[, list(count = .N, average = mean(value)), by=key(ds)]

fp <- file.path(path, "HumanActivityRecognitionUsingSmartphonesDataset.txt")
write.table(tidyset, fp, quote=FALSE, sep="\t", row.names=FALSE)





