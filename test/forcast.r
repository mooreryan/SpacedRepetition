dat <- read.csv("forcast.txt", header=F)
years=3
xmax=365*years
ymax=max(dat$V2)

pdf("forcast.pdf", height=5, width=10)
plot(dat$V1, dat$V2, ylim=c(0,ymax), type="l", lwd=3, xaxt="n", xlim=c(0,xmax))
axis(1, at=round(seq(from=0,to=xmax,length.out=25)))
dev.off()
