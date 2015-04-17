# Climate Change in North America

## Summary
Using average monthly surface temperature data from the National Oceanic and Atmospheric Administration, I analyzed the rate of climate change in the U.S. and Canada for two periods: 1950-1980 and 1980-2010. Using data visualization and regression analysis, I determined that the rate of global warming is faster in the second period than the first -- at about a rate of 0.036 degrees C annually. Furthermore, Western parts of the U.S. and Canada, including Alaska, experience higher rates of warming compared with other regions. 

## Data Source
The data for my analysis comes from the Global Historical Climatology Network Monthly (GHCNM) dataset Version 3. It contains the mean monthly temperature for 7280 weather stations around the world. I used the "adjusted" version of the dataset because the researchers who created the GHCNM dataset have implemented quality control. Because the large size of the dataset, I discretized the dataset into grids of 4 degrees in length and width; I use the mean monthly temperature of stations within each grid as my unit of analysis.  

## Sparkline Visualization

To visualize the data in its most raw form, I constructed sparkline maps that show the monthly anomaly from 1950 to 2010. According to NOAA's monitoring references:

> The term temperature anomaly means a departure from a reference value or long-term average. A positive anomaly indicates that the observed temperature was warmer than the reference value, while a negative anomaly indicates that the observed temperature was cooler than the reference value.

For each grid and month, the reference temperature is the mean temperature for the grid and month for 1920-2010. For each grid, month, and year, I create the anomaly by subtracting the reference temperature from that grid's monthly temperature that year. 

For each grid, I made sparkline maps that show the following:

* maximum anomaly temperature for each year
* minimum anomaly temperature for each year
* mean anomaly temperature for each year

For grids that have less than 25 percent monthly data missing, I also display the best linear predictor for each trend mentioned above. 

### Maximum Anomaly Temperatures: 1950-2010
![Max 1](graphics/max.png)

### Minimum Anomaly Temperatures: 1950-2010
![Min 1](graphics/min.png) 

### Mean Anomaly Temperatures: 1950-2010
![Mean 1](graphics/mean.png)

## Estimating the Rate of Warming

Finally, I try to estimate the rate of warming across the entire region of interest and for each grid. First, I consider the monthly anomaly as a time series for the entire region. I constructed the following plot:

![Time Series 1](graphics/main_plot.png)

Besides plotting the actual data in each plot, I included the fitted trend line from a loess regression along with its 95 percent confidence interval. In the first period, there does not seem to be much evidence of warming. For most years between 1950 and 1979, the average monthly temperature was below that of reference baseline. In the first period, I estimated the annual rate of temperature change to be -0.007 degrees C. In the second period, however, the average monthly temperature was above the historical baseline for most months. Furthermore, after 1980, annual warming appears to follow a linear trend, increasing at a rate of 0.032 degrees C annually.

![Time Series 2](graphics/main_seasons.png)

Furthermore, I constructed the time series by the four seasons. The change in warming trend between the two periods is most visible in the winter and spring months. The change in trend occurred around a decade later, in 1990, for the fall months. 

Using OLS regression with fixed effect for month and grid, I estimate that the annual rate of change for temperature is -0.008 C (SE = 0.002) in the first period and 0.036 C (SE = 0.001) in the second period. While the annual rate of change in temperature is statistically different from 0 in the first period, it remains substantively small. In contrast, the annual rate of change in temperature in the same period is most statistically significant and substantively large. 

Furthermore, I estimate the annual rate of change in temperature for each grid as labeled heatmaps. I estimated the annual rate of change for grids that contain more than 100 observations with fixed effects for month.

![Grids 1](graphics/grid_effects.png)

The fastest rates of annual increase in temperature occur in the Western parts of the U.S. and Canada, including Alaska. The fast rates of warming



