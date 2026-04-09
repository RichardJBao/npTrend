#' Local constant nonparametric estimator
#'
#' @keywords internal
LCEstimation <- function(y,time,h,k){
  diff <- outer(time,time,"-")/h
  k.diff <- do.call(k,list(diff))
  m.hat <- (k.diff %*% y)/rowSums(k.diff)
  return(m.hat)
}

#' Optional: Local linear nonparametric estimator
#'
#' @keywords internal
LLEstimation <- function(y,time,h,k){
  n <- length(y)
  m.hat <- rep(0,n)
  for (i in 1:n){
    diff <- (rep(time[i],n)-time)/h
    ker <- do.call(k,list(diff))
    zmatrix <- cbind(rep(1,n),rep(time[i],n)-time)
    bhat <- solve(t(zmatrix) %*% diag(ker) %*% zmatrix) %*%
      (t(zmatrix) %*% diag(ker) %*% y)
    m.hat[i] <-  bhat[1,]
  }
  return(m.hat)
}
