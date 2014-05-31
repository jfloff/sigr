setwd("~/Code/HappiTweet")

library(ggplot2)
library(reshape)
library(scales)

mode <- function(x) {
  d <- density(x, from=1, to=9 , adjust = 0.805)
  d$x[which.max(d$y)]
}

# Open csv with state for each point
anew_scores <- read.csv("data/scores_with_state_and_county_hedonometer.csv", header = TRUE, colClasses=c(NA,'NULL',NA))

split_by_state <- split(anew_scores, anew_scores$state)
split_by_state[['district of columbia']] <- NULL

# vector with mean by each state
scores_mode <- sapply(split_by_state, function(x) round(mode(x$anew_score), digits=2))

gallup <- read.csv("data/rescale_gallup.csv", header = TRUE, colClasses=c(NA,'NULL',NA))
colnames(gallup)[2] <- "gallup_score"
# gallup <- sapply(split(gallup_df, gallup_df$state), function(x) x$gallup_score)

gallup$anew_score = scores_mode[gallup$state]
gallup$diff = round(gallup$gallup_score - gallup$anew_score, digits=2)
gallup$mean = apply(subset(gallup, select=c(gallup_score, anew_score)),1,mean)

# melt() stacks the two response variables into a
# factor (variable) and its values (value)
melted_gallup <- melt(subset(gallup, select=c(state, gallup_score, anew_score)), id = c('state'))

# Use the new factor as the variable defining the color
# aesthetic and use the value variable as the response
plot = ggplot(melted_gallup, aes(x = state, y = value, colour = variable, group = state, width = 0.75)) +
  ggtitle("Differences between LabMT and Gallup Score") +
  scale_y_continuous(breaks=pretty_breaks(n=22)) +
  geom_point() +
  geom_line(colour = 'black', size = 0.25) +
  annotate("text",
           x = gallup$state, y = gallup$mean,
           label = gallup$diff,
           size = 2.75, vjust=-0.6
  ) +
  expand_limits(x = 49) +
  coord_flip() +
  labs(x = 'State', y = 'Score', colour = 'Score') +
  theme_bw() +
  theme(legend.position="bottom") +
  scale_colour_manual(
    breaks = levels(melted_gallup$variable),
    values = c('red', 'green'),
    labels = c("Gallup", "LabMT")
  )

plot

png(file="paper/images/differences.png",width=800,height=750,res=96)
plot
dev.off()
