setwd("~/Code/HappiTweet")

library(sp)
library(ggplot2)
library(maps)
library(maptools)
library(RColorBrewer)
library(scales)

mode <- function(x) {
  d <- density(x, from=1, to=9 , adjust = 0.805)
  d$x[which.max(d$y)]
}

# Open csv with state for each point
anew_scores <- read.csv("data/scores_with_state_and_county_hedonometer.csv", header = TRUE, colClasses=c(NA,'NULL',NA))

# Gets data set with states already inside R
states_polygons = map_data('state')

# vector with mean by each state
scores_mode <- sapply(split(anew_scores, anew_scores$state), function(x) round(mode(x$anew_score), digits=2))

#Now link the vote data to the state shapes by matching names:
states_polygons$scores_mode = scores_mode[states_polygons$region]

#Finally, add a color layer to the map:
# passes the map, and as fill column the scores
map = ggplot(states_polygons) +
  aes(long, lat, group=group) +
  geom_polygon() +
  aes(fill=scores_mode) +
  theme_bw() +
  theme(axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank()
  )

vector <- as.vector(states_polygons$scores_mode)
mean <- mean(vector, na.rm=TRUE)
sd <- sd(vector, na.rm=TRUE)
min <- min(vector)
max <- max(vector)

scale <- c(min, mean - (sd/2), mean - (sd/3) , mean, mean + (sd/3), mean + (sd/2), max)
map = map + scale_fill_gradientn(
  colours = brewer.pal(length(scale), "RdYlGn"),
  values = rescale(scale),
  name='LabMT \nscore'
)

map = map + theme(plot.title=element_text(face="bold"))
map = map + coord_map(project='globular') + ggtitle("LabMT score for tweets by US State")

map

png(file="paper/images/scores_by_state.png",width=900,height=450,res=96)
map
dev.off()
