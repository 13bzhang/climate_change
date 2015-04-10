# An example with a time series of energy consumption at Yale colleges.
data(YaleEnergy)
y <- YaleEnergy

# Need list of 12 data frames, each with one time series.
df.1 <- data.frame(y[y$name==y$name[1],"ELSQFT"])
z <- list(data.frame(rep(NA, 85)),
          data.frame(y[y$name==y$name[2],"ELSQFT"]),
          data.frame(y[y$name==y$name[3],"ELSQFT"]),
          data.frame(y[y$name==y$name[4],"ELSQFT"]),
          data.frame(y[y$name==y$name[5],"ELSQFT"]),
          data.frame(y[y$name==y$name[6],"ELSQFT"]),
          data.frame(y[y$name==y$name[7],"ELSQFT"]),
          data.frame(y[y$name==y$name[8],"ELSQFT"]),
          data.frame(y[y$name==y$name[9],"ELSQFT"]),
          data.frame(y[y$name==y$name[10],"ELSQFT"]),
          data.frame(y[y$name==y$name[11],"ELSQFT"]),
          data.frame(y[y$name==y$name[12],"ELSQFT"]))

sparkmat(z, locs=data.frame(y$lon, y$lat), new=TRUE,
         w=0.002, h=0.0002, just=c("left", "top"))
grid.text(y[1:12,1], unit(y$lon[1:12]+0.001, "native"),
          unit(y$lat[1:12]+0.00003, "native"),
          just=c("center", "bottom"), gp=gpar(cex=0.7))
grid.text("Degrees Longitude", 0.5, unit(-2.5, "lines"))
grid.text("Degrees Latitude", unit(-4.5, "lines"), 0.5, rot=90)
grid.text("Monthly Electrical Consumption (KwH/SqFt)",
          0.5, 0.82, gp=gpar(cex=1, font=2))
grid.text("of Yale Residential Colleges",
          0.5, 0.77, gp=gpar(cex=1, font=2))
grid.text("July 1999 - July 2006",
          0.5, 0.72, gp=gpar(cex=1, font=2))

# An example with pressure and high cloud cover over a regular grid of the
# Americas, provided by NASA ().

runexample <- TRUE
if (runexample) {
  
  data(nasa)
  
  grid.newpage()
  pushViewport(viewport(w = unit(1, "npc")-unit(2, "inches"),
                        h = unit(1, "npc")-unit(2, "inches")))
  v <- viewport(xscale = c(-115, -55),
                yscale = c(-22.5, 37.5))
  pushViewport(v)
  
  y <- vector(mode="list", length=24*24)
  locs <- as.data.frame(matrix(0, 24*24, 2))
  tile.shading <- rep(0, 24*24)
  for(i in 1:24) {     # Latitudes
    for(j in 1:24) {   # Longitudes
      y[[(i-1)*24+j]] <- as.data.frame(t(nasa$data[,,i,j]))
      locs[(i-1)*24+j,] <- c(as.numeric(dimnames(nasa$data)$lon[j]),
                             as.numeric(dimnames(nasa$data)$lat[i]))
      tile.shading[(i-1)*24+j] <- gray( 1-.5*(nasa$elev[i,j]/max(nasa$elev)) )
    }
  }
  
  yscales <- list(quantile(nasa$data["pressure",,,], c(0.01, 0.99), na.rm=TRUE),
                  quantile(nasa$data["cloudhigh",,,], c(0.01, 0.99), na.rm=TRUE))
  
  sparkmat(y, locs=locs, just='center', w=2.5, h=2.5,
           tile.shading=tile.shading, lcol=c(6,3), yscales=yscales,
           tile.margin = unit(c(2,2,2,2), 'points'), new=FALSE)
  
  grid.xaxis(gp=gpar(fontface=2, fontsize=14))
  grid.yaxis(gp=gpar(fontface=2, fontsize=14))
  grid.rect()
  
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
  
  grid.lines(nasa$coast[,1], nasa$coast[,2], default.units = 'native',
             gp = gpar(col = 'black', lwd = 1))
  
  grid.text("Pressure",
            x=0.25, y=unit(1, "npc")+unit(1.25, "lines"),
            gp=gpar(fontface=2, fontsize=14))
  grid.rect(x=0.25, y=unit(1, "npc") + unit(0.5, "lines"),
            width=0.4, height=unit(0.05, "inches"), gp=gpar(col=6, fill=6))
  grid.text("High Cloud",
            x=0.75, y=unit(1, "npc")+unit(1.25, "lines"),
            gp=gpar(fontface=2, fontsize=14))
  grid.rect(x=0.75, y=unit(1, "npc") + unit(0.5, "lines"),
            width=0.4, height=unit(0.05, "inches"), gp=gpar(col=3, fill=3))
}


