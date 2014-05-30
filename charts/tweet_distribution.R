setwd("~/Code/twitter-mood")

library(ggplot2)
library(RColorBrewer)
library(scales)

smooth <- 0.805
mode <- function(x) {
  d <- density(x, from=1, to=9 , adjust = smooth)
  d$x[which.max(d$y)]
}

# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  require(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

# Open csv with state for each point
anew_scores <- read.csv("data/scores_with_state_and_county_hedonometer.csv", header = TRUE, colClasses=c(NA,'NULL',NA))

texas <- subset(anew_scores, state=='texas')
texas_mean <- mean(texas$anew_score)
texas_median <- median(texas$anew_score)
texas_mode <- mode(texas$anew_score)
texas_plot <- ggplot(texas, aes(x=anew_score)) + 
  geom_histogram(
    aes(y=..density..),
    binwidth=.5,
    colour="black", fill="white"
  ) +
  scale_y_continuous(expand=c(0.001,0), breaks=pretty_breaks(n=10)) +
  expand_limits(y = 0.65) +
  scale_x_continuous(expand=c(0.001,0.001), breaks=pretty_breaks(n=10)) +
  geom_vline(aes(xintercept = texas_mean), show_guide = TRUE, linetype = "longdash", size = 0.5, colour='red') +
  annotate("text", x = texas_mean, y = 0.59, label = "mean", size = 3.5, hjust = 1.1, colour = 'red') +
  geom_vline(aes(xintercept = texas_median), show_guide = TRUE, linetype = "longdash", size = 0.5, colour='blue') +
  annotate("text", x = texas_median, y = 0.63, label = "median", size = 3.5, hjust = -.1, colour = 'blue') +
  geom_vline(aes(xintercept = texas_mode), show_guide = TRUE, linetype = "longdash", size = 0.5, colour=muted('green')) +
  annotate("text", x = texas_mode, y = 0.59, label = "mode", size = 3.5, hjust = -.1, colour = muted('green')) +
  geom_density(from=1, to=9 , adjust = smooth, size=1.5 ) +
  theme_bw() + 
  ggtitle("Texas (most tweets)") + 
  xlab("LabMT Score") +
  ylab("Density")

vermont <- subset(anew_scores, state=='vermont')
vermont_mean <- mean(vermont$anew_score)
vermont_median <- median(vermont$anew_score)
vermont_mode <- mode(vermont$anew_score)
vermont_plot <- ggplot(vermont, aes(x=anew_score)) + 
  geom_histogram(
    aes(y=..density..),
    binwidth=.5,
    colour="black", fill="white"
  ) +
  scale_y_continuous(expand=c(0.001,0), breaks=pretty_breaks(n=10)) +
  expand_limits(y = 0.51) +
  scale_x_continuous(expand=c(0.001,0.001), breaks=pretty_breaks(n=10)) +
  geom_vline(aes(xintercept = vermont_mean), show_guide = TRUE, linetype = "longdash", size = 0.5, colour='red') +
  annotate("text", x = vermont_mean, y = 0.46, label = "mean", size = 3.5, hjust = 1.1, colour = 'red') +
  geom_vline(aes(xintercept = vermont_median), show_guide = TRUE, linetype = "longdash", size = 0.5, colour='blue') +
  annotate("text", x = vermont_median, y = 0.49, label = "median", size = 3.5, hjust = -.1, colour = 'blue') +
  geom_vline(aes(xintercept = vermont_mode), show_guide = TRUE, linetype = "longdash", size = 0.5, colour=muted('green')) +
  annotate("text", x = vermont_mode, y = 0.44, label = "mode", size = 3.5, hjust = -.1, colour = muted('green')) +
  geom_density(from=1, to=9 , adjust = smooth, size=1.5 ) +
  theme_bw() + 
  ggtitle("Vermont (least tweets)") + 
  xlab("LabMT Score") +
  ylab("Density")

colorado <- subset(anew_scores, state=='colorado')
colorado_mean <- mean(colorado$anew_score)
colorado_median <- median(colorado$anew_score)
colorado_mode <- mode(colorado$anew_score)
colorado_plot <- ggplot(colorado, aes(x=anew_score)) + 
  geom_histogram(
    aes(y=..density..),
    binwidth=.5,
    colour="black", fill="white"
  ) +
  scale_y_continuous(expand=c(0.001,0), breaks=pretty_breaks(n=10)) +
  expand_limits(y = 0.57) +
  scale_x_continuous(expand=c(0.001,0.001), breaks=pretty_breaks(n=10)) +
  geom_vline(aes(xintercept = colorado_mean), show_guide = TRUE, linetype = "longdash", size = 0.5, colour='red') +
  annotate("text", x = colorado_mean, y = 0.55, label = "mean", size = 3.5, hjust = 1.1, colour = 'red') +
  geom_vline(aes(xintercept = colorado_median), show_guide = TRUE, linetype = "longdash", size = 0.5, colour='blue') +
  annotate("text", x = colorado_median, y = 0.55, label = "median", size = 3.5, hjust = -.1, colour = 'blue') +
  geom_vline(aes(xintercept = colorado_mode), show_guide = TRUE, linetype = "longdash", size = 0.5, colour=muted('green')) +
  annotate("text", x = colorado_mode, y = 0.52, label = "mode", size = 3.5, hjust = -.1, colour = muted('green')) +
  geom_density(from=1, to=9 , adjust = smooth, size=1.5 ) +
  theme_bw() + 
  ggtitle("Colorado (first in ranking)") + 
  xlab("LabMT Score") +
  ylab("Density")

georgia <- subset(anew_scores, state=='georgia')
georgia_mean <- mean(georgia$anew_score)
georgia_median <- median(georgia$anew_score)
georgia_mode <- mode(georgia$anew_score)
georgia_plot <- ggplot(georgia, aes(x=anew_score)) + 
  geom_histogram(
    aes(y=..density..),
    binwidth=.5,
    colour="black", fill="white"
  ) +
  scale_y_continuous(expand=c(0.001,0), breaks=pretty_breaks(n=10)) +
  expand_limits(y = 0.69) +
  scale_x_continuous(expand=c(0.001,0.001), breaks=pretty_breaks(n=10)) +
  geom_vline(aes(xintercept = georgia_mean), show_guide = TRUE, linetype = "longdash", size = 0.5, colour='red') +
  annotate("text", x = georgia_mean, y = 0.66, label = "mean", size = 3.5, hjust = 1.1, colour = 'red') +
  geom_vline(aes(xintercept = georgia_median), show_guide = TRUE, linetype = "longdash", size = 0.5, colour='blue') +
  annotate("text", x = georgia_median, y = 0.67, label = "median", size = 3.5, hjust = -.1, colour = 'blue') +
  geom_vline(aes(xintercept = georgia_mode), show_guide = TRUE, linetype = "longdash", size = 0.5, colour=muted('green')) +
  annotate("text", x = georgia_mode, y = 0.62, label = "mode", size = 3.5, hjust = -.2, colour = muted('green')) +
  geom_density(from=1, to=9 , adjust = smooth, size=1.5 ) +
  theme_bw() + 
  ggtitle("Georgia (last in ranking)") + 
  xlab("LabMT Score") +
  ylab("Density")

multiplot(texas_plot, colorado_plot, vermont_plot, georgia_plot, cols=2)

png(file="paper/images/tweets_distribution.png",width=800,height=650,res=96)
multiplot(texas_plot, colorado_plot, vermont_plot, georgia_plot, cols=2)
dev.off()