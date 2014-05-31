setwd("~/Code/HappiTweet")

library(ggplot2)
library(reshape)
library(scales)
library(tableplot)
library(plyr)

mode <- function(x) {
  d <- density(x, from=1, to=9 , adjust = 0.805)
  d$x[which.max(d$y)]
}

# Open csv with state for each point
anew_scores <- read.csv("data/scores_with_state_and_county_hedonometer.csv", header = TRUE, colClasses=c(NA,'NULL',NA))

split_by_state <- split(anew_scores, anew_scores$state)
split_by_state[['district of columbia']] <- NULL

# vector with mean by each state
scores_mean <- sapply(split_by_state, function(x) round(mean(x$anew_score), digits=2))
scores_sd <- sapply(split_by_state, function(x) round(sd(x$anew_score), digits=2))
scores_median <- sapply(split_by_state, function(x) round(median(x$anew_score), digits=2))
scores_mode <- sapply(split_by_state, function(x) round(mode(x$anew_score), digits=2))

gallup <- read.csv("data/rescale_gallup.csv", header = TRUE, colClasses=c(NA,NA,'NULL'))
colnames(gallup)[2] <- "gallup_score"
# gallup <- sapply(split(gallup_df, gallup_df$state), function(x) x$gallup_score)

gallup$gallup_ranking = rank(-gallup$gallup_score, ties.method= "first")

# add geo_happy paper ranking
geo_happy <- read.csv("data/geo_happy.csv", header = TRUE)
gallup$geo_happy_score = sapply(split(geo_happy, geo_happy$state), function(x) x$score)[gallup$state]
gallup$geo_happy_ranking = rank(-gallup$geo_happy_score, ties.method= "first")

# statistics
gallup$anew_score_mean = scores_mean[gallup$state]
gallup$anew_score_sd = scores_sd[gallup$state]
gallup$anew_score_median = scores_median[gallup$state]
gallup$anew_score_mode = scores_mode[gallup$state]

gallup$anew_ranking = rank(-gallup$anew_score_mode, ties.method= "first")
gallup$mean_diff = round(gallup$gallup_score - gallup$anew_score_mean, digits=2)
gallup$median_diff = round(gallup$gallup_score - gallup$anew_score_median, digits=2)
gallup$mode_diff = round(gallup$gallup_score - gallup$anew_score_mode, digits=2)

# count tweets by state
count(anew_scores, c('state'))[-8, ]$freq
gallup$tweets <- count(anew_scores, c('state'))[-8, ]$freq

mean(gallup$anew_score_mean)
mean(gallup$anew_score_median)
mean(gallup$anew_score_mode)
mean(gallup$tweets)
mean(gallup$mean_diff)
mean(gallup$median_diff)
mean(gallup$mode_diff)
mean(gallup$anew_score_sd)
cor(gallup$gallup_score , gallup$anew_score_mean)
cor(gallup$gallup_score , gallup$anew_score_median)
cor(gallup$gallup_score , gallup$anew_score_mode)
cor(gallup$gallup_score , gallup$geo_happy_score)
cor(gallup$anew_score_mode , gallup$geo_happy_score)
# ggplot(gallup, aes(x=gallup_score, y=anew_score_mode)) + geom_point(shape=1) + geom_smooth(method=lm, se=FALSE)
cor(gallup$median_diff , gallup$anew_score_sd)
cor(gallup$mode_diff , gallup$anew_score_sd)
cor(gallup$tweets, gallup$mean_diff)
cor(gallup$tweets, gallup$median_diff)
cor(gallup$tweets, gallup$mode_diff)
cor(gallup$tweets, gallup$anew_score_sd)
cor(gallup$tweets, gallup$anew_ranking)
cor(gallup$tweets, gallup$anew_score_mode)

# reorder columns
gallup <- gallup[c("state", "tweets", "anew_ranking", "gallup_ranking", "geo_happy_ranking", "gallup_score", "geo_happy_score", "anew_score_mode",  "mode_diff", "anew_score_median", "median_diff", "anew_score_mean", "mean_diff", "anew_score_sd")]
gallup <- gallup[with(gallup, order(anew_ranking)), ]
gallup
