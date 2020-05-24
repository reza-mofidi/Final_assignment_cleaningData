library(dplyr)

## Download the database and unzip the files

if(!file.exists("~/data")){dir.create("~/data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="~/data/finalAssignment.zip")

if(!file.exists("UCI HAR Dataset")){
  unzip("~/data/finalAssignment.zip", exdir="~/data")
}
setwd("~/data/UCI HAR Dataset")

##assigning dataframes to each file in the dataset

features<- read.table("~/data/UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activities<- read.table("~/data/UCI HAR Dataset/activity_labels.txt", col.names = c("code","activity"))
subject_test<- read.table("~/data/UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test<- read.table ("~/data/UCI HAR Dataset/test/x_test.txt", col.names=features$functions)
y_test<- read.table ("~/data/UCI HAR Dataset/test/y_test.txt", col.names="code")
subject_train<- read.table ("~/data/UCI HAR Dataset/train/subject_train.txt", col.name="subject")
x_train<- read.table ("~/data/UCI HAR Dataset/train/x_train.txt", col.names=features$functions)
y_train<- read.table ("~/data/UCI HAR Dataset/train/y_train.txt", col.names="code")

## First  goal Merge the training and test datasets
x_complete<- rbind(x_train,x_test)
y_complete<- rbind(y_train, y_test)
subjects <- rbind(subject_train, subject_test)
combined_data<- cbind(subjects, x_complete, y_complete)

##Secound goal: Extract only means and standard deviations from each measurment to create a tidydataset
tidy_dataset<- combined_data %>% select(subject, code, contains("Mean"), contains("std"))

## Use descriptive activity names to name activities within the dataset

tidy_dataset$code<- activities[tidy_dataset$code,2]
## correct descriptive labeling of each variable

names(tidy_dataset)[2]<- "activity"
names(tidy_dataset)<-gsub("Acc", "Accelerometer", names(tidy_dataset))
names(tidy_dataset)<-ghub("Gyro", "Gyroscope", names(tidy_dataset))
names(tidy_dataset)<-gsub("BodyBody", "Body", names(tidy_dataset))
names(tidy_dataset)<-gsub("Mag", "Magnitude", names(tidy_dataset))
names(tidy_dataset)<-gsub("^t", "Time", names(tidy_dataset))
names(tidy_dataset)<-gsub("^f", "Frequency", names(tidy_dataset))
names(tidy_dataset)<-gsub("tBody", "TimeBody", names(tidy_dataset))
names(tidy_dataset)<-gsub("-mean()", "Mean", ignore.case=TRUE)
names(tidy_dataset)<-gsub("-std()", "STD", ignore.case=TRUE)
names(tidy_dataset)<-gsub("-freq()", "Frequency", ignore.case=TRUE)
names(tidy_dataset)<-gsub("angle", "Angle", names(tidy_dataset))
names(tidy_dataset)<-gsub("gravity", "Gravity", names(tidy_dataset))

##Create a new dataset with average values for each variable, activity and each subject

step5 <- tidy_dataset %>% 
  group_by(subjects, activity) %>%
  summarise_all(funs(mean))
write.table(step5, "FinalData.text", row.names =F)
