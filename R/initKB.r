# this function initialize that knowledge base, or the training set,
# it basically samples the dataset resulting from the simulation
# of the AM and returns the samples dtaset.

initKB <- function(file, size){
  #TODO: add checks on the input parameters
  
  T<-read.csv(file);
  TS<-T[sample(1:nrow(T),round(size*nrow(T)/100,0), FALSE),];
  return(TS);
}
