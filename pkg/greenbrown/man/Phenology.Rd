\name{Phenology}
\alias{Phenology}
\title{Calculate phenology metrics in time series}
\description{This function calculates from time series annual metrics of vegetation phenology:
\itemize{ 
\item{ \code{sos} start of season }
\item{ \code{eos} end of season }
\item{ \code{los} length of season }
\item{ \code{pop} position of peak value (maximum) }
\item{ \code{pot} position of trough value (minimum) }
\item{ \code{mgs} mean growing season value }
\item{ \code{peak} peak value (maximum) }
\item{ \code{trough} trough value (minimum) }
\item{ \code{msp} mean spring value }
\item{ \code{mau} mean autumn value }
\item{ \code{rsp} rate of spring greenup (not all methods) }
\item{ \code{rau} rate of autumn senescence rates (not all methods) }
}
The calculation of these metrics is performed in three steps and by using different methods:
\itemize{ 
\item{ Step 1: Filling of permanent (winter) gaps. See \code{\link{FillPermanentGaps}}}
\item{ Step 2: Time series smoothing and interpolation. See \code{\link{TsPP}} }	
\item{ Step 3: Detection of phenology metrics. Phenology metrics are estimated from the gap filled, smoothed and interpolated time series. This can be done by threshold methods (\code{\link{PhenoTrs}}) or by using the derivative of the time series (\code{\link{PhenoDeriv}}). }
\item{ Step 4: Correction of annual DOY (day of year) time series. sos, eos, pop, and pot time series are corrected to not jump between years and ouliers are removed. See (\code{\link{CorrectDOY}}). }
}}
\usage{Phenology(Yt, approach = c("White", "Trs", "Deriv"), min.mean = 0.1, 
    trs = NULL, fpg = FillPermanentGaps, tsgf = "TSGFspline", 
    interpolate = TRUE, min.gapfrac = 0.2, lower = TRUE, fillval = NA, 
    fun = min, method = c("Elmore", "Beck"), check.seasonality = 1:3, 
    backup = NULL, ...)}
