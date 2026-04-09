#' Autoregressive wild bootstrap for nonparametric trend
#'
#'
#' @keywords internal
AWBootstrap <- function(y,time,m.tilde,B,h,newtime,k){
  n <- length(y)
  eps.hat <- y - m.tilde
  m.hat.star <- matrix(data=0, nrow=n, ncol=B)

  # Precompute smoothing weight matrix, avoiding LCEstimation in each
  diff <- outer(newtime, newtime, "-")/h
  k.diff <- do.call(k, list(diff))
  W <- k.diff / rowSums(k.diff)

  for (b in 1:B){
    eps.star <- awb(eps.hat,time)
    y.star <- m.tilde + eps.star
    m.hat.star[,b] <- W %*% y.star
  }
  return(m.hat.star)
}
