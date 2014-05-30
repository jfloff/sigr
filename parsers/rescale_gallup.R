gallup <- read.csv("data/gallup.csv", header = TRUE, colClasses=c(NA,NA,NA))

rescale_gallup <- function(x) {
  # http://stackoverflow.com/questions/5294955/how-to-scale-down-a-range-of-numbers-with-a-known-min-and-max-value
  # you want to scale a range [min,max] to [a,b]
  min = 0
  max = 10
  a = 1
  b = 9
  (((b - a) * (x - min))/(max - min)) + a
}

rescale_gallup <- data.frame(
  state = gallup$state,
  gallup_2012_score = round(sapply(gallup$gallup_2012_score, function(x) rescale_gallup(x)), digits = 2),
  gallup_2013_score = round(sapply(gallup$gallup_2013_score, function(x) rescale_gallup(x)), digits = 2)
)

write.csv(rescale_gallup, file="data/rescale_gallup.csv", row.names=FALSE)