####################################
# Practical Exam Climate

# packages
library(ggplot2)
library(reshape)
library(reshape2)
library(gdata)
library(rworldmap)
library(YaleToolkit)
library(plyr)
library(mapproj)
library(animation)

# set file directory
setwd("~/Dropbox/case_studies/climate/")
# load the data
load("~/Dropbox/case_studies/climate/code/unadjust_grid0.RData")
load("~/Dropbox/case_studies/climate/code/unadjust_grid1.RData")
load("~/Dropbox/case_studies/climate/code/unadjust_grid2.RData")

# functions to make the sparkline plots

prep.spark <- function(data.set, year.range=1980:2000,
                       percent.plot=0.75){
  library(plyr)
  # get the min, max, mean for each year
  mydata <- ddply(eval(data.set), 
              .(year, grid), summarise,
              t.max = max(temp, na.rm = T),
              t.min = min(temp, na.rm = T),
              t.mean = mean(temp, na.rm = T), 
              t.sd = sd(temp, na.rm = T),
              elev = mean(elev, na.rm = T),
              scount = mean(scount, na.rm = T))
  # make the grid
  x <- seq(-180, -54, 4)
  y <- seq(24, 90, 4)
  # grid numbers
  ig <- matrix(1:(length(y)*length(x)), length(y), length(x), byrow = TRUE)
  rownames(ig) <- y     
  colnames(ig) <- x
  # prepare the data
  mydata <- mydata[!is.na(mydata$grid),]
  mydata <- mydata[order(mydata$grid, mydata$year),]
  gd.y <- vector(mode="list", length=length(x)*length(y))
  max.y <- vector(mode="list", length=length(x)*length(y))
  min.y <- vector(mode="list", length=length(x)*length(y))
  mean.y <- vector(mode="list", length=length(x)*length(y))
  sd.y <- vector(mode="list", length=length(x)*length(y))
  temp.count <- c() # check
  nothings <- rep(NA, length(year.range))
  for (i in 1:(length(x)*length(y))){
    myyear <- data.frame(year = year.range)
    temp <- data.frame(year = mydata$year[mydata$grid==i], 
                       t.max = mydata$t.max[mydata$grid==i],
                       t.min = mydata$t.min[mydata$grid==i],
                       t.mean = mydata$t.mean[mydata$grid==i],
                       t.sd = mydata$t.sd[mydata$grid==i])
    mycount <- nrow(data.frame(temp=mydata$t.mean[mydata$grid==i]))
    m <- data.frame(merge(x = myyear, y = temp, all.x = TRUE))
    if (mycount > percent.plot*length(year.range)){
      m1 <- lm(t.max ~ year, data = m)
      m2 <- lm(t.min ~ year, data = m)
      m3 <- lm(t.mean ~ year, data = m)
      m4 <- lm(t.sd ~ year, data = m)
      max.y[[i]] <- data.frame(fitted = predict(object = m1, newdata = myyear),
                               real = data.frame(m$t.max))
      min.y[[i]] <- data.frame(fitted = predict(object = m2, newdata = myyear),
                               real = data.frame(m$t.min))
      mean.y[[i]] <- data.frame(fitted = predict(object = m3, newdata = myyear),
                                real = data.frame(m$t.mean))
      sd.y[[i]] <- data.frame(fitted = predict(object = m4, newdata = myyear),
                              real = data.frame(m$t.sd))
    } else{
      max.y[[i]] <- data.frame(fitted = nothings, 
                               real = data.frame(m$t.max))
      min.y[[i]] <- data.frame(fitted = nothings, 
                               real = data.frame(m$t.min))
      mean.y[[i]] <- data.frame(fitted = nothings, 
                                real = data.frame(m$t.mean))
      sd.y[[i]] <- data.frame(fitted = nothings, 
                              real = data.frame(m$t.sd))
    }
    temp.count[i] <- mycount
  }
  # elevation
  e.1 <- ddply(mydata, .(grid), summarise, elev = mean(elev))
  e.1 <- na.omit(e.1)
  elev.1 <- matrix(NA, length(y), length(x))
  for (i in 1:nrow(elev.1)) for (j in 1:nrow(elev.1)){
    g.no <- ig[i,j] # grid number
    if (g.no %in% e.1$grid){
      elev.1[i,j] <- e.1$elev[e.1$grid==g.no] 
    } else{
      elev.1[i,j] <- NA
    }
  }
  # locations
  gd.locs <- expand.grid(x = x, y = y)
  return(list(max.y = max.y, min.y = min.y, 
              mean.y = mean.y, sd.y = sd.y, elev = elev.1, 
              gd.locs = gd.locs))
}

