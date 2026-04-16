#' Autoregressive wild bootstrap for nonparametric trend
#'
#'
#' @keywords internal
AWBootstrap <- function(y,time,m.tilde,B,h,newtime,k){
  n <- length(y)
  eps.hat <- y - m.tilde

  # Precompute smoothing weight matrix, avoiding LCEstimation in each
  diff <- outer(newtime, newtime, "-")/h
  k.diff <- do.call(k, list(diff))
  W <- k.diff / rowSums(k.diff)

  th <- 0.01^(1 / (1.75 * n^(1/3)))
  l <- stats::median(diff(time))
  L <- cholesky.decomp(time, th, l)

  m.hat.star <- foreach::foreach(b = 1:B, .combine = 'cbind', .packages = "stats") %dopar% {

    # Generate perturbed residuals using the corrected AWB logic (parentheses matter!)
    eps.star <- awb(eps.hat, L)
    y.star <- m.tilde + eps.star

    # Apply the precomputed weights to the new synthetic data
    as.numeric(W %*% y.star)
  }

  return(m.hat.star)
}
