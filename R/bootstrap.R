#' Bootstrap distribution of the break test statistic
#'
#' Computes the bootstrap distribution of the structural break test
#' statistic using the autoregressive wild bootstrap (AWB).
#'
#' The bootstrap is conducted under the null hypothesis of no structural
#' break, using residuals from the fitted no-break trend model.
#'
#' @param y Numeric vector of observations.
#' @param time Numeric vector of time indices of the same length as \code{y}.
#' @param nterms Integer specifying the number of Fourier terms used
#'   in the trend specification.
#' @param B Integer number of bootstrap replications.
#' @param trim.frac Trimming fraction used to exclude boundary regions
#'   from candidate break locations.
#'
#' @details
#' For each bootstrap replication, AWB residuals are generated and added
#' to the fitted no-break trend. The break test statistic is then recomputed
#' on the bootstrap sample. The returned bootstrap statistics are sorted
#' in ascending order.
#'
#' @return
#' A numeric vector of length \code{B} containing the sorted bootstrap
#' test statistics.
#'
#' @seealso \code{\link{break.teststat}}, \code{\link{fit.trend}}
#'
#' @keywords internal
# break.bootstrap <- function(y, time, nterms, B, trim.frac) {
#
#   trend <- as.numeric(fit.trend(y, time, nterms)[[2]])
#   resid <- y - trend
#
#   eps.star <- replicate(B, awb(resid, time))
#   y.star <- trend + eps.star
#
#   S.star <- numeric(B)
#   for (b in seq_len(B)) {
#     S.star[b] <- break.teststat(
#       y.star[, b], time, nterms, trim.frac
#     )[[1]]
#   }
#
#   return(sort(S.star))
# }

break.bootstrap <- function(y,time,nterms,B,trim.frac){
  n <- length(time)
  trend <- as.numeric(fit.trend(y,time,nterms)[[2]])
  resid <- y - trend
  S.star <- rep(0,B)
  for (b in 1:B){
    eps.star <- awb(resid,time)
    y.star <- trend + eps.star
    S.star[b] <- break.teststat(y.star,time,nterms,trim.frac)[[1]]
  }
  S.sorted <- sort(S.star, decreasing = FALSE)
  return(S.sorted)
}


#' Bootstrap confidence interval for break location (parallel)
#'
#' Computes a bootstrap confidence interval for the estimated break
#' location using parallel computation.
#'
#' The procedure resamples residuals via the autoregressive wild bootstrap
#' and recomputes the break location for each bootstrap replication.
#'
#' @param y Numeric vector of observations.
#' @param time Numeric vector of time indices.
#' @param trend.fit Fitted trend values under the selected model.
#' @param nterms Integer specifying the number of Fourier terms.
#' @param B Integer number of bootstrap replications.
#' @param alpha Significance level.
#' @param trim.frac Trimming fraction for admissible break locations.
#'
#' @details
#' The bootstrap is implemented using \code{parallel::parSapply}.
#' One CPU core is left unused by default.
#'
#' @return
#' A list of length two containing the lower and upper bounds
#' of the bootstrap confidence interval for the break location.
#'
#' @seealso \code{\link{get.break}}, \code{\link{break.bootstrap}}
#'
#' @keywords internal
location.bootstrap <- function(y, time, trend.fit, nterms,
                                B, alpha, trim.frac, cores = 1) {

  resid <- y - trend.fit
  cl <- parallel::makeCluster(cores)

  parallel::clusterExport(
    cl,
    c("awb", "cholesky.decomp", "regressors",
      "fit.trend", "fit.break", "get.break"),
    envir = environment()
  )

  T.star <- parallel::parSapply(cl, seq_len(B), function(b) {
    eps.star <- as.numeric(awb(resid, time))
    y.star <- trend.fit + eps.star
    get.break(y.star, time, nterms, trim.frac)[[1]]
  })

  parallel::stopCluster(cl)

  T.sorted <- sort(T.star)
  list(
    T.sorted[ceiling(alpha * B)],
    T.sorted[ceiling((1 - alpha) * B)]
  )
}


#' Bootstrap confidence intervals for trend parameters (parallel)
#'
#' Computes bootstrap confidence intervals for trend parameters
#' in either the no-break or one-break model using parallel computation.
#'
#' @param y Numeric vector of observations.
#' @param time Numeric vector of time indices.
#' @param trend.fit Fitted trend values.
#' @param para Estimated parameter vector.
#' @param breakdate Estimated break location (0 if no break).
#' @param nterms Integer specifying the number of Fourier terms.
#' @param B Integer number of bootstrap replications.
#' @param alpha Significance level.
#' @param trim.frac Trimming fraction for break estimation.
#'
#' @details
#' Bootstrap samples are generated using the autoregressive wild bootstrap.
#' Parameter estimates are recomputed for each bootstrap sample and used
#' to construct percentile-based confidence intervals.
#'
#' @return
#' A list of length two containing the lower and upper confidence bounds
#' for each parameter.
#'
#' @seealso \code{\link{fit.trend}}, \code{\link{fit.break}}
#'
#' @keywords internal
para.bootstrap <- function(y, time, trend.fit, para, breakdate,
                            nterms, B, alpha, trim.frac) {

  resid <- y - trend.fit
  rows <- if (breakdate == 0) 2 * nterms + 2 else 2 * nterms + 4

  cores <- max(1, parallel::detectCores() - 1)
  cl <- parallel::makeCluster(cores)

  parallel::clusterExport(
    cl,
    c("awb", "cholesky.decomp", "regressors",
      "fit.trend", "fit.break"),
    envir = environment()
  )

  diffs <- parallel::parSapply(cl, seq_len(B), function(b) {
    eps.star <- awb(resid, time)
    y.star <- trend.fit + eps.star
    if (breakdate == 0) {
      fit.trend(y.star, time, nterms)[[1]] - para
    } else {
      fit.break(y.star, time, breakdate, nterms)[[2]] - para
    }
  })

  parallel::stopCluster(cl)

  diffs <- as.matrix(diffs)
  stopifnot(nrow(diffs) == rows)
  lo <- apply(diffs, 1, quantile, probs = alpha / 2)
  hi <- apply(diffs, 1, quantile, probs = 1 - alpha / 2)

  list(para - hi, para - lo)
}

