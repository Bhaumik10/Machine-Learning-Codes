rm(list = setdiff(ls(), lsf.str()))
source("http://d396qusza40orc.cloudfront.net/rprog%2Fscripts%2Fsubmitscript1.R")
source('/Users/Bhaumik/Desktop/specdata/')
specdata <- "specdata/"
sulfate <- 'sulfate'
nitrate <- 'nitrate'
id <- 1:332

pollutantmean <- function(dir,pollut,id=1:332)
{
  directory <- dir
  substance <- c(pollut)
  file_r <- id
  final_data <- ''
  data_4_mean <- ''
  
  files <-length(file_r) #will get the length of file which entered by user
  
  for (i in 1:files)
  {
    
    file_name <- sprintf("%03d.csv",file_r[i]) # convert in 3 digits file name
    
    file_path <- paste('/Users/Bhaumik/Desktop',directory,file_name,sep = "/") # gives file path
    
    data <- read.csv(file_path)[,substance] #read mention substance column
    data[data==""] <- NA
    data <- na.omit(unlist(data))
    final_data <- as.numeric(unlist(c(final_data,data)))
  }
  final_data_4_mean <- na.omit(final_data)
  Pollutantmean_final<- mean(final_data_4_mean)
  print(Pollutantmean_final)
}