# sparkline plot function
my.sparkmap <- function(my.data, my.elev, my.locs, file.name){
  x <- seq(-180, -54, 4)
  y <- seq(24, 90, 4)
  png(paste0("~/Dropbox/case_studies/climate/graphics/",file.name,".png"), width = 14, height = 10, units = "in", res = 150)
  grid.newpage()
  pushViewport(viewport(w = unit(1, "npc")-unit(2, "inches"),
                        h = unit(1, "npc")-unit(2, "inches")))
  v <- viewport(xscale = c(-189-2, -54+2),
                yscale = c(24-2, 90+2))
  pushViewport(v)
  tile.shading <- rep(0, length(x)*length(y))
  for(i in 1:length(y)) {     # Latitudes
    for(j in 1:length(x)) {   # Longitudes
      tile.shading[(i-1)*length(x)+j] <- ifelse(
        !is.na(my.elev[i,j]), gray(1-0.5*
                                     (my.elev[i,j]/
                                        max(my.elev,na.rm = TRUE))),NA)
    }
  }
  # axis
  grid.xaxis(gp=gpar(fontface=2, fontsize=14))
  grid.yaxis(gp=gpar(fontface=2, fontsize=14))
  grid.rect()
  # yscale max
  yscales <- quantile(unlist(my.data), c(0.01, 0.99), na.rm=TRUE)
  # sparkmat
  sparkmat(my.data, locs=my.locs, just='center', w=3.5, h=3.5, ldw=0.45, 
           tile.shading=tile.shading, yscales=yscales, lcol = c(2,4),
           tile.margin = unit(c(0,0,0,0), 'points'), new=FALSE)
  # axis labels
  grid.text("Degrees Latitude", x=unit(-0.75, "inches"), y=0.5, rot=90,
            gp=gpar(fontface=2, fontsize=14))
  grid.text("Degrees Longitude", x=0.5, y=unit(-0.75, "inches"), rot=0,
            gp=gpar(fontface=2, fontsize=14))
  grid.text("Grayscale shading reflects",
            x=unit(1, "npc")+unit(0.6, "inches"), y=0.5, rot=270,
            gp=gpar(fontface=2, fontsize=14))
  grid.text("average elevation above sea level",
            x=unit(1, "npc")+unit(0.3, "inches"), y=0.5, rot=270,
            gp=gpar(fontface=2, fontsize=14))
  # get the coastlines
  data(coastsCoarse)
  foo <- coastsCoarse@lines
  listNA <- list()
  for (i in 1:134){
    c1 <- foo[[i]]@Lines[[1]]@coords[,1] # long
    c2 <- foo[[i]]@Lines[[1]]@coords[,2] #lat
    if (min(c1) < -52){
      listNA[[length(listNA)+1]] <- foo[[i]]@Lines[[1]]@coords
    } else{
      listNA <- listNA
    }
  }
  # plot the coastlines
  for (i in 1:length(listNA)){
    mypoints <- data.frame(lon = listNA[[i]][,1], 
                           lat = listNA[[i]][,2])
    mypoints <- mypoints[mypoints$lon > -180 & mypoints$lon < -52 &
                           mypoints$lat > 24 & mypoints$lat < 88,]
    if (nrow(mypoints)>0){
      grid.lines(mypoints$lon, mypoints$lat, default.units = 'native', 
                 gp = gpar(col = "black", lwd = 2, alpha = 0.3)) 
    }
  }
  # label the sparklines
  grid.text("Fitted from OLS",
            x=0.25, y=unit(1, "npc")+unit(1.25, "lines"),
            gp=gpar(fontface=2, fontsize=14))
  grid.rect(x=0.25, y=unit(1, "npc") + unit(0.5, "lines"),
            width=0.4, height=unit(0.05, "inches"), gp=gpar(col=2, fill=2))
  grid.text("Actual",
            x=0.75, y=unit(1, "npc")+unit(1.25, "lines"),
            gp=gpar(fontface=2, fontsize=14))
  grid.rect(x=0.75, y=unit(1, "npc") + unit(0.5, "lines"),
            width=0.4, height=unit(0.05, "inches"), gp=gpar(col=4, fill=4))
  dev.off()
}

