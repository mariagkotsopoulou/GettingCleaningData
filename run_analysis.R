
#### LOAD LIBRARIES ########################################################
library(dplyr)
library(data.table) 


#### 1.MERGE TRAINING & TEST ##############################################

## download the data 
fileUrl<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./UCIHARDataset.zip", method="libcurl")
## extract the zip file 
unzip("./UCIHARDataset.zip", exdir = "./")

## load the training data set
train <- read.table("UCI HAR Dataset/train/X_train.txt")
## load the variable names 
namesfeatures <- read.table("UCI HAR Dataset/features.txt")
## add the variable names to the training data set 
colnames(train) <- as.character(namesfeatures$V2)
## each row of the data set corresponds to measurements of an activity
trainlabels <- read.table("UCI HAR Dataset/train/y_train.txt")
## each row of the data set corresponds to measurements of a person performing activity
subjecttrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
## add to the dataset the person (i.e. subject) and activity variable row ids 
train <- cbind(subjecttrain, trainlabels, train)
colnames(train)[1:2] <- c("Subject","Activity")

## load the test data set
test <- read.table("UCI HAR Dataset/test/X_test.txt")
## add the variable names to the testing data set 
colnames(test) <- as.character(namesfeatures$V2)
## each row of the data set corresponds to measurements of an activity
testlabels <- read.table("UCI HAR Dataset/test/y_test.txt")
## each row of the data set corresponds to measurements of a person peforming activity
subjecttest <- read.table("UCI HAR Dataset/test/subject_test.txt")
## add to the dataset the person (i.e. subject) and activity variable row ids 
test <- cbind(subjecttest, testlabels, test)
colnames(test)[1:2] <- c("Subject","Activity")

## combine training and test dataset
data <- rbind(train, test)

## remove objects not to be used further on
rm(subjecttest, subjecttrain, test, testlabels, train, trainlabels)

#### 2.GET MEAN AND STD FOR EACH MEASUREMENT ######################

## find variable names containing mean and standard deviation
## only interested in the measurement variables 
## and not the variables created a posteriori i.e. Jerk signals, signal magnitude and Fast Fourier Transform (FFT) 
subsetnamesfeatures <- namesfeatures %>%
                        filter(grepl("*-mean()|*-std()", V2) & !grepl("*Jerk*|*Mag*|^f", V2))

## select only the columns with the variables of interest
## add second filter so as to not select the columns containing numbers as we are only interested in the X,Y,Z ones
subsetdatanames <- c("Subject","Activity", as.vector(subsetnamesfeatures$V2))
data <- data[,!grepl('[[:digit:]]', colnames(data))]  %>% select(one_of(subsetdatanames))

## remove objects not to be used further on
rm(subsetdatanames,subsetnamesfeatures, namesfeatures)

#### 3. ADD DESCRIPTIVE ACTIVITY NAMES  ######################################

# load the activity labels (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING)
activitylabels <- read.table("UCI HAR Dataset/activity_labels.txt")

# recode the activity column using the activity labels 
data <- data %>% 
          mutate(Activity = plyr::mapvalues(Activity, as.vector(activitylabels$V1),
                                            as.vector(tolower(activitylabels$V2)))) 

## remove objects not to be used further on
rm(activitylabels)

#### 4.ADD DESCRIPTIVE LABELS VARIABLE NAMES. ##########################################

# tBodyAcc  --> sensor acceleration signal , body motion component
# tGravityAcc  -->   sensor acceleration signal , gravitational component  
# tBodyGyro --> Triaxial Angular velocity from the gyroscope.

# Across all columns, replace all instances of "..." with "..."
names(data) <- gsub("tBodyAcc", "BodyMotionAcceleration", names(data))
names(data) <- gsub("tGravityAcc", "GravitationalAcceleration", names(data))
names(data) <- gsub("tBodyGyro", "GyroscopeVelocity", names(data))


#### 5.CREATE TIDY DATA WITH AVERAGE BY ACTIVITY & SUBJECT. ######################

## transform data from wide to long format by activity and subject
datamelt = melt(setDT(data), id = c("Activity","Subject" ))
## separate the variable by its components 
## Variable: BodyMotionAcceleration or GravitationalAcceleration or GyroscopeVelocity
## Measuremnt: mean or std (standard deviation)
## Triaxial: X, Y or Z 
datamelt[, c("Variable", "Measurement","Triaxial") := tstrsplit(variable, "-", fixed=TRUE)]
## remove the parenthesis string from mean() and std()
datamelt[, Measurement := gsub("()", "", Measurement,fixed="TRUE")]  
## change column types 
cols <- c("Activity","Subject","Measurement","Triaxial" )
datamelt[, (cols) := lapply(.SD, factor), .SDcols=cols]

## create tidy data set of the variable average by activity and subject 
datacast = dcast(datamelt, Activity +Subject  + Measurement + Triaxial  ~ Variable , value.var = "value", fun=mean)

#### SAVE TIDY DATA SET TO BE USED FOR LATER ANALYSIS

write.csv(datacast, "UCIHARTidyData.csv")

