#Plot One Mouse Task Progression
require(zoo)
require(ggplot2)
require(binom)
require(plyr)
require(dplyr)
require(scales)


fin <- read.csv("~/Documents/speechData/6925.csv")
#fin <- read.csv("~/Documents/speechData/6927.csv")
#fin <- read.csv("~/Documents/speechData/6928.csv")

#Filter Data
fin <- fin[(fin$step<=13 & fin$step>=5),]
fin <- fin[!is.na(fin$correct),]

#Rollmean
winsize <- 300
fin.z <- zoo(fin$correct,seq.int(1,nrow(fin)))
fin.z.rm <- rollmean(fin.z,winsize,align="left")
fin.z.ci <- rollapply(fin.z,winsize,FUN = function(zz) binom.confint(sum(zz),winsize,conf.level=0.95,method="exact")[5:6],align="left")

#Adjust by step
fin.step <- fin$step[(winsize/2):(nrow(fin)-(winsize/2))]
fin.z.rm[(fin.step == 7 | fin.step == 8)] <- (fin.z.rm[(fin.step == 7 | fin.step == 8)] + 1)
fin.z.rm[(fin.step == 9 | fin.step == 10)] <- (fin.z.rm[(fin.step == 9 | fin.step == 10)] + 2)
fin.z.rm[(fin.step == 11 | fin.step == 12)] <- (fin.z.rm[(fin.step == 11 | fin.step == 12)] + 3)
fin.z.rm[(fin.step == 13)] <- (fin.z.rm[(fin.step == 13)] + 4)

fin.z.ci[(fin.step == 7 | fin.step == 8),] <- (fin.z.ci[(fin.step == 7 | fin.step == 8),] + 1)
fin.z.ci[(fin.step == 9 | fin.step == 10),] <- (fin.z.ci[(fin.step == 9 | fin.step == 10),] + 2)
fin.z.ci[(fin.step == 11 | fin.step == 12),] <- (fin.z.ci[(fin.step == 11 | fin.step == 12),] + 3)
fin.z.ci[(fin.step == 13),] <- (fin.z.ci[(fin.step == 13),] + 4)

#Plot
stepplot <- ggplot(fin.z.rm,aes(x=seq.int(1,length(fin.z.rm)),y=fin.z.rm)) + 
  scale_x_continuous() + scale_y_continuous(limits=c(0,5)) + 
  geom_ribbon(aes(ymin=lower,ymax=upper),data=fin.z.ci,fill="#96C0CE",alpha=0.7) +
  geom_line() +
  geom_line(aes(y=0),colour="#74828F",size=.75) +
  geom_line(aes(y=1),colour="#74828F",size=.75) +
  geom_line(aes(y=2),colour="#74828F",size=.75) +
  geom_line(aes(y=3),colour="#74828F",size=.75) +
  geom_line(aes(y=4),colour="#74828F",size=.75) +
  geom_line(aes(y=5),colour="#74828F",size=.75) +
  geom_line(aes(y=0.5),colour="#C25B56",size=.5,linetype=2) + 
  geom_line(aes(y=1.5),colour="#C25B56",size=.5,linetype=2) + 
  geom_line(aes(y=2.5),colour="#C25B56",size=.5,linetype=2) + 
  geom_line(aes(y=3.5),colour="#C25B56",size=.5,linetype=2) + 
  geom_line(aes(y=4.5),colour="#C25B56",size=.5,linetype=2) + 
  theme(panel.background = element_blank(), 
        panel.grid.major = element_blank(),
        panel.grid.major = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        axis.ticks = element_blank())
  #+ labs(x="# Trials")
stepplot

ggsave("~/Documents/speechPlots/6925_levelplot.svg",plot=stepplot,device="svg",width=8,height=8,units="in")

################################################################
################################################################
# Generalization Barchart
spfiles <- c("~/Documents/speechData/6924.csv","~/Documents/speechData/6925.csv","~/Documents/speechData/6926.csv","~/Documents/speechData/6927.csv","~/Documents/speechData/6928.csv")
#spfiles <- c("~/Documents/speechData/6925.csv","~/Documents/speechData/6927.csv","~/Documents/speechData/6928.csv")


#Make dataframe
gendat <- data.frame(setNames(replicate(7,numeric(0),simplify = F),c("mouse","consonant","speaker","vowel","token","correct","gentype")))

for (f in spfiles){
  sp <- read.csv(f)
  sp.gens <- subset(sp,(step==15|step==13|step==12) & (!is.na(correct)),select=c("consonant","speaker","vowel","token","correct","gentype","step","session"))
  minsesh <- max(unique(sp.gens$session))-5
  sp.gens <- subset(sp.gens,session>=minsesh,select=c("consonant","speaker","vowel","token","correct","gentype","step"))
  #prevent overlapping gentypes
  sp.gens[sp.gens$speaker==1 & (sp.gens$vowel==1|sp.gens$vowel==2) & (sp.gens$token==1|sp.gens$token==2),]$gentype <- 1
  sp.gens[sp.gens$speaker==2 & (sp.gens$vowel==1|sp.gens$vowel==2) & sp.gens$token==1,]$gentype <- 1
  #fix lvl 13ers not having gentype
  if (nrow(sp.gens[sp.gens$step==13,])>0){
  sp.gens[sp.gens$step==13,]$gentype <- 1
  }
  if (nrow(sp.gens[sp.gens$step==12,])>0){
    sp.gens[sp.gens$step==12,]$gentype <- 1
  }
  sp.gens$mouse <- substr(f,24,27)
  gendat <- rbind(gendat,sp.gens)
}