\arguments{
  \item{Yt}{univariate time series of class \code{\link{ts}}}
  \item{approach}{Approach to be used to calculate phenology metrics from smoothed time series. 'White' by sclaing annual cycles between 0 and 1 (White et al. 1997, see \code{\link{PhenoTrs}}); 'Trs' for simple thresholds (\code{\link{PhenoTrs}}); 'Deriv' by using the derivative of the smoothed function (\code{\link{PhenoDeriv}}).}
  \item{min.mean}{minimum mean annual value in order to calculate phenology metrics. Use this threshold to suppress the calculation of metrics in grid cells with low average values	}
  \item{trs}{threshold to be used to determine SOS and EOS if method 'Trs' is used. If method 'Trs' is used but trs is NULL than trs will be computed from the long-term mean of Yt.}
  \item{fpg}{Filling of permanent gaps: If NULL, permanent gaps will be not filled, else the function \code{\link{FillPermanentGaps}} will be applied.}
  \item{tsgf}{Temporal smoothing and gap filling: Function to be used for temporal smoothing, gap filling and interpolation of the time series. If NULL, this step will be not applied. Otherwise a function needs to be specified. Exisiting functions that can be applied are \code{\link{TSGFspline}}, \code{\link{TSGFlinear}}, \code{\link{TSGFssa}}, \code{\link{TSGFdoublelog}}, \code{\link{TSGFphenopix}}  }
  \item{interpolate}{Should the smoothed and gap filled time series be interpolated to daily values?}
  \item{min.gapfrac}{How often has an observation to be NA to be considered as a permanent gap? (fraction of time series length) Example: If the month January is 5 times NA in a 10 year time series (= 0.5), then the month January is considered as permanent gap if min.gapfrac = 0.4.	}
  \item{lower}{For filling of permanent gaps: fill lower gaps (TRUE), upper gaps (FALSE) or lower and upper gaps (NULL)}
  \item{fillval}{For filling of permanent gaps: constant fill values for gaps. If NA the fill value will be estimated from the data using fun. }
  \item{fun}{For filling of permanent gaps: function to be used to compute fill values. By default, minimum.}
  \item{method}{If 'tsgf' is TSGFdoublelog: Which kind of double logistic curve should be used to smooth the data? 'Elmore' (Elmore et al. 2012, see \code{\link{FitDoubleLogElmore}}) or 'Beck' (Beck et al. 2006, see \code{\link{FitDoubleLogBeck}}) .}
  \item{check.seasonality}{Which methods in \code{\link{Seasonality}} should indicate TRUE (i.e. time series has seasonality) in order to calculate phenology metrics? 1:3 = all methods should indicate seasonality, Set to NULL in order to not perform seasonality checks.}
  \item{backup}{Which backup algorithm should be used instead of TSGFdoublelog for temporal smoothing and gap filling if the time series has no seasonality? If a time series has no seasonal pattern, the fitting of double logistic functions is not meaningful. In this case another method can be used. Default: NULL (returns NA - no smoothing), other options: "TSGFspline", "TSGFssa", "TSGFlinear"	}
  \item{\dots}{further arguments (currently not used)}
}
\details{This function allows to calculate phenology metrics on time series. This method  can be applied to gridded (raster) data using the function \code{\link{PhenologyRaster}}.}
\value{The function returns a "Phenology" object with the following components
\itemize{ 
\item{ \code{method} Selected method. }
\item{ \code{series} gap-filled, smoothed and daily interpolated time series }
\item{ \code{sos} annual time series of start of season }
\item{ \code{eos} annual time series of end of season }
\item{ \code{los} annual time series of length of season }
\item{ \code{pop} annual time series of position of peak (maximum) }
\item{ \code{pot} annual time series of position of trough (minimum) }
\item{ \code{mgs} annual time series of mean growing season values }
\item{ \code{peak} annual time series of peak value }
\item{ \code{trough} annual time series of trough value }
\item{ \code{msp} annual time series of mean spring value }
\item{ \code{mau} annual time series of mean autumn value }
\item{ \code{rsp} annual time series of spring greenup rates (only for methods 'Deriv' and 'Logistic')}
\item{ \code{rau} annual time series of autumn senescence rates (only for methods 'Deriv' and 'Logistic')}
}}
\references{Beck, P.S.A., C. Atzberger, K.A. Hodga, B. Johansen, A. Skidmore (2006): Improved monitoring of vegetation dynamics at very high latitudes: A new method using MODIS NDVI. - Remote Sensing of Environment 100:321-334. \cr
Elmore, A.J., S.M. Guinn, B.J. Minsley and A.D. Richardson (2012): Landscape controls on the timing of spring, autumn, and growing season length in mid-Atlantic forests. - Global Change Biology 18, 656-674. \cr	
White M.A., P.E. Thornton and S.W. Running (1997): A continental phenology model for monitoring vegetation responses to interannual climatic variability. - Global Biogeochemical Cycles 11, 217-234. }
\author{Matthias Forkel <matthias.forkel@geo.tuwien.ac.at> [aut, cre]}



