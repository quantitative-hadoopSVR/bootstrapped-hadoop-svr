# Thi function implements the update function in its
# basic version, taht is merging two datasets current dataset
# with the new sample coming from the operational data.

updateKB <- function(currentTS, newSample) {
  # TOOD: check that the two input datase frame are consistents
  return(rbind(currentTS, newSample));
}