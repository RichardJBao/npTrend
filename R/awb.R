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
  v <- stats::rnorm(n)
  nu <- L %*% (resid*v)
  as.numeric(nu)
}
