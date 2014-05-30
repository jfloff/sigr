setwd("~/Code/twitter-mood")

library(ggplot2)
library(reshape)
library(scales)

mode <- function(x) {
  d <- density(x, from=1, to=9 , adjust = 0.805)
  d$x[which.max(d$y)]  
}

#gallup data frame
gallup <- read.csv("data/rescale_gallup.csv", header = TRUE, colClasses=c(NA,'NULL',NA))
colnames(gallup)[2] <- "gallup_score"
gallup$ranking = rank(-gallup$gallup_score, ties.method= "first")
gallup$group = "Gallup"
gallup <- subset(gallup, select=c(group,state,ranking))

# anew data frame
# Open csv with state for each point
anew_scores <- read.csv("data/scores_with_state_and_county_hedonometer.csv", header = TRUE, colClasses=c(NA,'NULL',NA))

split_by_state <- split(anew_scores, anew_scores$state)
split_by_state[['district of columbia']] <- NULL

# vector with mean by each state
scores_mode <- sapply(split_by_state, function(x) round(mode(x$anew_score), digits=2))

# anew data frame
anew <- data.frame(state = gallup$state)
anew$anew_score = scores_mode[anew$state]
anew$ranking = rank(-anew$anew_score, ties.method= "first")
anew$group = "LabMT"
anew <- data.frame(group = anew$group, state = anew$state, ranking = anew$ranking)


#bump chart
bump <- rbind(anew,gallup)
plot <- ggplot(bump, aes(x=group, y=ranking, group=state, label=state, colour=state)) +
  geom_line(stat='identity') +
  scale_y_reverse(breaks=pretty_breaks(n=25)) +
  labs(x = '', y = 'Ranking') +
  geom_text(data = subset(bump, group == "LabMT"), size=3, hjust=1.05) +
  geom_text(data = subset(bump, group == "Gallup"), size=3, hjust=-0.05) +
  theme_bw() + 
  theme(legend.position="none") +
  ggtitle("Comparation between LabMT and Gallup rankings by US State")

plot

png(file="paper/images/bump_chart.png",width=800,height=650,res=96)
plot
dev.off()
