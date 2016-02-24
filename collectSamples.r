collectSamples <- function(file, iterations){
  #TODO: add checks on the input parameters
  T<-read.csv(file);
  x<-1:nrow(T);
  TS <- split(T, ceiling(x/iterations));
  return(TS);
}