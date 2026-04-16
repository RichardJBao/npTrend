#' Autoregressive wild bootstrap
#'
#' @param resid Residual vector
#' @param L Precalculated Cholesky matrix
#'
#' @return Bootstrap errors
#'
#' @keywords internal
awb <- function(resid, L) {
  n <- length(resid)
  nu <- L %*% stats::rnorm(n)
  as.numeric(nu) * resid
}
