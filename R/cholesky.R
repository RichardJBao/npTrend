#' Cholesky decomposition for dependent bootstrap errors
#'
#' @param time Time index
#' @param theta Dependence parameter
#' @param l Scaling parameter
#' @return Cholesky factor
#' @keywords internal
cholesky.decomp <- function(time,theta,l){
  n <- length(time)
  gamma <- theta^(1/l)
  omega <- matrix(data=0, nrow=n, ncol=n)
  for (i in 1:n){
    for (j in i:n){
      if (i==j){
        omega[i,j] <- 0.5
      } else {
        omega[i,j] <- gamma^(time[j]-time[i])
      }
    }
  }
  omega <- omega + t(omega)
  L <- chol(omega)
  return(L)
}

