#' Modified cross-validation bandwidth selection
#'
#' @keywords internal
MCV <- function(y,time,ell,grid,k){
  n <- length(y)
  dim <- length(grid)
  CV <- rep(0, dim)
  for (i in 1:dim){
    m.hat.llo <- rep(0,n)
    for (j in (1+ell):(n-ell)){
      timeleaveout <- time
      timeleaveout[(j-ell):(j+ell)] <- 0
      yleaveout <- y
      yleaveout[(j-ell):(j+ell)] <- 0
      m.hat.llo[j] <- LCEstimation(yleaveout,timeleaveout,grid[i],k)[j]
    }
    errors <- y-m.hat.llo
    errors[1:ell] <- 0
    errors[(n-ell+1):n] <- 0
    CV[i] <- t(errors)%*%errors
  }
  ind <- which.min(CV)
  h.opt <- grid[ind]
  return(list(h.opt,CV))
}

