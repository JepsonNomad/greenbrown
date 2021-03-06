\name{TrendGradient}
\alias{TrendGradient}
\title{Calculate temporal trends along a spatial gradient}
\description{This function extracts along a spatial gradient (e.g. along latitude) time series from a raster brick and computes for each position a temporal trend.}
\usage{TrendGradient(r, start = c(1982, 1), freq = 12, gradient.r = NULL, 
    gradient.brks = NULL, funSpatial = "mean", cor.area = FALSE, 
    scalar = 1, method = c("AAT", "STM", "SeasonalAdjusted", 
        "RQ"), mosum.pval = 0.05, h = 0.15, breaks = 0, funAnnual = mean, 
    funSeasonalCycle = MeanSeasonalCycle, percent = FALSE)}
\arguments{
  \item{r}{multi-layer raster object of class \code{\link[raster]{brick}}}
  \item{start}{beginning of the time series (i.e. the time of the first observation). The default is c(1982, 1), i.e. January 1982 which is the usual start date to compute trends on long-term series of satellite observations of NDVI. See \code{\link[stats]{ts}} for further examples.}
  \item{freq}{The frequency of observations. The default is 12 for monthly observations. Use 24 for bi-monthly observations, 365 for daily observations or 1 for annual observations. See \code{\link{ts}} for further examples.}
  \item{gradient.r}{raster layer with the variable that has a spatial gradient. If NULL (default) a gradient along latitude will be used. Alternatively, one could provide here for example a raster layer with a gradient along longitude for longitudinal gradients of trends or a raster layer with mean annual temperatures to compute trends along a temperature gradient. }
  \item{gradient.brks}{breaks for the gradient. These breaks define the class intervals for which time series will be extracted and trends computed. If NULL (default) 15 class breaks between the minimum and maximum values of the gradient will be used.}
  \item{funSpatial}{function that should be used for spatial aggregation of grid cells that belong to the same interval. }
  \item{cor.area}{If TRUE grid cell values are multiplied by grid cell area to correct for area.}
  \item{scalar}{Multiplier to be applied to time series (e.g. for unit conversions).}
  \item{method}{method to be used for trend calculation with the following options: 
\itemize{
\item{ \code{AAT} (default) calculates trends on annual aggregated time series (see \code{\link{TrendAAT}} for details). This method will be automatically choosen if the time series has a frequency of 1 (e.g. in case of annual time steps). If the time series has a frequency > 1, the time series will be aggregated to annual time steps using the mean. }
\item{ \code{STM} fits harmonics to the seasonal time series to model the seasonal cycle and to calculate trends based on a multiple linear regression (see \code{\link{TrendSTM}} for details). }
\item{ \code{SeasonalAdjusted} removes first the seasonal cycle from the time series and calculates the trend on the reaminder series (see \code{\link{TrendSeasonalAdjusted}} for details). }
}}
  \item{mosum.pval}{Maximum p-value for the OLS-MOSUM test in order to search for breakpoints. If p = 0.05, breakpoints will be only searched in the time series trend component if the OLS-MOSUM test indicates a significant structural change in the time series. If p = 1 breakpoints will be always searched regardless if there is a significant structural change in the time series or not. See \code{\link[strucchange]{sctest}} for details.	}
  \item{h}{minimal segment size either given as fraction relative to the sample size or as an integer giving the minimal number of observations in each segment. See \code{\link[strucchange]{breakpoints}} for details.}
  \item{breaks}{maximal number of breaks to be calculated (integer number). By default the maximal number allowed by h is used. See \code{\link[strucchange]{breakpoints}} for details.}
  \item{funAnnual}{function to aggregate time series to annual values if \code{AAT} is selected as method. The default function is the mean (i.e. trend calculated on mean annual time series). See \code{\link{TrendAAT}} for other examples}
  \item{funSeasonalCycle}{a function to estimate the seasonal cycle of the time series if \code{SeasonalAdjusted} is selected as method. A own function can be defined to estimate the seasonal cycle which has to return the seasonal cycle as a time series of class \code{\link{ts}}. Currently two approaches are part of this package:
\itemize{ 
\item{ \code{\link{MeanSeasonalCycle}} is the default which computes the mean seasonal cycle. }
\item{ \code{\link{SSASeasonalCycle}} detects a modulated seasonal cycle based on Singular Spectrum Analysis. }
}}
  \item{percent}{return trend as percentage change}
}
\details{The function returns a list of class 'TrendGradient' }
\value{The function returns a data.frame of class 'TrendGradient'.}

\author{Matthias Forkel <matthias.forkel@geo.tuwien.ac.at> [aut, cre]}



\seealso{\code{\link{Trend}}, \code{\link{TrendRaster}}}
\examples{
# load a multi-temporal raster dataset of Normalized Difference Vegetation Index
data(ndvimap)
plot(ndvimap, 8)

# compute a latitudinal gradient of trends (by default the method 'AAT' is used):
gradient <- TrendGradient(ndvimap, start=c(1982, 1), freq=12)
gradient
plot(gradient) 
# shown is the trend at each latitudinal band, the area represents the 95\% 
# confidence interval of the trend (computed with function TrendUncertainty), 
# symbols indicate the p-value of the trend at each latitude

plot(gradient, type="yx") # the gradient can be also plotted in reversed order

# latitudinal gradient with different number of intervals:
gradient <- TrendGradient(ndvimap, start=c(1982, 1), freq=12,
   gradient.brks=seq(66, 69, length=5))
plot(gradient) 

# example for a longitudinal gradient:
gradient.r <- raster(ndvimap, 1) # create a raster layer with longitudes:
gradient.r[] <- xFromCell(gradient.r, 1:ncell(gradient.r)) 
plot(gradient.r)
gradient <- TrendGradient(ndvimap, start=c(1982, 1), freq=12, 
   gradient.r=gradient.r)
plot(gradient, xlab="Longitude (E)") 

}
