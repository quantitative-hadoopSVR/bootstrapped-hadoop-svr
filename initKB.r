initKB <- function(file, size){
  #TODO: add checks on the input parameters
  T<-read.csv(file);
  TS<-T[sample(1:nrow(T),size, FALSE),];
  return(TS);
}