# Climate Data: 1950-1979
prepped1 <- prep.spark(data.set = gd.1, year.range = 1950:1979, 
                       percent.plot = 0.75)
my.sparkmap(my.data = prepped1$max.y, my.elev = prepped1$elev, 
            my.locs = prepped1$gd.locs, file.name = "max_1")
my.sparkmap(my.data = prepped1$min.y, my.elev = prepped1$elev, 
            my.locs = prepped1$gd.locs, file.name = "min_1")
my.sparkmap(my.data = prepped1$mean.y, my.elev = prepped1$elev, 
            my.locs = prepped1$gd.locs, file.name = "mean_1")
my.sparkmap(my.data = prepped1$sd.y, my.elev = prepped1$elev, 
            my.locs = prepped1$gd.locs, file.name = "sd_1")

# Climate Data: 1980-2010
prepped2 <- prep.spark(data.set = gd.2, year.range = 1980:2010, 
                       percent.plot = 0.75)
my.sparkmap(my.data = prepped2$max.y, my.elev = prepped2$elev, 
            my.locs = prepped2$gd.locs, file.name = "max_2")
my.sparkmap(my.data = prepped2$min.y, my.elev = prepped2$elev, 
            my.locs = prepped2$gd.locs, file.name = "min_2")
my.sparkmap(my.data = prepped2$mean.y, my.elev = prepped2$elev, 
            my.locs = prepped2$gd.locs, file.name = "mean_2")
my.sparkmap(my.data = prepped2$sd.y, my.elev = prepped2$elev, 
            my.locs = prepped2$gd.locs, file.name = "sd_2")

# Against a baseline

baseline.prep <- function(baseline.dat, current.dat){
  baseline <- ddply(eval(baseline.dat), 
                    .(grid, month), summarise,
                    mean.mo = weighted.mean(x = temp, 
                                            w = scount/sum(scount), 
                                            na.rm = TRUE))
  a.d <- merge(x = eval(current.dat), y = baseline, all.x = TRUE)
  a.d$diff <- a.d$temp-a.d$mean.mo
  # Heatmaps
  # make the grid
  x <- seq(-180, -54, 4)
  y <- seq(24, 90, 4)
  # grid numbers
  ig <- matrix(1:(length(y)*length(x)), length(y), length(x), byrow = TRUE)
  rownames(ig) <- y     
  colnames(ig) <- x
  a.d$grid <- as.numeric(a.d$grid)
  a.d$lon <- rep(NA, nrow(a.d))
  a.d$lat <- rep(NA, nrow(a.d))
  for (i in 1:max(ig)){
    print(i)
    myindex <- which(ig==i, arr.ind=TRUE)
    print(myindex)
    a.d$lon[a.d$grid==i] <- x[myindex[2]]
    a.d$lat[a.d$grid==i] <- y[myindex[1]]
  }
  return(a.d)
}

a.1 <- baseline.prep(baseline.dat = gd.0, current.dat = gd.1)
a.2 <- baseline.prep(baseline.dat = gd.1, current.dat = gd.2)
a.2b <- baseline.prep(baseline.dat = gd.0, current.dat = gd.2)


