# use this to put what you want to be ploted

plotModel <- function() {
  # TOOD: check that the two input datase frame are consistents
  
day = c(0,1,2,3,4,5,6)
weather = c(1,0,0,0,0,0,0)
happy = factor(c(T,F,F,F,F,F,F))

d = data.frame(day=day, weather=weather, happy=happy)
model2 = svm(happy ~ day + weather, data = d)
plot(model2, d);

}