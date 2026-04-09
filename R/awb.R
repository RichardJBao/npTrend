#' Autoregressive wild bootstrap
#'
#' @param resid Residual vector
#' @param time Time index
#' 
#' @return Bootstrap errors
#' 
#' @keywords internal
awb <- function(resid, time) {
  n <- length(time)
  th <- 0.01^(1 / (1.75 * n^(1/3)))
  l <- 1 / 365.25

  L <- cholesky.decomp(time, th, l)
  nu <- L %*% stats::rnorm(n)
  as.numeric(nu) * resid
}
