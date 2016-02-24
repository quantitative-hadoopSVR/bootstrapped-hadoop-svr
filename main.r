main <- function(amDatasetPath, opDatasetPath, nSampleAM, iterations){
  #TODO: add checks on the input parameters

  # load the libsvm library
  library(e1071);
  
  # sources all the R scripts in the current folder
  for (nm in list.files("./", pattern = "\\.[RrSsQq]$")) {
    cat(nm,":")           
    source(file.path("./", nm))
    cat("\n")
  }
  
  # generates the synthetic initial training set
  TS<-initKB(amDatasetPath, nSampleAM); 
  
  # TODO: add the initial training of the machine learner over the traning set
  model<- svm(x = data.frame(TS$nCore), y = data.frame(TS$responseTime), type = "eps-regression");
  print(model);
  
  # for each sample coming from the operations
  # updates the KB with the new samples
  # and re-traing the machine learner
  for(D in collectSamples(opDatasetPath, iterations)) {
    TS<-updateKB(TS, D);
    # TODO: add the re-train of che machine learner
    model<- svm(x = data.frame(TS$nCore), y = data.frame(TS$responseTime), type = "eps-regression");
    print(model);
  }
  
  return(model);
  
}