##Make sure all the raw data files exist.  
##If data files do not yet exists, download the zip file, create the data subdirectory 
##and unzip the raw data files into it
getDataFiles <- function()
{
    ##check if data subdectory exists
    if(!file.exists("./data"))
    {
        dir.create("./data")
    }

    ## if raw zip file does not exist, download it
    if(!file.exists("./data/rawdata.zip"))
    {
        ## if doesnt exist download file
        download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile = "./data/rawdata.zip")
    }
        
    ##check the subdirectories for train and test do not exist, extract from zip file
    if(!file.exists("./data/UCI HAR Dataset/features.txt") | 
          !file.exists("./data/UCI HAR Dataset/activity_labels.txt") | 
        !file.exists("./data/UCI HAR Dataset/test") | 
           !file.exists("./data/UCI HAR Dataset/test/subject_test.txt") |
           !file.exists("./data/UCI HAR Dataset/test/X_test.txt") |
           !file.exists("./data/UCI HAR Dataset/test/y_test.txt") |
       !file.exists("./data/UCI HAR Dataset/train") |
           !file.exists("./data/UCI HAR Dataset/train/subject_train.txt") |
           !file.exists("./data/UCI HAR Dataset/train/X_train.txt") |
           !file.exists("./data/UCI HAR Dataset/train/y_train.txt") 
        )
    {
        ##extract file from zip.  suppress warnings for files we dont need to overwrite
        suppressWarnings(unzip("./data/rawdata.zip", overwrite = FALSE, exdir="./data"))
    }            
}


##Read the data from the files and merge the datasets
##the dataset contains the raw data from the sensors (X_train and X_Test), 
readAndMergeData <- function()
{           
    #get test data and combine with subject and activity labels
    testData<-read.table("./data/UCI HAR Dataset/test/X_test.txt", header=F, stringsAsFactors=FALSE)    
    
    #get training data and combine with subject and activity labels
    trainData<-read.table("./data/UCI HAR Dataset/train/X_train.txt", header=F, stringsAsFactors=FALSE)
    
    #combine the two datasets into one
    combinedData<-rbind(testData,trainData)
    
    #add the columns names
    features <- read.table("./data/UCI HAR Dataset/features.txt", stringsAsFactors=FALSE, header=F)
    colnames(combinedData) <- features$V2
    return (combinedData)
}

##Subset the dataset for only those features that relate to mean or std
filterOutMeansAndStds<-function(sensorData)
{    
    #return (sensorData[,which(colnames(sensorData) %like% "_mean[(][)]" | colnames(sensorData) %like% "_std[(][)]")])
    return (sensorData[,which(colnames(sensorData) %like% "mean[(]" | colnames(sensorData) %like% "std[(]")])
}

##Add the subject information (subject_train and suject_test) and 
##the activity information (y_train and y_test) to the dataset
addSubjectAndActivityLabels <- function(sensorData)
{
    #get activity labels
    activityLabels<-read.table("./data/UCI HAR Dataset/activity_labels.txt", header=F, stringsAsFactors=FALSE)  
    
    #create list of activity labels for test and training data sets
    testActivity<-read.table("./data/UCI HAR Dataset/test/y_test.txt", header=F, stringsAsFactors=FALSE)
    trainActivity<-read.table("./data/UCI HAR Dataset/train/y_train.txt", header=F, stringsAsFactors=FALSE)
    testActivity[,1]<-activityLabels[testActivity[,1],2]
    trainActivity[,1]<-activityLabels[trainActivity[,1],2]            
    activity<-rbind(testActivity,trainActivity)
    colnames(activity)<-"Activity"
        
    testSubjects<-read.table("./data/UCI HAR Dataset/test/subject_test.txt", header=F, stringsAsFactors=FALSE)    
    trainSubjects<-read.table("./data/UCI HAR Dataset/train/subject_train.txt", header=F, stringsAsFactors=FALSE)
    subjects<-rbind(testSubjects,trainSubjects)
    colnames(subjects)<-"Subject"
    
    #remove the paranthesis and substitute underscore for dash from column names for increased readability
    colnames(sensorData)<-gsub("[()]","",colnames(sensorData))
    colnames(sensorData)<-gsub("-","_",colnames(sensorData))
    
    sensorData<-cbind(subjects, activity, sensorData)
}

##Perform a melt to create a dataset for the means of the variables for 
##each combination of variable, ##subject, and activity
if(!is.element('reshape2', installed.packages()[,1])) 
{
    install.packages('reshape2')
}
library(reshape2)
meltDataSet<-function(sensorDataWithSubjectAndActivity)
{
    meltedDF<-melt(sensorDataWithSubjectAndActivity, , id=c("Subject", "Activity"))
    return (dcast(meltedDF, Subject + Activity ~ variable, mean))
}

##Save the dataset to the file tidydataset.txt
saveDataSet<-function(dataset)
{
    write.table(dataset, "tidydataset.txt", row.name=FALSE)
}

##Perform the steps for the run analysis
runAnalysis<-function()
{
    cat("0. Getting the raw data files\n")
    getDataFiles()
    
    cat("1. Merging the training and the test sets to create one data set\n")
    originalDataset<-readAndMergeData()
    
    cat("2. Extracting only the measurements on the mean and standard deviation for each measurement (with labels).\n")
    filteredDataset<-filterOutMeansAndStds(originalDataset)
    
    cat("3. Setting descriptive activity names to name the activities in the data set\n")
    dataSetWithLabels<-addSubjectAndActivityLabels(filteredDataset)
    
    cat("4. Creating tidy data set for the means of the variables for combination of variable, subject, and activity.\n")
    newTidyDataset<-meltDataSet(dataSetWithLabels)
    
    cat("5. Saving to new data set to file\n")
    saveDataSet(newTidyDataset)
}

##Call the runAnalysis to perform all the steps needed to create the tidy data set
runAnalysis()