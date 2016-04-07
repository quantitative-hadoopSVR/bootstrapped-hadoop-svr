# this function collects data from the system during the operations.
# Being the operative data already all available it basically splits into
# sequential chunks the dataset of operative data and returns the list of chunks.

collectSamples <- function(file, iterations){
  #TODO: add checks on the input parameters
  T<-read.csv(file);
  x<-1:nrow(T);
  TS <- split(T, ceiling(x/iterations));
  return(TS);
}