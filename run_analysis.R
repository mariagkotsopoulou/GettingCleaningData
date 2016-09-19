
# 2.Extracts only the measurements on the mean and standard deviation for each measurement.
# 3.Uses descriptive activity names to name the activities in the data set
# 4.Appropriately labels the data set with descriptive variable names.
# 5.From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.

#30 volunteers 
# each person performed six activities 
# (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING)

# we captured 3-axial linear acceleration and 3-axial angular velocity 
# accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ  -->tBodyGyro-XYZ
# the acceleration signal was then separated into 
# body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) 

# 1.Merges the training and the test sets to create one data set.

train <- read.table("UCI HAR Dataset/train/X_train.txt")

NamesFeatures <- read.table("UCI HAR Dataset/features.txt")

colnames(train) <- as.character(NamesFeatures$V2)

trainlabels <- read.table("UCI HAR Dataset/train/y_train.txt")

subjecttrain <- read.table("UCI HAR Dataset/train/subject_train.txt")

train <- cbind(subjecttrain, trainlabels, train)

colnames(train)[1:2] <- c("subject","activity")

head(train[,1:5])
