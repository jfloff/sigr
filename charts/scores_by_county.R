setwd("~/Code/twitter-mood")

library(sp)
library(ggplot2)
library(maps)
library(maptools)
library(RColorBrewer)
library(scales)

mode <- function(x) {
  if(length(x) < 2)
  {
    x
  }
  else
  {
    d <- density(x, from=1, to=9 , adjust = 0.805) 
    d$x[which.max(d$y)]
  }
}

# Open csv with state for each point
anew_scores <- read.csv("data/scores_with_state_and_county_hedonometer.csv", header = TRUE, colClasses=c('NULL',NA,NA))

tweets_by_county <- count(anew_scores, c('county'))

# Gets data set with states already inside R
counties_polygons = map_data('county')

# scale for colors and limit values --> taken from state chart
scale <- c(6.210000, 6.234657, 6.247939, 6.274504, 6.301069, 6.314351, 6.680000)

# vector with mean by each state
scores_mode <- sapply(split(anew_scores, anew_scores$county), 
    function(x) {
      val <- round(mode(x$anew_score), digits=2)
      if (val>max(scale))
        max(scale)
      else if (val < min(scale))
        min(scale)
      else
        val 
    }
)

#Now link the vote data to the state shapes by matching names:
counties_polygons$scores_mode = scores_mode[counties_polygons$subregion]

#Finally, add a color layer to the map:
# passes the map, and as fill column the scores
map = ggplot(counties_polygons) +
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

map = map + scale_fill_gradientn(
  colours = brewer.pal(length(scale), "RdYlGn"),
  values = rescale(scale),
  name = 'LabMT \nscore',
  na.value = NA
)

map = map + theme(plot.title=element_text(face="bold"))
map = map + coord_map(project='globular') + ggtitle("LabMT score for tweets by US County")

map

png(file="paper/images/scores_by_county.png",width=900,height=450,res=96)
map
dev.off()