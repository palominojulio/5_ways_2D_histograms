# 5 Ways to Do 2-D Histograms in R
# (Plus 1 Bonus Figure)
#
# Myles Harrison
# http://www.everydayanalytics.ca

# Color housekeeping
library(RColorBrewer)
rf <- colorRampPalette(rev(brewer.pal(11,'Spectral')))
r <- rf(32)

# Create normally distributed data for plotting
x <- rnorm(mean=1.5, 5000)
y <- rnorm(mean=1.6, 5000)
df <- data.frame(x,y)

# Plot
plot(df, pch=16, col='black', cex=0.5)

##### OPTION 1: hexbin from package 'hexbin' #######
library(hexbin)
# Create hexbin object and plot
h <- hexbin(df)
plot(h)
plot(h, colramp=rf)

# hexbinplot function allows greater flexibility
hexbinplot(y~x, data=df, colramp=rf)

# Setting max and mins
hexbinplot(y~x, data=df, colramp=rf, mincnt=2, maxcnt=60)

# Scaling of legend - must provide both trans and inv functions
hexbinplot(y~x, data=df, colramp=rf, trans=log, inv=exp)

##### OPTION 2: hist2d from package 'gplots' #######
library(gplots)

# Default call
h2 <- hist2d(df)

# Coarser binsizing and add colouring
h2 <- hist2d(df, nbins=25, col=r)

# Scaling with log as before
h2 <- hist2d(df, nbins=25, col=r, FUN=function(x) log(length(x)))

##### OPTION 3: stat_bin2d from package 'ggplot' #######
library(ggplot2)

# Default call (as object)
p <- ggplot(df, aes(x,y))
h3 <- p + stat_bin2d()
h3

# Default call (using qplot)
qplot(x,y,data=df, geom='bin2d')

# Add colouring and change bins
h3 <- p + stat_bin2d(bins=25) + scale_fill_gradientn(colours=r)
h3

# Log scaling
h3 <- p + stat_bin2d(bins=25) + scale_fill_gradientn(colours=r, trans="log")
h3

##### OPTION 4: kde2d from package 'MASS' #######
# Not a true heatmap as interpolated (kernel density estimation)
library(MASS)

# Default call 
k <- kde2d(df$x, df$y)
image(k, col=r)

# Adjust binning (interpolate - can be computationally intensive for large datasets)
k <- kde2d(df$x, df$y, n=200)
image(k, col=r)

##### OPTION 5: The Hard Way (DIY) #######
# http://stackoverflow.com/questions/18089752/r-generate-2d-histogram-from-raw-data

nbins <- 25
x.bin <- seq(floor(min(df[,1])), ceiling(max(df[,1])), length=nbins)
y.bin <- seq(floor(min(df[,2])), ceiling(max(df[,2])), length=nbins)

freq <-  as.data.frame(table(findInterval(df[,1], x.bin),findInterval(df[,2], y.bin)))
freq[,1] <- as.numeric(freq[,1])
freq[,2] <- as.numeric(freq[,2])

freq2D <- diag(nbins)*0
freq2D[cbind(freq[,1], freq[,2])] <- freq[,3]

# Normal
image(x.bin, y.bin, freq2D, col=r)

# Log
image(x.bin, y.bin, log(freq2D), col=r)


##### Addendum: 2D Histogram + 1D on sides (from Computational ActSci w R) #######
#http://books.google.ca/books?id=YWcLBAAAQBAJ&pg=PA60&lpg=PA60&dq=kde2d+log&source=bl&ots=7AB-RAoMqY&sig=gFaHSoQCoGMXrR9BTaLOdCs198U&hl=en&sa=X&ei=8mQDVPqtMsi4ggSRnILQDw&redir_esc=y#v=onepage&q=kde2d%20log&f=false

h1 <- hist(df$x, breaks=25, plot=F)
h2 <- hist(df$y, breaks=25, plot=F)
top <- max(h1$counts, h2$counts)
k <- kde2d(df$x, df$y, n=25)

# margins
oldpar <- par()
par(mar=c(3,3,1,1))
layout(matrix(c(2,0,1,3),2,2,byrow=T),c(3,1), c(1,3))
image(k, col=r) #plot the image
par(mar=c(0,2,1,0))
barplot(h1$counts, axes=F, ylim=c(0, top), space=0, col='red')
par(mar=c(2,0,0.5,1))
barplot(h2$counts, axes=F, xlim=c(0, top), space=0, col='red', horiz=T)
