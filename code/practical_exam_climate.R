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

# file directory
setwd("~/Dropbox/case_studies/climate/data")

# import data: time series
ad <- read.fwf(file = "ghcnm.tavg.v3.2.0.20121113.qca.dat", 
               widths = c(11,4,4,rep(c(5,1,1,1),12)),
               na.strings="-9999")
rep.names <- c()
no.2 <- c("01", "02", "03", "04", "05", "06", "07", "08", "09",
          "10", "11", "12")
for (i in 1:12){
  rep.names <- c(rep.names, paste0("value_",no.2[i]), 
                 paste0("dmflag_",no.2[i]), paste0("qcflag_",no.2[i]), 
                 paste0("dsflag_",no.2[i]))
}
names(ad) <- c("id", "year", "element", rep.names)
summary(ad$element)
# get rid of years I don't need
ad <- ad[ad$year>1920,]
# import data: location
lo <- read.xls(xls = "ghcnm.tavg.v3.2.0.20121113.qcu.xls", 
               sheet = 1, header = FALSE)
names(lo) <- c("id", "lat", "lon", "stnelev",
               "name", "grelev", "popcls",
               "popsiz", "topo", "stveg",
               "stloc", "ocndis", "airstn",
               "towndis", "grveg", "popcss")
summary(lo$lat) # check the 
summary(lo$lon)
lo$stnelev[lo$stnelev==-999.00] <- NA
# keep the ones within U.S. and Canada
lo$keep <- ifelse(lo$lat > 24.00 & lo$lon < -53.00, TRUE, FALSE)
# plot where the stations are located
newmap <- getMap(resolution = "low")
plot(newmap, xlim = c(-180, -53), ylim = c(24,90), asp = 1)
points(lo$lon, lo$lat, col = "red", cex = 0.3, pch = 20)
# get the ids for stations we are keeping
st.keep <- lo$id[lo$keep]
lo <- lo[lo$keep,]

# make the grid
x <- seq(-180, -54, 4)
y <- seq(24, 90, 4)

# grid numbers
ig <- matrix(1:(length(y)*length(x)), length(y), length(x), byrow = TRUE)
rownames(ig) <- y     
colnames(ig) <- x
# label the grid
lo$grid <- rep(NA, nrow(lo))
for (i in 1:(length(x)-1)) for (j in 1:(length(y)-1)){
  lo$grid <- ifelse(lo$lon >= x[i] & lo$lon < x[i+1] &
                      lo$lat >= y[j] & lo$lat < y[j+1], ig[j,i], lo$grid)
}

# preparation for merge
# in the time series, get rid of the stations we are not keeping
ad$keep <- ad$id %in% st.keep
ad <- ad[ad$keep,]
ad <- reshape(data = ad, varying=rep.names, timevar = "month", idvar = c("id", "year"), direction="long", sep="_", new.row.names = NULL)
rownames(ad) <- 1:nrow(ad)
dat <- merge(x = ad, y = lo, all.x = TRUE, by = "id")
# remove some stuff
rm(ad)
rm(lo)
# years 1950-1979
gd.0 <- ddply(dat[dat$year>=1920 & dat$year<1950,], 
              .(grid, year, month, element), summarise,
              temp = mean(value/100, na.rm = T),
              elev = mean(stnelev, na.rm = T),
              scount = length(unique(id)))
save(gd.0, file = "~/Dropbox/case_studies/climate/code/unadjust_grid0.RData")
rm(gd.0)
gd.1 <- ddply(dat[dat$year>=1950 & dat$year<1980,], 
              .(grid, year, month, element), summarise,
             temp = mean(value/100, na.rm = T),
             elev = mean(stnelev, na.rm = T),
             scount = length(unique(id)))
save(gd.1, file = "~/Dropbox/case_studies/climate/code/unadjust_grid1.RData")
rm(gd.1)
# years 1980-2000
gd.2 <- ddply(dat[dat$year>=1980 & dat$year<2011,], 
              .(grid, year, month, element), summarise,
              temp = mean(value/100, na.rm = T),
              elev = mean(stnelev, na.rm = T),
              scount = length(unique(id)))
save(gd.2, file = "~/Dropbox/case_studies/climate/code/unadjust_grid2.RData")
rm(gd.2)
rm(dat)


