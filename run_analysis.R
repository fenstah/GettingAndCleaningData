
##Make sure all the raw data files exist.  
##If not download the zip file, create the data subdirectory and unzip the raw data files into it
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

##get a vector for the features
getFeatures <- function()
{
    features<-read.table("./data/UCI HAR Dataset/features.txt", stringsAsFactors=FALSE, header=F)
    
    #make the feature names more meaningfule
    #remove parantheses
    features$V2<-gsub("[()]", "", features$V2)
    
    #replace commas with underscores
    features$V2<-gsub(",", "_", features$V2)
    
    #return a vector of feature names
    return (features$V2)
}

##read the data from the files and merge the datasets
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
    colnames(combinedData) <- getFeatures()
    return (combinedData)
}

##subset the dataset for only those features that relate to mean or std
filterOutMeansAndStds<-function(sensorData)
{
    return (sensorData[,which(colnames(sensorData) %like% "[Mm][Ee][Aa][Nn]" | colnames(sensorData) %like% "[Ss][Tt][Dd]")])
}

##adds the subject information (subject_train and suject_test) and the activity information (y_train and y_test)
##to the dataset
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
    
    sensorData<-cbind(subjects, activity, sensorData)
}
