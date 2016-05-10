setwd("/home/irma/quantitative/cineca-runs-20160116/R2")
files <- list.files(pattern = ".csv") ## creates a vector with all file names in your folder
nMmean <- rep(0,length(files))
nRmean <- rep(0,length(files))
tMmean <- rep(0,length(files))
tRmean <- rep(0,length(files))
respmean <- rep(0,length(files))
ncores <- rep(0,length(files))
for(i in 1:length(files)){
  data <- read.csv(files[i],header=T)
  nMmean[i]<- mean(data$nM)
  nRmean[i] <- mean(data$nR)
  tMmean[i] <- mean(data$Mavg)
  tRmean[i] <- mean(data$Ravg)
  respmean[i] <- mean(data$nM)
  ncores[i]<- mean(data$nCores)
}
result <- cbind(files,nRmean,nMmean, tMmean, tRmean,respmean,ncores)
write.csv(result,"result_means.csv")