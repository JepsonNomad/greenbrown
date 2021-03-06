FitLogistic <- structure(function(
	##title<< 
	## Fit logistic functions 
	##description<<
	## Fits logistic functions between one or several predictor variables and a response variable. In case of multi-variate fits, logistic functions can be combined either additatively or multiplicatively: \cr
	## Additive: y = Logistic(x1) + Logistic(x2) + Logistic(xN) \cr
	## Multiplicative: y = Logistic(x1) * Logistic(x2) * Logistic(xN) 
	
	x,
	### predictor variables
	
	y,
	### response variables
	
	additive = FALSE,
	### Make an additive or multiplicative fit? The default is a multiplicative fit.
	
	method = c("genoud"),
	### Method to be used for optimization of fit parameters. "genoud" uses genetic optimization (see \code{\link{genoud}}). Can be also one of "Nelder-Mead", "BFGS", "CG", "L-BFGS-B", "SANN", "Brent" (see \code{\link{optim}}). If two methods are provided, the second method is applied on the best result of the first method.
		
	ninit = 50,
	### number of inital parameter sets for the optimization. Inital parameter sets will be included in genoud as part of the first generation. Each initial parameter set will be used as starting value within \code{\link{optim}} methods. A higher number of ninit will likely avoid solutions close to local optima but is computationally more expensive.
	
	...
	### further arguments for \code{\link{genoud}} or \code{\link{optim}}

	##details<<
	## No details.
	
	##references<< No reference.	
	
	##seealso<<
	## \code{\link{Logistic}}
) { 
	
	# compute logistic fit
	.model <- function(dpar, x, par.init, additive) {
	   par <- dpar * par.init
	   xf <- x
	   for (i in 1:ndim) {
	      xf[,i] <- Logistic(par[seq(i, by=ndim, length=3)], x[,i])
	      if (i == 1) pred <- xf[,i]
	      if (i > 1) {
	         if (additive) pred <- pred + xf[,i]
	         if (!additive) pred <- pred * xf[,i]
	      }
	   }
	   pred <- pred + par[length(par)] # offset
	   return(data.frame(xf, pred))
	}
	
	# compute sum of squared error
	.error <- function(dpar, x, y, par.init, additive) {
	   pred <- .model(dpar, x, par.init, additive)
	   err <- sum((pred$pred - y)^2, na.rm=TRUE)
	   return(err)
	}
	
	# prepare data
	xy <- na.omit(cbind(y, x))
	y <- xy[, 1]
	x <- xy[, -1]
	if (is.vector(x)) x <- matrix(x, nrow=length(x))
	ndim <- ncol(x)
	
	# create inital parameter sets
	sl.init <- (max(y) - min(y)) / (apply(x, 2, max) - apply(x, 2, min))
	ninit2 <- max(c(300, ninit))
	par.init <- c(rep(mean(y), ndim), sl.init, apply(x, 2, mean), min(y))
	dpar.init <- matrix(1, nrow=ninit2, ncol=length(par.init), byrow=TRUE)
	dpar.init[, 1:ndim] <- c(runif(ndim*ninit2/3, -50, 50), runif(ndim*ninit2/3, -3, 3), runif(ndim*ninit2/3, -0.9, 0.9))[1:(ndim*ninit2)]
	dpar.init[, (ndim+1):(ndim*2)] <- c(runif(ndim*ninit2/3, -500, 500), runif(ndim*ninit2/3, -5, 5), runif(ndim*ninit2/3, -0.5, 0.5))[1:(ndim*ninit2)]
	dpar.init[, (ndim*2+1):(ndim*3)] <- runif(ndim*ninit2, -5, 5)
	dpar.init[, ncol(dpar.init)] <- runif(ninit2, 0, 2000)
	dpar.init[is.na(dpar.init)] <- 1
	dpar.init <- rbind(dpar.init, 1)
	
	# select best initial parameter sets
	err <- apply(dpar.init, 1, FUN=function(dpar, x, y, par.init, additive) {
	   .error(dpar, x=x, y=y, par.init=par.init, additive=additive)
	}, x=x, y=y, par.init=par.init, additive=additive)
	dpar.init <- dpar.init[order(err)[1:ninit], ]
	
	# perform optimization
	if (method[1] == "genoud") { # genetic optimization
	   opt <- genoud(.error, nvars=length(par.init), starting.values=dpar.init, x=x, y=y, par.init=par.init, additive=additive, ...)
	   
	} else { # or optim
	
	   # optimize from initial parameter sets
	   opt.l <- apply(dpar.init, 1, FUN=function(dpar, x, y, par.init, additive) {
	      opt <- optim(dpar, .error, method=method[1], x=x, y=y, par.init=par.init, additive=additive)
	      fit <- .model(opt$par, x, par.init, additive)
         #plot(y, fit$pred)
         return(opt)
	   }, x=x, y=y, par.init=par.init, additive=additive)

	   # best fit
	   cost <- unlist(llply(opt.l, function(opt) opt$value))
	   best <- which.min(cost)
	   opt <- opt.l[[best]]
   }
   
   # perform a second optimization
   if (length(method) > 1) {
	   opt <- optim(opt$par, .error, method=method[2], x=x, y=y, par.init=par.init, additive=additive)
	}
	
	# final fit
	fit <- .model(opt$par, x, par.init=par.init, additive=additive)
   
   result <- list(predicted=fit$pred, model=.model, components=fit, par=opt$par*par.init, opt=opt, par.init=par.init, additive=additive)
   class(result) <- "FitLogistic"
   return(result)
   ### An object of class 'FitLogistic' which is actually a list.
}, ex=function() {

# 1D example
x <- 1:1000
y <- Logistic(c(1, 0.01, 500), x) + rnorm(1000, 0, 0.01)
plot(x, y)
fit <- FitLogistic(x, y)
lines(x, fit$predicted, col="red")
fit$par # fitted parameter

# performance of fit
ScatterPlot(fit$predicted, y, objfct=TRUE)

## 2D example - takes more time
#n <- 1000
#x1 <- runif(n, 0, 100)
#x2 <- runif(n, 0, 100)
#f1 <- Logistic(c(1, 0.1, 50), x1)
#f2 <- Logistic(c(1, -1, 20), x2)
#plot(x1, f1)
#plot(x2, f2)
#y <- f1 * f2 * rnorm(n, 1, 0.1)
#plot(x1, y) 
#plot(x2, y)
#fit <- FitLogistic(x=cbind(x1, x2), y)
#ScatterPlot(fit$predicted, y, objfct=TRUE)

})


predict.FitLogistic <- structure(function(
	##title<< 
	## Predict method for logistic function fits
	##description<<
	## Predict values based on logistic function fits.
	
	object,
	### an oject as returned by \code{\link{FitLogistic}}
	
	newdata,
	### data.frame of predictor variables

	...
	### further arguments (not used)

	##details<<
	## No details.
	
	##references<< No reference.	
	
	##seealso<<
	## \code{\link{FitLogistic}}
) { 
   pred <- do.call(object$model, list(dpar=object$opt$par, x=newdata, par.init=object$par.init, additive=object$additive))
   return(pred$pred)
   ### a vector of predicted values
}, ex=function() {

x <- 1:1000
y <- Logistic(c(1, 0.01, 500), x) + rnorm(1000, 0, 0.01)
plot(x, y)
fit <- FitLogistic(x, y)
lines(x, fit$predicted, col="red")

newdata <- data.frame(x=-500:1000)
pred <- predict(fit, newdata)
plot(newdata$x, pred)

})






