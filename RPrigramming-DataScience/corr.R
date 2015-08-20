rm(list = setdiff(ls(), lsf.str()))
source('/Users/Bhaumik/Desktop/specdata')
specdata <- "specdata/"
id <- 1:50000

corr <- function(dir,threshold = 0)
{
  directory <- dir
  threshold_no <- threshold
  file_path_init <- paste('/Users/Bhaumik/Desktop/',directory,sep = "/")
  All_files <- list.files(file_path_init)
  #print(All_files)
  final_data <- ''
  corrsNum <- numeric(0)
  files <-length(All_files) #will get the length of file which entered by user
  corNum <- numeric(0)
  for (i in 1:files)
  {
    
    file_path <- paste('/Users/Bhaumik/Desktop/',directory,All_files[i],sep = "/") # gives file path
    
    data <- read.csv(file_path) #read mention substance column
    data[data==""] <- NA
    data_threshold <- nrow(data.frame(cbind(data[complete.cases(data),])))
    #data_threshold <- nrow(sample_data)
    
    if(data_threshold > threshold_no )
    {
      final_data <- data
      data_corr<-data.frame(final_data[complete.cases(final_data),],stringsAsFactors = FALSE)
      sulfate <- as.numeric(unlist(data_corr["sulfate"]))
      nitrate <- as.numeric(unlist(data_corr["nitrate"]))
      corNum <- c(corNum, cor(sulfate, nitrate))
    }
  }
  
  print(head(corNum))
  print(summary(corNum))
  print(length(corNum))
  return(corNum)
}


#corr(specdata)
