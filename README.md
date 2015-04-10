# Climate Change in North America

## Summary
Using average monthly surface temperature data from the National Oceanic and Atmospheric Administration, I analyzed the rate of climate change in the U.S. and Canada for two periods: 1950-1980 and 1980-2010. Using data visualization and regression analysis, I determine that the rate of global warming is faster in the second period than the first -- at about a rate of 0.036 degrees C annually. Furthermore, Western parts of the U.S. and Canada, including Alaska, experience higher rates of warming compared with other regions. 

## Data Source
The data for my analysis comes from the Global Historical Climatology Network Monthly (GHCNM) dataset Version 3. It contains the mean monthly temperature for 7280 weather stations around the world. I used the "adjusted" version of the dataset because the researchers who created the GHCNM dataset have implemented quality control. Because the large size of the dataset, I discretized the dataset into grids of 4 degrees in length and width; I use the mean monthly temperature of stations within each grid as my unit of analysis.  

## Sparkline Visualization

To visualize the data in its most raw form, I constructed sparkline maps. For each grid, I made sparkline maps that show the following:

* maximum monthly temperature for each year
* minimum monthly temperature for each year
* mean monthly temperature for each year
* standard deviation of monthly temperature for each year

For grids that have less than 25 percent monthly data missing, I also display the best linear predictor for each trend mentioned above. 

### Years: 1950-1980

![Max 1](graphics/max_1.png)

![Min 1](graphics/min_1.png) 

![Mean 1](graphics/mean_1.png)

![SD 1](graphics/sd_1.png)

### Years: 1980-2010

![Max 2](graphics/max_2.png)

![Min 2](graphics/min_2.png) 

![Mean 2](graphics/mean_2.png)

![SD 2](graphics/sd_2.png)

## Climate Change Over Time

Next, I attempt to visualize how monthly temperature deviated from a historical baseline over time. For each period, I calculated a historical monthly baseline for each grid using monthly temperature data from the previous 30 years. For instance, this means, I used data from 1920 to 1950 as the baseline for 1950 to 1980 and 1950 to 1980 as the baseline for 1980 to 2010. (Using 1920 to 1950 as a baseline for the second period did not produce significantly different results.) 

In these following animated heatmaps, I display the deviation from the baseline monthly temperature by grid and month across the years. 

### Years: 1950-1980

![1 1](graphics/ani_1_1.gif) 

![1 2](graphics/ani_1_2.gif)

![1 3](graphics/ani_1_3.gif)

![1 4](graphics/ani_1_4.gif)

![1 5](graphics/ani_1_5.gif)

![1 6](graphics/ani_1_6.gif)

![1 7](graphics/ani_1_7.gif)

![1 8](graphics/ani_1_8.gif)

![1 9](graphics/ani_1_9.gif)

![1 10](graphics/ani_1_10.gif)

![1 11](graphics/ani_1_11.gif)

![1 12](graphics/ani_1_12.gif)

### Years: 1980-2010

![2 1](graphics/ana_2_1.gif) 

![2 2](graphics/ana_2_2.gif)

![2 3](graphics/ana_2_3.gif)

![2 4](graphics/ana_2_4.gif)

![2 5](graphics/ana_2_5.gif)

![2 6](graphics/ana_2_6.gif)

![2 7](graphics/ana_2_7.gif)

![2 8](graphics/ana_2_8.gif)

![2 9](graphics/ana_2_9.gif)

![2 10](graphics/ana_2_10.gif)

![2 11](graphics/ana_2_11.gif)

![2 12](graphics/ana_2_12.gif)

## Estimating the Rate of Warming

Finally, I try to estimate the rate of warming across the entire region of interest and for each grid. First, I consider the deviation from the baseline historical temperature as a time series for the entire region. I constructed the following plots:

![Time Series 1](graphics/main_plot_1.png)

![Time Series 2](graphics/main_plot_2.png)

Besides plotting the actual data in each plot, I included the fitted trend line from a loess regression along with its 95 percent confidence interval. In the first period, there does not seem to be much evidence of warming. For most years after 1960, the average monthly temperature was below that of the historical baseline. In the second period, however, the average monthly temperature was above the historical baseline for most months. Furthermore, the rate of warming is increasing, particularly after 1995. 

Using OLS regression with fixed effect for month and grid, I estimate that the annual rate of change for temperature is -0.008 C (SE = 0.002) in the first period and 0.036 C (SE = 0.001) in the second period. While the annual rate of change in temperature is statistically different from 0 in the first period, it remains substantively small. In contrast, the annual rate of change in temperature in the same period is most statistically significant and substantively large. 

Furthermore, I estimate the annual rate of change in temperature for each grid in the two periods as labeled heatmaps. I estimated the annual rate of change for grids that contain more than 50 observations with fixed effects for month.

![Grids 1](graphics/grid_effects_1.png)

![Grids 2](graphics/grid_effects_2.png)

In the first period, the majority of grids show a negative annual change in temperature, with a few exceptions in the Alaska and Western Canada. In the second period, the majority of grids show a positive annual change in temperature. The fastest rates of warming occur in the Western parts of the U.S. and Canada, including Alaska. The Arctic regions of Canada have experienced the most variation in rates of temperature change. 



