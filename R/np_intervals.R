#' Pointwise confidence intervals
#'
#' @keywords internal
pointwise.int <- function(y,m.hat,m.star,m.tilde,alpha,B){
  n <- length(y)
  diff.beta <- m.star - matrix(data=m.tilde, nrow=n, ncol=B)
  beta.sorted <- matrix(data=NA, nrow=n, ncol=B)
  intervals.beta <- matrix(data=NA, nrow=n, ncol=2)

  beta.sorted <- t(apply(diff.beta, 1, sort, decreasing = FALSE))

  intervals.beta[,1] <- as.numeric(m.hat) - beta.sorted[,ceiling((1-(alpha/2))*B)]
  intervals.beta[,2] <- as.numeric(m.hat) - beta.sorted[,ceiling((alpha/2)*B)]
  return(intervals.beta)
}

#' Simultaneous confidence bands
#'
#' @keywords internal
simult.int <- function(y, m.hat, m.tilde, m.star, alpha, B, G, G.total) {
  n <- length(y)
  diff.beta <- m.star - matrix(data = m.tilde, nrow = n, ncol = B)

  # Fast row-wise sorting
  beta.sorted <- t(apply(diff.beta, 1, sort))

  alpha.p <- 1 / B
  count.b <- 1
  beta.quantiles <- matrix(data = NA, nrow = n, ncol = 2 * ceiling(alpha * B) - 2)

  while (alpha.p < alpha) {
    beta.quantiles[, count.b] <- beta.sorted[, ceiling((alpha.p / 2) * B)]
    beta.quantiles[, count.b + 1] <- beta.sorted[, ceiling((1 - alpha.p / 2) * B)]
    count.b <- count.b + 2
    alpha.p <- alpha.p + 1 / B
  }

  beta.total <- 0
  alpha.p <- 1 / B
  beta.ratio <- matrix(data = NA, nrow = ceiling(alpha * B) - 1, ncol = 1)
  xx <- 1; xb <- 1

  # Subset the matrix once for the G indices
  diff.beta.G <- diff.beta[G, , drop = FALSE]

  while (alpha.p < alpha) {
    lower_bound <- beta.quantiles[G, xb]
    upper_bound <- beta.quantiles[G, xb + 1]

    # VECTORIZED CHECK: Replaces the j and k loops.
    # Checks if every element in the matrix is within bounds simultaneously
    is_within <- (diff.beta.G >= lower_bound) & (diff.beta.G <= upper_bound)

    # colSums counts how many G elements are valid in each of the B columns
    # sum(...) counts how many columns had a perfect G.total score
    beta.total <- sum(colSums(is_within) == G.total)

    beta.ratio[xx] <- beta.total / B
    alpha.p <- alpha.p + 1 / B
    xx <- xx + 1
    xb <- xb + 2
  }

  beta.difference <- beta.ratio - (1 - alpha)
  beta.min <- which.min(abs(beta.difference))
  m_vec <- as.numeric(m.hat)
  q_low <- as.numeric(beta.quantiles[, (2 * beta.min)])
  q_high <- as.numeric(beta.quantiles[, (2 * beta.min - 1)])

  beta.confidence <- matrix(data = NA, nrow = n, ncol = 2)
  beta.confidence[, 1] <- m_vec - q_low
  beta.confidence[, 2] <- m_vec - q_high
  return(beta.confidence)
}

