#' Fit linear trend without break
#' @keywords internal
fit.trend <- function(y,time,nterms){
  reg <- regressors(0,time,nterms)
  reg <- reg[,(1:(2*nterms+2))]
  para <- solve(t(reg)%*%reg)%*%t(reg)%*%y
  reg.fit <- reg%*%para
  trend.fit <- reg[,(2*nterms+1):(2*nterms+2)]%*%para[(2*nterms+1):(2*nterms+2),]
  resid <- y - reg.fit
  SSR <- t(resid)%*%resid
  return(list(para,reg.fit,SSR,trend.fit))
}


#' Fit linear trend with one break
#' @keywords internal
fit.break <- function(y,time,breakdate,nterms){
  diff <- time-breakdate
  date <- which.min(abs(diff))
  reg <- regressors(breakdate,time,nterms)
  para <- solve(t(reg)%*%reg)%*%t(reg)%*%y
  reg.fit <- reg%*%para
  res <- y - reg.fit
  SSR <- t(res) %*% res
  trend.fit <- reg[,(2*nterms+1):(2*nterms+3)]%*%para[(2*nterms+1):(2*nterms+3),]
  intercept <- para[2*nterms+1]
  slope1 <- para[2*nterms+2]
  slope2 <- para[2*nterms+3]
  intercept2 <- intercept - time[date]*slope2
  para.transform <- rep(0,2*nterms+4)
  para.transform[1:(2*nterms)] <- para[(1:(2*nterms)),1]
  para.transform[(2*nterms+1):(2*nterms+4)] <- c(intercept,intercept2,slope1,(slope1+slope2))
  return(list(para,para.transform,reg.fit,SSR,trend.fit))
}
