setwd("~/Code/twitter-mood")

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
states_polygons = subset(states_polygons, region != 'district of columbia')

split_by_state <- split(anew_scores, anew_scores$state)
split_by_state[['district of columbia']] <- NULL

# vector with mean by each state
scores_mode <- sapply(split_by_state, function(x) round(mode(x$anew_score), digits=2))

#Now link the vote data to the state shapes by matching names:
states_polygons$scores_mode = scores_mode[states_polygons$region]

# ranking = sort(rank(-scores_mode, ties.method= "first"))
# ranking = replace(ranking,c(1:9),"Top Quintile") #9 since Hawaii is here on Gallup
# ranking = replace(ranking,c(10:19),"2nd Quintile")
# ranking = replace(ranking,c(20:29),"3rd Quintile")
# ranking = replace(ranking,c(30:38),"4th Quintile") #9 since Alaska is here on Gallup
# ranking = replace(ranking,c(39:48),"5th Quintile")
# states_polygons$quantiles = ranking[states_polygons$region]

get_quantile <- function(quantiles, value) {
  if (quantiles[1] <= value & value <= quantiles[2]) {
    return("5th Quintile")
  } else if (quantiles[2] <= value & value <= quantiles[3]) {
    return("4th Quintile")
  } else if (quantiles[3] <= value & value <= quantiles[4]) {
    return("3th Quintile")
  } else if (quantiles[4] <= value & value <= quantiles[5]) {
    return("2nd Quintile")
  } else if (quantiles[5] <= value & value <= quantiles[6]) {
    return("1st Quintile")
  }
}

quantiles <- quantile(scores_mode, c(0, 0.2, 0.4, 0.6, 0.8, 1))
states_polygons$quantiles <- sapply(states_polygons$scores_mode, function(x) get_quantile(quantiles, x))

#Finally, add a color layer to the map:
# passes the map, and as fill column the scores
map = ggplot(states_polygons) +
  aes(long, lat, group=group) +
  geom_polygon() +
  aes(fill=quantiles) + 
  labs(fill = "Quintiles") +
  theme_bw() +
  theme(legend.position = "bottom",
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank()
  ) + 
  scale_fill_manual(values = c('#689A27','#4DA7C1','#E7CD44','#E87625','#C53D27'))

# 2013
# GREEN = #4F993F
# BLUE = #329FB2
# YELLOW = #E4CC3C
# ORANGE = #E76B19
# RED = #C22D20

# 2012
# GREEN = #689A27
# BLUE = #4DA7C1
# YELLOW = #E7CD44
# ORANGE = #E87625
# RED = #C53D27


map = map + theme(plot.title=element_text(face="bold"))
map = map + coord_map(project='globular') + ggtitle("Quintiles for Gallup-Healthway 2012 Score by US State")

map

png(file="paper/images/FOR_REPLACE_scores_by_state_gallup_style.png",width=900,height=550,res=96)
map
dev.off()