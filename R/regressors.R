#' Construct regressor matrix for trend with break and Fourier terms
#'
#' @keywords internal
regressors <- function(breakdate, time, nterms){
  nterms <- as.numeric(nterms)    # force numeric to avoid list/scalar issues
  iter <- 0                      # define iter outside of if/else

  if (nterms == 0){
    x.matrix <- matrix(0, nrow=length(time), ncol=3)
  } else {
    x.matrix <- matrix(0, nrow=length(time), ncol=2*nterms + 3)
    for (i in seq_len(nterms)){
      x.matrix[, 2*(i-1)+1] <- cos(2*pi*i*time)
      x.matrix[, 2*i] <- sin(2*pi*i*time)
    }
    iter <- nterms                 
  }

  x.matrix[, 2*iter + 1] <- 1
  x.matrix[, 2*iter + 2] <- time
  ind <- time > breakdate
  x.matrix[, 2*iter + 3] <- (time - breakdate) * ind

  return(x.matrix)
}