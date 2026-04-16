#' Nonparametric trend estimation with bootstrap inference
#'
#' Estimates trend, with bootstrap pointwise confidence intervals and simultaneous confidence bands for the trend
#'
#' @param y Numeric vector of length n of observations containing the time series of interest
#' @param time A vector of length n, containing the corresponding dates in decimal format
#' @param B Integer number of bootstrap replications.
#' @param alpha Nominal coverage of confidence intervals will be (1-alpha)
#' @param h Bandwidth parameter for nonparametric estimation, can be selected by the user or by a data-driven selection method,
#' called Modified Cross Validation (MCV) and will be started by selecting "h=-1" with parameter
#' l=4 and a grid [0.001,0.099] by default. Both can be changed by the user
#' @param k Kernel function for nonparametric estimation, with Epanechnikov, Uniform, Quartic, Cosine kernels available
#' @param nterms Integer specifying the number of Fourier terms, default = 3
#' @param G Set of time indices over which the confidence bands will be made simultaneous, with default being whole sample
#' @param C Parameter determining the extend of oversmoothing in Step 1 of the bootstrap algorithm, default is 0.5
#' @param l Parameter for MCV, default equals 4
#' @param grid Range of possible bandwidth for MCV, default being [0.001,0.099] in steps of 0.002
#'
#' @return A list of class "results.nonpara" containing:
#' \item{m.hat}{Trend estimate vector.}
#' \item{confidence.pw}{Matrix of pointwise confidence intervals.}
#' \item{confidence.simu}{Matrix of simultaneous confidence bands.}
#' \item{h.opt}{Selected bandwidth.}
#' \item{CV}{MCV criterion matrix.}
#' @export
nonpara.trend <- function(y,time,B,alpha,h,k,nterms=3,
                          G=seq(1,length(y),1),C=0.5,l=5,
                          grid=seq(0.01, by=0.005, length.out=50)){
  n <- length(y)
  newtime <- (time-time[1])/(time[n]-time[1])
  if (nterms!=0){
    y <- remove.fourier(y,time,nterms)
  }else if(nterms<0){"invalid number of Fourier terms"}
  if (h == -1){
    temp <- MCV(y,newtime,l,grid,k)
    h.opt <- temp[[1]]
    CV <- cbind(grid, temp[[2]])
  }else{
    h.opt <- h
  }
  h.tilde <- C*(h.opt)^(5/9)
  m.hat <- LCEstimation(y,newtime,h.opt,k)
  m.tilde <- LCEstimation(y,newtime,h.tilde,k)
  m.star <- AWBootstrap(y,time,m.tilde,B,h.opt,newtime,k)
  confidence.pw <- pointwise.int(y,m.hat,m.star,m.tilde,alpha,B)
  G.total <- length(G)
  confidence.simu <- simult.int(y,m.hat,m.tilde,m.star,alpha,B,G,G.total)
  if (h == -1){
    return(list(y,m.hat,confidence.pw,confidence.simu,h.opt,CV))
  }else{
    return(list(y,m.hat,confidence.pw,confidence.simu))
  }
}

#' Plot nonparametric trend and confidence bands
#'
#' @param x An object of class "results.linear".
#' @param time A vector containing the corresponding dates.
#' @param m.hat Trend estimate vector.
#' @param int.s Matrix of simultaneous confidence bands.
#' @param low Lower bound of y-axis.
#' @param up Upper bound of y-axis.
#' @param xlabel X-axis label.
#' @param ylabel Y-axis label.
#' @param ... Additional arguments passed to the generic \code{plot} function.
#'
#' @method plot results.nonpara
#' @export plot.results.nonpara
plot.results.nonpara <- function(x, time, m.hat, int.s, low, up, xlabel, ylabel, ...) {

  # 1. Initialize the plot and draw the grey data points
  plot(time, x, type="p", ylim=c(low,up), col="grey", xlab=xlabel, ylab=ylabel, ...)

  # 2. Add the fitted line
  lines(time, m.hat, lwd=1.5, col="black")

  # 3. Add the upper and lower confidence intervals
  lines(time, int.s[,1], lwd=1.5, col="blue")
  lines(time, int.s[,2], lwd=1.5, col="blue")
}
