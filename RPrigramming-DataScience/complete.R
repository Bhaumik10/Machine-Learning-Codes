rm(list = setdiff(ls(), lsf.str()))
source('/Users/Bhaumik/Desktop/specdata')
specdata <- "specdata/"
id <- 1:332

complete <- function(dir,id=1:332)
{
  directory <- dir
  file_r <- id
  case_without_na <- data.frame()
  output <- data.frame()
  
  files <-length(file_r) #will get the length of file which entered by user
  nobs = numeric()
  for (i in 1:files)
  {
    
    file_name <- sprintf("%03d.csv",file_r[i]) # convert in 3 digits file name
    
    file_path <- paste('/Users/Bhaumik/Desktop/',directory,file_name,sep = "/") # gives file path
    
    data <- read.csv(file_path,stringsAsFactors=FALSE) #read mention substance column
    data[data==""] <- NA
    
    nobs = c(nobs, sum(complete.cases(data)))
    #     case_without_na1 <- data.frame(data[complete.cases(data),])
    #     output1 <- aggregate(case_without_na1$ID, by = case_without_na1[c('ID')], length)
    #     output <- rbind(output,output1)
    #case_without_na <- rbind(case_without_na,case_without_na1)
    
    
  }
  
  #output <- aggregate(case_without_na$Date, by = case_without_na[c('ID')], length)
  
  #   colnames(output) <- c("id","nobs")
  #   
  #   
  #   newop <- data.frame(output)
  #   
  #   colnames(newop) <- c("id","nobs")
  #   print(newop)
  #   
  #   #print(class(newop))
  return(data.frame(id, nobs))
}
