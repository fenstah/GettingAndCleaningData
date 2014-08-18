GettingAndCleaningData
======================

##Background
The purpose of this project was to demonstrate the ability to collect, work with, and clean a data set. The goal was to prepare a tidy data that can be used for later analysis. That tidy data containes a set with the average of each variable for each activity and each subject that took place in the experiment described below.Submitted as part of this project is a tidy data set as described below, a code book that describes the variables and data, and a README.md (this file) which explains how the script works.  

The data for this project is centered around one of the most exciting areas in all of data science right now - wearable computing.  Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained from http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones.

##The Experiment
The data for this exercise was gathered from experiments that were carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, the 3-axial linear acceleration and 3-axial angular velocity were captured at a constant rate of 50Hz. The experiments were video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers were selected for generating the training data and 30% for the test data. 

### Raw files
    Provided with the data were different, related data files for:
    * features_info.txt': Shows information about the variables used on the feature vector.
    * 'features.txt': List of all features.
    * 'activity_labels.txt': Links the class labels with their activity name.
    * 'train/X_train.txt': Training set.
    * 'train/y_train.txt': Training labels.
    * 'test/X_test.txt': Test set.
    * 'test/y_test.txt': Test labels.
    * 'train/subject_train.txt': Identifies the subject who performed the activity for each sample. Its range is from 1 to 30. 
    
Also included were several raw data files contained within subdirectories names 'Inertial Signals' for both the training and test subject.  These raw data files were not needed for this exercise as the data contained within them can also be found in the the files listed above.  The data use for this experiment can be found at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip.

##Steps to reproduce
The accompanying R script, run_analysis.R, executes several steps to aggregate and filter the data contained in the disparate files listed above into one tidy data set and save that data set as a space delimited file names 'tidydataset.txt'.  Each of the steps executed by the script are self-contained in a separate function to maximum possible reuse.  The steps executed to create the tidy data set and resulting file are:

### Get the raw data files
Calls a function named 'getDataFiles' which checks to see if the raw data files already exist in a subdirectory named './data'.  If any of the files, inluding the zip fle, needed to successfully run the script do not exist then the zip file is downloaded (if it does not exist) and unzipped overwriting those files that do not exist.

### Combine the training and test data sets into one
Now that we are assured that the necessary files exist, the 'readAndMergeData' function is called.  The 'readAndMergeData' function reads the data from the 'test/X_test.txt' and the 'train/X_train.txt' files and uses the 'rbind' method to combine the rows.  It also reads the feature names from 'features.txt' and sets the column names for the new combined data set to the variable names (the second column) obtained from reading in the feature names.  The function then returns this data set.

### Extract only the measurements on the mean and standard deviation
The combined data set obtained from the 'readAndMergeData' function is passed to the 'filterOutMeansAndStds' function.  This function creates a subset of the original data set by selecting only those column names that signified mean and standard deviation.  The instructions were a bit ambiguous as there are many variables that exist in the data set with 'mean' as part of their name but do not have a complementaty measurment for standard deviation.  Thus, I interpreted te instructions to mean that only those columns with measurements for both mean and standard deviation measurements should be selected.  Exploratory analysis of the data set showed that these variables are those with 'mean()' or 'std()' as part of the name.  Therefore, a filter for column names with 'mean()' and 'std()' was selected and the resulting subset of data is returned from the function as a data set.

### Add descriptive activity names to the data set. Also label with descriptive variable names. 
The data set obtained from filtering out for only means and standard deviations is then passed to the 'addSubjectAndActivityLabels' method to add a column for both the Subject information and the Activity Labels ot the data set. First, the activity label information is read from the 'activity_labels.txt' file and stored in a data set.  Then the activity information for each subject for each record is read from the 'test/y_test.txt' and 'train/y_train.txt' files respectively.  These files represent the activity information with the activity identifier, so the data for each of these tables is replaced with their corresponding activity label by matching on the activity identifier.  The two activity tables are then combined using 'rbind' and a column name of 'Activity' is set for the resulting vector.

Using a similar approach, the subject information is obtained by reading from the 'test/subject_test.txt' and 'train/subject_train.txt' files respectively, using 'rbind' to combine the data sets, and setting the column name to 'Subject'

Some formatting is performed on the column names to remove parantheses and subsititute dashes with underscores simply to improve readability for descriptive varibale names.  Lastly, the subject, activity, and original data set are combined together using 'cbind' and returned from the function.

### Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
The resulting data set from calling the 'addSubjectAndActivityLabels' method is passed to the 'meltDataSet' method.  This method uses the 'melt' and 'dcast' methods found in the 'reshape2' package to reshape the data and form a new, tidy data set.  First, we check to see if the 'reshape2' package is already installed and if it is not then install it. The 'library(reshape2)' method is called so the methods within this package can be used.  The 'melt' function is called to melt the data set with ids of 'Subject' and 'Activity' that were added to the data set from previously calling the 'addSubjectAndActivityLabels' method.  Since no variable names are passed into the method, it will use all variables other than the two we used for the ids as the variables.  The 'dcast' method is then executed to cast the resulting melted data set as a data frame that is broken down by subjects and activities for each subject.  Because we want the mean for variable, 'mean' is passed in as the function aggregate.  This is the same approached that is outlined in slide 4 and 5 of the 'Reshaping Data' video lecture found at https://class.coursera.org/getdata-006/lecture/37.

The resulting tidy data set is then returned from the function.

### Save the new data set in a file name 'tidydataset.txt'
The tiny data set resulting from calling 'meltDataSet' is passed to the 'saveDataSet' method to save the data set to a file named 'tidydataset.txt' using the write.table with row.name=FALSE. 
