setwd("~/Code/twitter-mood")

library(rjson)
library(sp)
library(plyr)

# The single argument to this function, pointsDF, is a data.frame in which:
#   - column 1 contains the longitude in degrees (negative in the US)
#   - column 2 contains the latitude in degrees
latlong2state <- function(pointsDF) {
  # Prepare SpatialPolygons object with one SpatialPolygon
  # per state (plus DC, minus HI & AK)
  states <- map('state', fill=TRUE, col="transparent", plot=FALSE)
  IDs <- sapply(strsplit(states$names, ":"), function(x) x[1])
  states_sp <- map2SpatialPolygons(states, IDs=IDs,
                                   proj4string=CRS("+proj=longlat +datum=wgs84"))
  
  # Convert pointsDF to a SpatialPoints object 
  pointsSP <- SpatialPoints(pointsDF, 
                            proj4string=CRS("+proj=longlat +datum=wgs84"))
  
  # Use 'over' to get _indices_ of the Polygons object containing each point 
  indices <- over(pointsSP, states_sp)
  
  # Return the state names of the Polygons object containing each point
  stateNames <- sapply(states_sp@polygons, function(x) x@ID)
  stateNames[indices]
}

# Open connection to file
json_file <- 'data/us_geo_tweets'
con  <- file(json_file, open = "r")

# store the data so after we build a data frame
lats <- c()
lons <- c()

i <- 1
while (length(line <- readLines(con, n = 1, warn = FALSE)) > 0)
{
  tweet <- fromJSON(line)
  
  lats[[i]] <- tweet[['coordinates']][['lat']]
  lons[[i]] <- tweet[['coordinates']][['lon']]
  
  i <- i + 1
}

close(con)

# get states for each point
states <- latlong2state(data.frame(x = lons, y = lats))

# build data frame without NAs
anew_scores <- subset(na.omit(data.frame(state = states)), state!="district of columbia")

all_tweets_by_state <- count(anew_scores, c('state'))

all_tweets_by_state

# write to CSV
write.csv(all_tweets_by_state, file="data/all_tweets_with_state.csv", row.names=FALSE)