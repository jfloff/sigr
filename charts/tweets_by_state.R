setwd("~/Code/twitter-mood")

library(rjson)
library(sp)
library(ggplot2)
library(plyr)
library(reshape)
library(scales)

# Open csv with state for each point
anew_scores <- read.csv("data/scores_with_state_and_county_hedonometer.csv", header = TRUE, colClasses=c(NA,'NULL',NA))
all_tweets <- read.csv("data/all_tweets_by_state.csv", header = TRUE)

# remove columbia
anew_scores <- subset(anew_scores, state!="district of columbia")

# count tweets by state
tweets_by_state <- count(anew_scores, c('state'))
colnames(tweets_by_state)[2] <- "anew_count"
tweets_by_state$all_count = all_tweets$freq

percentage = round((tweets_by_state$anew_count * 100)/tweets_by_state$all_count, digits=2)
mean(percentage)

percentage <- sapply(percentage, function(x) paste(x, "%", sep=""))

melted_data <- melt(tweets_by_state, id.vars = "state")

mean_anew_tweets <- round(mean(tweets_by_state$anew_count))
mean_all_tweets <- round(mean(tweets_by_state$all_count))

plot = ggplot(data=melted_data, aes(x=state, y=value, fill=variable, order = -as.numeric(variable), width = 0.75)) + 
#   geom_hline(aes(yintercept = mean_anew_tweets), show_guide = TRUE, linetype = "longdash", size = 0.5, colour='orange') +
  coord_flip() + 
  geom_bar(stat="identity",position = "identity") + 
  scale_fill_manual(values = c("orange",muted("blue")), labels=c("Tweets with LabMT words", "Total Tweets")) +
  scale_y_continuous(expand=c(0.001,0), breaks=pretty_breaks(n=10)) +
  expand_limits(y = 47000) +
  ggtitle("Number of Tweets by US State") + 
  theme_bw() + 
  theme(legend.title=element_blank(), legend.position="bottom") +
  xlab("State") +
  ylab("Number of Tweets") +
  annotate("text", x = tweets_by_state$state, y = tweets_by_state$all_count, label = percentage, size = 3.5, hjust=-0.15, vjust=0.45)
  
plot

png(file="paper/images/tweets_by_state.png",width=900,height=650,res=96)
plot
dev.off()