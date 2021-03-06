TrendLongestSEG <- structure(function(
	##title<< 
	## Extract slope and p-value for the longest time series segment from a TrendRaster raster brick 
	##description<<
	## This function extracts the slope and p-value of a trend for the longest time series segment from a raster brick that was created with \code{\link{TrendRaster}}
	
	r
	### \code{RasterBrick} as created with \code{\link{TrendRaster}} or object of class 'Trend' as returned by \code{\link{Trend}}

	##seealso<<
	## \code{\link{TrendRaster}}
) {
	if (class(r) == "Trend") {
		# get results for longest segment if Trend object
		bp <- r$bp$breakpoints	# get breakpoints
		breaks <- length(bp) 
		bp.dates.res <- rep(NA, breaks)	# resulting vector for breakdates
		seg.length.res <- rep(NA, breaks+1)	# resulting vector for segment length
		if (!is.na(bp[1])) {
			bp.dates <- as.numeric(r$time[r$bp$breakpoints])	# get breakdate
			bp.dates.res[1:length(bp.dates)] <- bp.dates					# copy breakdate to result vector
			limits <- c(r$bp$breakpoints, length(r$series))	# get ends of segments
			seg.length <- c(limits[1], limits[2:length(limits)] - limits[1:(length(limits)-1)])	
			seg.length.res[1:length(seg.length)] <- seg.length
		} else {
			seg.length.res[1] <- length(r$series)
		}
		seg.max <- which.max(seg.length.res)
		sl <- 	# slope of longest segment
		pval <- r$pval[seg.max]	# p-value of longest segment
		if (all(is.na(pval))) pval <- r$mk.pval[seg.max]
		r2 <- c(
		   LengthSEG = seg.length.res[seg.max], 
		   SlopeSEG = r$slope[seg.max], 
		   PvalSEG = pval, 
		   LongestSEG=seg.max, 
		   SlopeUncLowerSEG = unlist(r$slope_unc[seg.max, 2]), 
		   SlopeUncUpperSEG = unlist(r$slope_unc[seg.max, 3]), 
		   SlopeUncMed = unlist(r$slope_unc[seg.max, 4]))
		names(r2) <- c("LengthSEG", "SlopeSEG", "PvalSEG", "LongestSEG", "SlopeUncLowerSEG", "SlopeUncUpperSEG", "SlopeUncMedianSEG")
	} else {
		# get results for longest segment if raster
		nms <- NamesTrendRaster(r)
		r2 <- calc(r, function(x) {
			result <- rep(NA, 4)
			if (!AllEqual(x)) {
				seg.length <- x[grep("Length", nms)] # length of each segment
				seg.max <- which.max(seg.length)	# longest segment
				sl <- x[grep("Slope", nms)[seg.max]]	# slope of longest segment
				pval <- x[grep("Pval", nms)[seg.max]]	# p-value of longest segment
				lngth <- seg.length[seg.max]	# length of longest segment
				result <- c(lngth, sl, pval, seg.max)
			}
			return(result)	
		})
		names(r2) <- c("LengthSEG", "SlopeSEG", "PvalSEG", "LongestSEG")
	}
	return(r2)		
}, ex=function() {
# load a multi-temporal raster dataset of Normalized Difference Vegetation Index
data(ndvimap)
plot(ndvimap, 8)

# calculate trend 
trendmap <- TrendRaster(ndvimap, start=c(1982, 1), freq=12, method="AAT", breaks=1)
plot(trendmap)

# select trend and p-value only for the longest time series segment
trendmap.longestseg <- TrendLongestSEG(trendmap)
plot(trendmap.longestseg)

})
