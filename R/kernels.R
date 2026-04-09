#' Uniform kernel
#'
#' Usage note: internal function, if using uniform kernel run
#' k <- npTrend::k.unif and pass k into functions which
#' use k as input
#'
#' @param u Numeric vector
#' @return Kernel weights
#' @export
k.unif <- function(u) {
  bol <- abs(u) <= 1
  0.5 * bol
}

#' Epanechnikov kernel
#'
#' Usage note: internal function, if using Epanechnikov kernel
#' run k <- npTrend::k.epanech and pass k into functions which
#' use k as input
#'
#' @param u Numeric vector
#' @return Kernel weights
#' @export
k.epanech <- function(u) {
  bol <- abs(u) <= 1
  weight <- 3/4 * (1 - u^2)
  weight * bol
}

#' Quartic kernel
#'
#' Usage note: internal function, if using quartic kernel run
#' k <- npTrend::k.quartic and pass k into functions which
#' use k as input
#'
#' @param u Numeric vector
#' @return Kernel weights
#' @export
k.quartic <- function(u) {
  bol <- abs(u) <= 1
  weight <- 15/16 * (1 - u^2)^2
  weight * bol
}

#' Cosine kernel
#'
#' Usage note: internal function, if using cosine kernel run
#' k <- npTrend::k.cosine and pass k into functions which
#' use k as input
#'
#' @param u Numeric vector
#' @return Kernel weights
#' @export
k.cosine <- function(u) {
  bol <- abs(u) <= 1
  weight <- pi/4 * cos(pi/2 * u)
  weight * bol
}

