# this is the main function which run the bootstrapped SVR 
# It initialize the SVM using data sampled from the AM.
# Then it perform the enhancement of the predictor
# by re-training it over a training set that is 
# at each timestep updated with data cominig from the operations.

main <- function(amDatasetPath, opDatasetPath, pSampleAM, iterations){
  #TODO: add checks on the input parameters
  
  if (pSampleAM-round(pSampleAM)!=0 | as.integer(pSampleAM>100) | as.integer(pSampleAM)<0)
  {stop("Specify percentage as number between 0 and 100")}
  else if (iterations-round(iterations)!=0)
  {stop("Specify iterations as integers")}
  
  
  # load the libsvm library
  library(e1071);
  
  # sources all the R scripts in the current folder
  for (nm in list.files("./", pattern = "\\.[RrSsQq]$")) {
    cat(nm,":")           
    source(file.path("./", nm))
    cat("\n")
  }
  
  # generates the synthetic initial training set
  TS<-initKB(amDatasetPath, pSampleAM); 
  
  # TODO: add the initial training of the machine learner over the traning set
  model<- svm(x = data.frame(TS$nCore), y = data.frame(TS$responseTime), type = "eps-regression");
  print(model);
  plot(TS,col=2);
  # for each sample coming from the operations
  # updates the KB with the new samples
  # and re-traing the machine learner
  for(D in collectSamples(opDatasetPath, iterations)) {
    TS<-updateKB(TS, D);
    # TODO: add the re-train of che machine learner
    model<- svm(x = data.frame(TS$nCore), y = data.frame(TS$responseTime), type = "eps-regression");
    # plot(model,data.frame(TS$nCore),data.frame(TS$responseTime),type="eps-regression");
    print(model);
  }

 }