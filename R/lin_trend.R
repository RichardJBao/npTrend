#' Main linear trend estimation with break testing
#'
#' Trend estimation with bootstrap inference for location and confidence interval of the break, and point estimation and confidence intervals for parameters
#'
#' @param y Numeric vector of length n of observations containing the time series of interest
#' @param time A vector of length n, containing the corresponding dates in decimal format
#' @param B Integer number of bootstrap replications.
#' @param alpha Nominal coverage of confidence intervals will be (1-alpha)
#' @param nterms Integer specifying the number of Fourier terms, default = 3
#' @param trim.frac Parameter pi as described in Section 3.1 of Friedrich et al. (2020), default equals 0.1
#' @param cores Integer; number of CPU cores to use for parallel bootstrap. Default is 1.
#'
#' @return A list containing the following:
#' \item{p}{Numeric. p-value of bootstrap test for break in trend.}
#' \item{cv}{Numeric. Critical value of the test.}
#' \item{S_T}{Numeric. Test statistic S_T.}
#' \item{para}{Numeric vector. Parameters of the trend.}
#' \item{fit}{List. Fitted values.}
#' \item{breakpoint}{Numeric. Point estimation of trend break location.}
#' \item{CI.break}{Numeric vector. Bootstrap 95\% confidence interval for trend break.}
#' \item{CI.para}{List. Bootstrap 95\% confidence intervals for parameters.}
#' @export
lin.trend <- function(y,time,B,alpha, nterms=3, trim.frac=0.1, cores = 1){
  test <- breaktest(y,time,nterms,B,alpha,trim.frac)
  p <- test[[1]]
  cv <- test[[2]]
  S_T <- test[[3]]
  if (p < 0.05){
    breakpoint <- get.break(y,time,nterms,trim.frac)[[1]]
    break.reg <- fit.break(y,time,breakpoint,nterms)
    para <- break.reg[[2]]
    fit <- list(break.reg[[3]],break.reg[[5]])
    CI <- location.bootstrap(y,time,break.reg[[3]],nterms,B,alpha,trim.frac, cores)
    CI.low <- CI[[1]]
    CI.up <- CI[[2]]
    CI.para <- para.bootstrap(y,time,break.reg[[3]],para,breakpoint,nterms,B,alpha,trim.frac)
    CI.para.low <- CI.para[[1]]
    CI.para.up <- CI.para[[2]]
  }else{
    breakpoint <- 0
    trend.reg <- fit.trend(y,time,nterms)
    para <- trend.reg[[1]]
    fit <- list(trend.reg[[2]],trend.reg[[4]])
    CI.para <- para.bootstrap(y,time,trend.reg[[2]],para,breakpoint,nterms,B,alpha,trim.frac)
    CI.para.low <- CI.para[[1]]
    CI.para.up <- CI.para[[2]]
    CI.low <- 0
    CI.up <- 0
  }
  return(list(p,cv,S_T,para,fit,breakpoint,c(CI.low,CI.up),c(CI.para.low,CI.para.up)))
}

#' Plot linear trend results
#'
#' @param x An object of class "results.linear".
#' @param y Ignored; included for compatibility with the plot generic.
#' @param fit Fitted values (optional, defaults to x[[5]]).
#' @param breakdate Estimated break date (optional).
#' @param CI.break Confidence interval for break (optional).
#' @param low Lower bound of y-axis.
#' @param up Upper bound of y-axis.
#' @param xlabel X-axis label.
#' @param ylabel Y-axis label.
#' @param ... Additional arguments passed to the generic \code{plot} function.
#'
#' @return Returns plots of the linear trend estimation, estimated breakpoint, and confidence intervals
#'
#' @method plot results.linear
#' @export plot.results.linear
plot.results.linear <- function(y, time, fit, breakdate, CI.break, low, up, xlabel, ylabel) {

  # 1. Initialize the plot and draw the grey data points
  plot(time, y, type="p", lwd=1.5, ylim=c(low,up), col="grey", xlab=xlabel, ylab=ylabel)

  # 2. Add the two fitted lines from your fit list
  lines(time, fit[[1]], lwd=2, col="blue")
  lines(time, fit[[2]], lwd=2, col="black")

  # 3. Add the vertical breakdate confidence intervals
  abline(v=CI.break[1], lty=3, lwd=2)
  abline(v=CI.break[2], lty=3, lwd=2)
}

