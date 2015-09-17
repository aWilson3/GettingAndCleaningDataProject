library(dplyr)

##read in data and merge training and testing sets
train <- read.table("train/X_train.txt")
train_labels <- read.table("train/y_train.txt")
test <- read.table("test/X_test.txt")
test_labels <- read.table("test/y_test.txt")
all <- rbind(train, test)
all_labels <- rbind(train_labels, test_labels)


##read feature names in as a data frame. Then filter the merged data frame to include
##only the features including the mean and standard deviation for each measurement
features <- read.table("features.txt", sep = " ", stringsAsFactors = FALSE, col.names = c("number", "name"))
index_vec1 <- grep("mean[^a-zA-Z]", features$name)
index_vec2 <- grep("std[^a-zA-Z]", features$name)
index_vec <- sort(c(index_vec1, index_vec2))
all = all[,index_vec]

##create a new dataframe that includes a description of the activity, as well as labeled features
all_labels <- rename(all_labels, activity = V1)
all_labels$activity <- factor(all_labels$activity,
                             labels = c("WALKING", "WALKING_UPSTAIRS", "WALKING-DOWNSTAIRS", "SITTING", "STANDING", "LAYING"))
tidy_df <- cbind(all_labels, all)
colnames(tidy_df) <- c("activity", features$name[index_vec])

##create separate data frame giving the average of each variable, grouped by activity and subject
subject_train <- read.table("train/subject_train.txt")
subject_test <- read.table("test/subject_test.txt")
subjects <- rbind(subject_train, subject_test)

colnames(subjects) = c("subject")
new_df <- cbind(subjects, tidy_df)
new_df <- aggregate(new_df[,3:68], by = list(new_df$subject, new_df$activity), FUN = mean)
new_df <- rename(new_df, subject = Group.1, activity = Group.2)

##write output to text file
new_df <- apply(new_df, 2, format)
write.table(new_df, file = "tidyDataSet.txt", quote = FALSE, row.names = FALSE)

  