#Summarize & reshape data
gendat.type <- ddply(gendat,.(gentype),summarize, meancx = mean(correct),cilo = binom.confint(sum(correct),length(correct),conf.level=0.95,method="exact")[[5]],cihi = binom.confint(sum(correct),length(correct),conf.level=0.95,method="exact")[[6]])
gendat.mouse <- ddply(gendat,.(mouse,gentype),summarize, meancx = mean(correct),cilo = binom.confint(sum(correct),length(correct),conf.level=0.95,method="exact")[[5]],cihi = binom.confint(sum(correct),length(correct),conf.level=0.95,method="exact")[[6]])

#plot lines
limits <- aes(ymax=cihi,ymin=cilo,fill=as.factor(mouse),alpha=0.1)
gen.lines <- ggplot(gendat.mouse,aes(gentype,meancx,split=as.factor(mouse))) +
  geom_ribbon(limits) +
  geom_line() +
  geom_line(aes(y=0.5),colour="#C25B56",size=.5,linetype=2) + 
  xlab("Generalization Type") +
  theme(panel.background = element_blank(), 
        panel.grid.major = element_blank(),
        panel.grid.major = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_text(size=rel(1.5)),
        axis.title.x = element_text(size=rel(1)),        
        axis.text.x = element_text(size=rel(1.5)),
        axis.ticks.length = unit(.4,"lines"),
        legend.position="none") + 
  scale_y_continuous(limits = c(.5,.7),breaks=c(.5,.6,.7),labels=c("50%","60%","70%")) 

ggsave("~/Documents/speechPlots/25_27_28_genlines.svg",plot=gen.lines,device="svg",width=8,height=4,units="in")

#plot bars
limits <- aes(ymax=cihi,ymin=cilo)
gen.bartype <- ggplot(gendat.type,aes(gentype,meancx,fill=as.factor(gentype))) + 
  geom_bar(position="dodge",stat="identity") +
  geom_errorbar(limits,position="dodge",width=0.25,size=1) + 
  scale_y_continuous(limits = c(.5,.7),breaks=c(.5,.6,.7),labels=c("50%","60%","70%"),oob = rescale_none) +
  xlab("Generalization Type") + 
  theme(panel.background = element_blank(), 
        panel.grid.major = element_blank(),
        panel.grid.major = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_text(size=rel(3)),
        axis.title.x = element_blank(),        
        axis.text.x = element_blank(),
        axis.ticks = element_blank(),
        legend.position="none")
gen.bartype

ggsave("~/Documents/speechPlots/25_27_28_genbartype.svg",plot=gen.bartype,device="svg",width=4,height=3,units="in")
ggsave("~/Documents/speechPlots/25_27_28_genbartype.png",plot=gen.bartype,device="png",width=4,height=3,units="in")

#plot bars split by mouse
limits <- aes(ymax=cihi,ymin=cilo)
dodge <- position_dodge(width=.9)
gen.barmouse <- ggplot(gendat.mouse,aes(gentype,meancx,fill=as.factor(mouse))) + 
  geom_bar(position="dodge",stat="identity") +
  geom_errorbar(limits,position=dodge,width=0.25,size=0.25) + 
  scale_y_continuous(limits = c(.5,.7),breaks=c(.5,.6,.7),labels=c("50%","60%","70%"),oob = rescale_none) +
  xlab("Generalization Type") + 
  theme(panel.background = element_blank(), 
        panel.grid.major = element_blank(),
        panel.grid.major = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_text(size=rel(1.5)),
        axis.title.x = element_text(size=rel(1.5)),        
        axis.text.x = element_text(size=rel(1.5)),
        legend.position="none")
gen.barmouse

ggsave("~/Documents/speechPlots/25_27_28_genbarmouse.svg",plot=gen.barmouse,device="svg",width=8,height=4,units="in")











#####################


#############################################
#Spikelist
#spikenums.csv comes from "getnspikes.m" in MATLAB
spikes <- read.csv('~/Documents/ephysData/spikenums.csv')
names(spikes) <- c("date","session","filenum","channel","cluster","photype","spikenum")

spikeplot <- ggplot(arrange(spikes,photype),aes(y=spikenum,x=interaction(date,session,channel,cluster),fill=as.factor(photype))) + 
  geom_bar(position = "fill",stat="identity") + 
  coord_flip() + 
  theme(panel.background = element_blank(), 
        panel.grid.major = element_blank(),
        panel.grid.major = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(), 
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks = element_blank(),
        legend.position="none")
spikeplot

ggsave("~/Documents/speechPlots/spikeplot.svg",plot=spikeplot,device="svg",width=8,height=10,units="in")
ggsave("~/Documents/speechPlots/spikeplot.png",plot=spikeplot,device="png",width=2,height=2.5,units="in")
ggsave("~/Documents/speechPlots/spikeplot_smaller.png",plot=spikeplot,device="png",width=1,height=1.25,units="in")
ggsave("~/Documents/speechPlots/spikeplot_narrow.png",plot=spikeplot,device="png",width=1,height=2.5,units="in")
ggsave("~/Documents/speechPlots/spikeplot_narrower.png",plot=spikeplot,device="png",width=1,height=5,units="in")

