
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
    if(!file.exists("./data/UCI HAR Dataset/test") | 
#            !file.exists("./data/UCI HAR Dataset/test/subject_test.txt") |
           !file.exists("./data/UCI HAR Dataset/test/X_test.txt") |
           !file.exists("./data/UCI HAR Dataset/test/y_test.txt") |
#            !file.exists("./data/UCI HAR Dataset/test/Inertial Signals") |  
#            !file.exists("./data/UCI HAR Dataset/test/Inertial Signals/body_acc_x_test.txt") | 
#            !file.exists("./data/UCI HAR Dataset/test/Inertial Signals/body_acc_y_test.txt") | 
#            !file.exists("./data/UCI HAR Dataset/test/Inertial Signals/body_acc_z_test.txt") | 
#            !file.exists("./data/UCI HAR Dataset/test/Inertial Signals/body_gyro_x_test.txt") | 
#            !file.exists("./data/UCI HAR Dataset/test/Inertial Signals/body_gyro_y_test.txt") | 
#            !file.exists("./data/UCI HAR Dataset/test/Inertial Signals/body_gyro_z_test.txt") | 
#            !file.exists("./data/UCI HAR Dataset/test/Inertial Signals/total_acc_x_test.txt") | 
#            !file.exists("./data/UCI HAR Dataset/test/Inertial Signals/total_acc_y_test.txt") | 
#            !file.exists("./data/UCI HAR Dataset/test/Inertial Signals/total_acc_z_test.txt") | 
       !file.exists("./data/UCI HAR Dataset/train") |
#            !file.exists("./data/UCI HAR Dataset/train/subject_train.txt") |
           !file.exists("./data/UCI HAR Dataset/train/X_train.txt") |
           !file.exists("./data/UCI HAR Dataset/train/y_train.txt") 
#            | !file.exists("./data/UCI HAR Dataset/train/Inertial Signals") |  
#            !file.exists("./data/UCI HAR Dataset/train/Inertial Signals/body_acc_x_train.txt") | 
#            !file.exists("./data/UCI HAR Dataset/train/Inertial Signals/body_acc_y_train.txt") | 
#            !file.exists("./data/UCI HAR Dataset/train/Inertial Signals/body_acc_z_train.txt") | 
#            !file.exists("./data/UCI HAR Dataset/train/Inertial Signals/body_gyro_x_train.txt") | 
#            !file.exists("./data/UCI HAR Dataset/train/Inertial Signals/body_gyro_y_train.txt") | 
#            !file.exists("./data/UCI HAR Dataset/train/Inertial Signals/body_gyro_z_train.txt") | 
#            !file.exists("./data/UCI HAR Dataset/train/Inertial Signals/total_acc_x_train.txt") | 
#            !file.exists("./data/UCI HAR Dataset/train/Inertial Signals/total_acc_y_train.txt") | 
#            !file.exists("./data/UCI HAR Dataset/train/Inertial Signals/total_acc_z_train.txt")
        )
    {
        ##extract file from zip.  suppress warnings for files we dont need to overwrite
        suppressWarnings(unzip("./data/rawdata.zip", overwrite = FALSE, exdir="./data"))
    }            
}

##read the data from the files and merge the datasets
readAndMergeData <- function()
{   
    testData<-read.table("./data/UCI HAR Dataset/test/X_test.txt", header=F, stringsAsFactors=FALSE)
    trainData<-read.table("./data/UCI HAR Dataset/train/X_train.txt", header=F, stringsAsFactors=FALSE)
    mergedData<-rbind(testData,trainData)
    return (mergedData)
}