\seealso{\code{\link{PhenologyRaster}}, \code{\link{TSGFspline}}, \code{\link{TSGFssa}}, \code{\link{TSGFdoublelog}}, \code{\link{FitDoubleLogElmore}}, \code{\link{FitDoubleLogBeck}}}
\examples{
# load a time series of NDVI (normalized difference vegetation index)
data(ndvi)
plot(ndvi)

# introduce some missing values
winter <- (1:length(ndvi))[cycle(ndvi) == 1 | cycle(ndvi) == 2 | cycle(ndvi) == 12]
ndvi[sample(winter, length(winter)*0.5)] <- NA
plot(ndvi)

# spline fit and threshold
spl.trs <- Phenology(ndvi, tsgf="TSGFspline", approach="White") 
spl.trs
plot(spl.trs)	# default plot: start of season, end of season, position of peak
plot(spl.trs, type=c("los")) # length of season

# plot mean spring, growing season, autumn and peak values
plot(spl.trs, type=c("msp", "mgs", "mau", "peak")) 

# gap-filled and smoothed time series that was used to estimate phenology metrics
plot(spl.trs$series, col="red"); lines(ndvi) 


# calculate phenology metrics using different smoothing methods and approaches
#-----------------------------------------------------------------------------

# linear interpolation/running median + threshold
lin.trs <- Phenology(ndvi, tsgf="TSGFlinear", approach="White") 

# linear interpolation/running median + derivative
lin.deriv <- Phenology(ndvi, tsgf="TSGFlinear", approach="Deriv") 

# spline + threshold
spl.trs <- Phenology(ndvi, tsgf="TSGFspline", approach="White") 

# spline + derivative
spl.deriv <- Phenology(ndvi, tsgf="TSGFspline", approach="Deriv") 

# double logistic fit + threshold
beck.trs <- Phenology(ndvi, tsgf="TSGFdoublelog", method="Beck", approach="White") 

# double logistic fit + derivative
beck.deriv <- Phenology(ndvi, tsgf="TSGFdoublelog", method="Beck", approach="Deriv") 

# double logistic fit + threshold
elmore.trs <- Phenology(ndvi, tsgf="TSGFdoublelog", method="Elmore", approach="White") 

# double logistic fit + derivative
elmore.deriv <- Phenology(ndvi, tsgf="TSGFdoublelog", method="Elmore", approach="Deriv") 

# compare results: SOS and EOS
type <- c("sos", "eos")
require(RColorBrewer)
cols <- brewer.pal(10, "Paired")
nms <- c("Lin+Trs", "Lin+Deriv", "Spline+Trs", "Spline+Deriv", "DoubleLog1+Trs", 
 "DoubleLog1+Deriv", "DoubleLog2+Trs", "DoubleLog2+Deriv")
plot(lin.trs, col=cols[1], type=type, ylim=c(1, 365))
plot(lin.deriv, col=cols[2], type=type, add=TRUE)
plot(spl.trs, col=cols[3], type=type, add=TRUE)
plot(spl.deriv, col=cols[4], type=type, add=TRUE)
plot(beck.trs, col=cols[7], type=type, add=TRUE)
plot(beck.deriv, col=cols[8], type=type, add=TRUE)
plot(elmore.trs, col=cols[9], type=type, add=TRUE)
plot(elmore.deriv, col=cols[10], type=type, add=TRUE)
legend("center", nms, text.col=cols, ncol=3, bty="n")

cor(cbind(lin.trs$sos, lin.deriv$sos, spl.trs$sos, spl.deriv$sos, beck.trs$sos, 
   beck.deriv$sos, elmore.trs$sos, elmore.deriv$sos), use="pairwise.complete.obs")
cor(cbind(lin.trs$eos, lin.deriv$eos, spl.trs$eos, spl.deriv$eos, beck.trs$eos, 
   beck.deriv$eos, elmore.trs$eos, elmore.deriv$eos), use="pairwise.complete.obs")

# compare results: LOS
type <- c("los")
plot(lin.trs, col=cols[1], type=type, ylim=c(130, 365))
plot(lin.deriv, col=cols[2], type=type, add=TRUE)
plot(spl.trs, col=cols[3], type=type, add=TRUE)
plot(spl.deriv, col=cols[4], type=type, add=TRUE)
plot(beck.trs, col=cols[7], type=type, add=TRUE)
plot(beck.deriv, col=cols[8], type=type, add=TRUE)
plot(elmore.trs, col=cols[9], type=type, add=TRUE)
plot(elmore.deriv, col=cols[10], type=type, add=TRUE)
legend("bottom", nms, text.col=cols, ncol=5, bty="n")

# compare results: MSP, PEAK, TROUGH
type <- c("msp", "peak", "trough")
plot(lin.trs, col=cols[1], type=type, ylim=c(0.17, 0.37))
plot(lin.deriv, col=cols[2], type=type, add=TRUE)
plot(spl.trs, col=cols[3], type=type, add=TRUE)
plot(spl.deriv, col=cols[4], type=type, add=TRUE)
plot(beck.trs, col=cols[7], type=type, add=TRUE)
plot(beck.deriv, col=cols[8], type=type, add=TRUE)
plot(elmore.trs, col=cols[9], type=type, add=TRUE)
plot(elmore.deriv, col=cols[10], type=type, add=TRUE)
legend("bottom", nms, text.col=cols, ncol=5, bty="n")


}
