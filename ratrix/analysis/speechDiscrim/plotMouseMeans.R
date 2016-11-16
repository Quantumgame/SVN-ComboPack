library(ggplot2)
library(reshape)

sm <- read.csv('~/Dropbox/Lab Self/inFormants/Behavior Data/sessionMeans.csv')
sm$numtrials = seq(1,nrow(sm),1)

smb <- melt(sm,id.vars = )
ggplot(data=sm, aes(x=))