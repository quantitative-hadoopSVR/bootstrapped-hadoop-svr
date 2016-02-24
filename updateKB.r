# basic version of the update function just merging the two datasets
updateKB <- function(currentTS, newSample) {
  # TOOD: check that the two input datase frame are consistents
  return(rbind(currentTS, newSample));
}