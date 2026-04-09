#' Regress data on Fourier terms and obtain residuals
#'
#' @keywords internal
remove.fourier <- function(y,time,nterms){
  x.matrix <- matrix(data=0, nrow=length(time),ncol=2*nterms+1)
  for (iter in 1:nterms){
    x.matrix[,(2*(iter-1)+1)] <- cos(2*pi*iter*time)
    x.matrix[,(2*iter)] <- sin(2*pi*iter*time)
  }
  x.matrix[,(2*nterms+1)] <- rep(1,length(time))
  fouriercoef <- solve(t(x.matrix) %*% x.matrix)%*%(t(x.matrix)%*%y)
  seasonal_adj <- y - x.matrix %*% fouriercoef
  return(seasonal_adj)
}