sparkmat(x = gd.y, locs=gd.locs, just='center', w=2, h=2,
         tile.shading=tile.shading, yscales=yscales,
         tile.margin = unit(c(2,2,2,2), 'points'), new=FALSE)

function (x, locs = NULL, w = NULL, h = NULL, lcol = NULL, yscales = NULL, 
          tile.shading = NULL, tile.margin = unit(c(0, 0, 0, 0), "points"), 
          tile.pars = NULL, just = c("right", "top"), new = TRUE, ...) 
{
  if (new) 
    grid.newpage()
  if (!is.null(x[[1]]) && is.null(yscales)) {
    yscales <- vector(mode = "list", length = length(x[[1]]))
    for (i in 1:length(x)) {
      for (j in 1:length(x[[1]])) {
        yscales[[j]] <- c(min(yscales[[j]][1], min(x[[i]][, 
                                                          j], na.rm = TRUE)), max(yscales[[j]][2], max(x[[i]][, 
                                                                                                              j], na.rm = TRUE)))
      }
    }
  }
  vectorize <- function(x, y) {
    x.v <- rep(x, length(y))
    y.v <- as.numeric(matrix(y, nrow = length(x), ncol = length(y), 
                             byrow = TRUE))
    return(data.frame(x = x.v, y = y.v))
  }
  if (is.null(locs)) {
    mats.down <- floor(sqrt(length(x)))
    mats.across <- ceiling(length(x)/mats.down)
    locs <- vectorize(x = (1:mats.across)/mats.across, y = (mats.down:1)/mats.down)
    locs$x <- unit(locs$x, "npc")
    locs$y <- unit(locs$y, "npc")
    if (is.null(w)) 
      w <- unit(1/mats.across, "npc")
    if (is.null(h)) 
      h <- unit(1/mats.down, "npc")
  }
  else {
    if (new) {
      pushViewport(viewport(x = 0.15, y = 0.1, width = 0.75, 
                            height = 0.75, just = c("left", "bottom"), xscale = range(pretty(locs[, 
                                                                                                  1])), yscale = range(pretty(locs[, 2]))))
      grid.xaxis()
      grid.yaxis()
    }
  }
  if (!is.unit(w)) 
    w <- unit(w, "native")
  if (!is.unit(h)) 
    h <- unit(h, "native")
  for (i in 1:length(x)) {
    if (is.unit(locs[i, 1])) 
      xloc <- locs[i, 1]
    else xloc <- unit(locs[i, 1], "native")
    if (is.unit(locs[i, 2])) 
      yloc <- locs[i, 2]
    else yloc <- unit(locs[i, 2], "native")
    sparklines.viewport <- viewport(x = xloc, y = yloc, just = just, 
                                    width = w, height = h)
    pushViewport(sparklines.viewport)
    if (!is.null(tile.pars)) 
      grid.rect(gp = tile.pars)
    sparklines(x[[i]], new = FALSE, lcol = lcol, yscale = yscales, 
               outer.margin = tile.margin, outer.margin.pars = gpar(fill = tile.shading[i], 
                                                                    col = tile.shading[i]), xaxis = FALSE, yaxis = FALSE)
    popViewport(1)
  }
}

library(gridfun)
data(ONTbound)
width <- 4.5; height <- 2.7
xrange <- range(swf$LONGITUDE)+ width/2*c(-1,1)
yrange <- range(swf$LATITUDE) + height/2*c(-1,1)
vp <- viewport(x=0.5, y=0.5, width=0.8, height=0.8,
               xscale=xrange, yscale=yrange)
pushViewport(vp)
grid.xaxis(); grid.yaxis()
grid.rect(gp=gpar(lty="dashed"))
upViewport()
pushViewport(viewport(x=0.5, y=0.5, width=0.8, height=0.8,
                      xscale=xrange, yscale=yrange, clip="on"))
grid.lines(unit(ONTbound$V1, "native"),
           unit(ONTbound$V2, "native"), gp=gpar(col="purple"))
