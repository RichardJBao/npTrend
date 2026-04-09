#' Locate break point
#' @keywords internal Helper function
get.break <- function(y,time,nterms,trim.frac){
  n <- length(y)
  trim <- n*trim.frac
  i.1 <- 1+trim
  i.2 <- n - trim
  len <- i.2-i.1+1
  SSR <- rep(0,len)
  for (i in 1:len){
    c.break <- i.1+(i-1)
    SSR[i] <- fit.break(y,time,time[c.break],nterms)[[4]]
  }
  min.ind <- i.1 + which.min(SSR) - 1
  min.val <- min(SSR)
  return(list(time[min.ind],min.val))
}

#' Break test statistic
#'
#' @param y Numeric vector of observations.
#' @param time Numeric vector of time indices.
#' @param nterms Integer specifying the number of Fourier terms.
#' @param trim.frac Trimming fraction for break estimation.
#'
#' @export
break.teststat <- function(y,time,nterms,trim.frac){
  SSR <- fit.trend(y,time,nterms)[[3]]
  break.reg <- get.break(y,time,nterms,trim.frac)
  break.date <- break.reg[[1]]
  SSR.break <- break.reg[[2]]
  S <- SSR - SSR.break
  return(list(S,SSR))
}

#' Break test with bootstrap
#' @keywords internal
breaktest <- function(y,time,nterms,B,alpha,trim.frac){
  temp <- break.teststat(y,time,nterms,trim.frac)
  S <- temp[[1]]
  S.boot <- break.bootstrap(y,time,nterms,B,trim.frac)
  p.value <- mean(S.boot>rep(S,B))
  critical.value <- S.boot[ceiling((1-alpha)*B)]
  return(list(p.value,critical.value,S))
}