gif.maker <- function(month, dataset, file.name, gg.name){
  m.lab <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
             "Aug", "Sep", "Oct", "Nov", "Dec")
  a.d <- dataset
  saveGIF({
    for (i in unique(a.d$year)[order(unique(a.d$year))]) 
      for (j in unique(a.d$month)[month]){
        mp <- ggplot() + geom_tile(data = a.d[a.d$year==i & a.d$month==j,], 
                                   aes(x = lon, y = lat, fill = diff), 
                                   colour = "white") + 
          scale_fill_gradient2(low = "blue", mid = "white", high = "red",
                               name = gg.name,
                               limits=c(-8, 8)) +
          theme_bw() + ylab("Latitude") + xlab("Longitude") +
          xlim(-180, -50) + ylim(20, 90) +
          theme(legend.position="bottom") + 
          ggtitle(paste0("Year: ",i,"     ","Month: ",m.lab[j]))
        final.map <- mp + mapWorld
        print(final.map)
      }
  }, interval = 1, movie.name = paste0(file.name,month,".gif"), 
  ani.width = 800, ani.height = 600)
}

# 1950-1980 GIFs
for (i in 1:12){gif.maker(month = i, dataset = a.1, 
                          file.name = "ana_1_", 
        gg.name = "Difference in Degrees C from 1920-1950 Baseline")}
# 1950-1980 GIFs
for (i in 1:12){gif.maker(month = i, dataset = a.2, 
                          file.name = "ana_2_", 
            gg.name = "Difference in Degrees C from 1950-1980 Baseline")}



# "Difference in Degrees C from 1950-1980 Baseline"
# visualizing the anomoly
trend.plot <- function(data.set, gg.title, file.name){
  a.d <- eval(data.set)
  a.ds <- ddply(a.d, .(month, year), summarise,
                diff = weighted.mean(x = diff, 
                                     w = scount/sum(scount), na.rm = TRUE))
  
  foo <- ifelse(a.ds$month>9, paste0(a.ds$year,"-",a.ds$month,"-01"),
                paste0(a.ds$year,"-0",a.ds$month,"-01"))
  a.ds$monthyear <- as.Date(foo, "%Y-%m-%d")
  ggplot() + geom_linerange(data = a.ds, 
                            aes(x = monthyear, ymin = 0,
                                ymax = diff, y = diff,
                                colour = ifelse(diff < 0, "darkblue", "red")), 
                            size=1, alpha=0.5) + theme_bw() +
    theme(legend.position="none") + 
    scale_y_continuous(breaks=-5:5) +
    scale_colour_manual(values = c("blue","red")) +
    geom_hline(yintercept=0, type="longdash") +
    stat_smooth(data = a.ds, 
                aes(x = monthyear, y = diff), color = "black") +
    xlab("Month-Year") + ylab(gg.title)
  ggsave(filename = file.name, width = 7, height=5, dpi = 150)
}

trend.plot(data.set = a.1, 
           file.name = "~/Dropbox/case_studies/climate/graphics/main_plot_1.png",
            gg.title = "Difference in Degrees C from 1920-1950 Baseline")
trend.plot(data.set = a.2, 
           file.name = "~/Dropbox/case_studies/climate/graphics/main_plot_2.png",
           gg.title = "Difference in Degrees C from 1950-1980 Baseline")
trend.plot(data.set = a.2b, 
           file.name = "~/Dropbox/case_studies/climate/graphics/main_plot_2b.png",
           gg.title = "Difference in Degrees C from 1920-1950 Baseline")


m1.f <- lm(formula = temp ~ year + I(factor(month)) + I(factor(grid)), data = a.1)
summary(m1.f)
m2.f <- lm(formula = diff ~ year + I(factor(month)) + I(factor(grid)), data = a.2)
summary(m2.f)

# fixed effects: 1950-1980
fixed.1 <- data.frame(grid = unique(a.1$grid), 
                      annual = rep(NA, length(unique(a.1$grid))))
for (i in 1:nrow(fixed.1)){
  tryCatch({
    print(unique(a.1$grid)[i])
    small <- a.1[a.1$grid==unique(a.1$grid)[i],]
    small <- small[!is.na(small$grid),]
    if (nrow(small)>50){
      m2.f <- lm(formula = diff ~ year + I(factor(month)), 
                 data = small)
      fixed.1$annual[i] <- m2.f$coef[2] 
    } else{
      fixed.1$annual[i] <- NA
    }
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}

eg.1 <- ddply(a.1, .(grid), summarise,
              lon = mean(lon, na.rm = TRUE),
              lat = mean(lat, na.rm = TRUE))
eg.1 <- merge(x = eg.1, y = fixed.1)
my.lim <- c(min(eg.1$annual, na.rm = TRUE), 
            max(eg.1$annual, na.rm = TRUE))
gg.name <- "Estimated Annual Increase in Temperature (Degrees C)"
eg.1$annual.p <- eg.1$annual
eg.1$annual.p[eg.1$annual < -0.2] <- -0.2
mp <- ggplot() + geom_tile(data = eg.1, 
                           aes(x = lon, y = lat, fill = annual.p), 
                           colour = "white") + 
  scale_fill_gradient2(low = "blue", mid = "white", high = "red",
                       name = gg.name, breaks = c(-0.1, 0, 0.1),
                       limits=c(-0.2, 0.2), space="Lab") +
  theme_bw() + ylab("Latitude") + xlab("Longitude") +
  xlim(-180, -50) + ylim(20, 90) +
  theme(legend.position="bottom") +
  ggtitle("Years: 1950-1980")+
  geom_text(data = eg.1, 
            aes(x = lon, y = lat, label = round(annual, 3)), size=2) + 
  final.map <- mp + mapWorld
print(final.map)
ggsave(filename = "grid_effects_1.png", width = 10, height=7, dpi = 300)

# fixed effects: 1980-2010
fixed.2 <- data.frame(grid = unique(a.2$grid), 
                      annual = rep(NA, length(unique(a.2$grid))))
for (i in 1:nrow(fixed.2)){
  tryCatch({
    print(unique(a.2$grid)[i])
    small <- a.2[a.2$grid==unique(a.2$grid)[i],]
    small <- small[!is.na(small$grid),]
    if (nrow(small)>50){
      m2.f <- lm(formula = diff ~ year + I(factor(month)), 
                 data = small)
      fixed.2$annual[i] <- m2.f$coef[2] 
    } else{
      fixed.2$annual[i] <- NA
    }
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}

eg.2 <- ddply(a.2, .(grid), summarise,
      lon = mean(lon, na.rm = TRUE),
      lat = mean(lat, na.rm = TRUE))
eg.2 <- merge(x = eg.2, y = fixed.2)
my.lim <- c(min(eg.2$annual, na.rm = TRUE), 
            max(eg.2$annual, na.rm = TRUE))
gg.name <- "Estimated Annual Increase in Temperature (Degrees C)"
eg.2$annual.p <- eg.2$annual
eg.2$annual.p[eg.2$annual < -0.2] <- -0.2
mp <- ggplot() + geom_tile(data = eg.2, 
                           aes(x = lon, y = lat, fill = annual.p), 
                           colour = "white") + 
  scale_fill_gradient2(low = "blue", mid = "white", high = "red",
                       name = gg.name, breaks = c(-0.1, 0, 0.1),
                       limits=c(-0.2, 0.2), space="Lab") +
  theme_bw() + ylab("Latitude") + xlab("Longitude") +
  xlim(-180, -50) + ylim(20, 90) +
  theme(legend.position="bottom") +
  ggtitle("Years: 1980-2010")+
  geom_text(data = eg.2, 
           aes(x = lon, y = lat, label = round(annual, 3)), size=2)
final.map <- mp + mapWorld
print(final.map)
ggsave(filename = "grid_effects_2.png", width = 10, height=7, dpi = 300)



a.0 <- ddply(gd.0, .(month, year), summarise,
             temp = weighted.mean(x = temp, 
                                  w = scount/sum(scount), na.rm = TRUE))
foo <- ifelse(a.0$month>9, paste0(a.0$year,"-",a.0$month,"-01"),
              paste0(a.0$year,"-0",a.0$month,"-01"))
a.0$monthyear <- as.Date(foo, "%Y-%m-%d")

ggplot(data = a.0, aes(x = monthyear, y = temp)) + 
  geom_line(size=1, alpha=0.5) + theme_bw() + stat_smooth()

