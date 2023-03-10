# devtools::load_all()
library(testthat)
set.seed(222)
n <- 201
pts <- seq(0, 1, by=0.015)
sampWienerD <- Wiener(n, pts)
sampWiener <- Sparsify(sampWienerD, pts, 10)
res <- FPCA(sampWiener$Ly, sampWiener$Lt )
  
test_that("fitted with QUO and FPC give similar results", {  
  
  fittedY <- fitted(res)
  fittedYe <- fitted(res, K=3, derOptns = list(p=1, method='FPC'))
  fittedYq <- fitted(res, K=3, derOptns = list(p=1, method='QUO'))
  
  if(1==3){
    par(mfrow=c(1,3))
    matplot(t(fittedY[1:3,]),t='l')
    matplot(t(fittedYe[1:3,]),t='l')
    matplot(t(fittedYq[1:3,]),t='l')
  }
  
  expect_warning(fitted(res, k=3, derOptns = list(p=1, method='FPC')), "specifying 'k' is deprecated. Use 'K' instead!")
  expect_equal( fittedYe, fittedYq, tolerance =0.01, scale= 1 ) #absolute difference
  
})

test_that("fitted and real data are extremely correlated", {  
  
  fittedY <- fitted(res) 
  
  if(1==3){
    par(mfrow=c(1,2))
    matplot(t(fittedY[1:5,]),t='l')
    matplot(t(sampWienerD[1:5,]),t='l') 
  } 
  
  expect_true(  cor(fittedY[,19], sampWienerD[,19] ) > 0.85 )  
  expect_true(  cor(fittedY[,29], sampWienerD[,29] ) > 0.85 )  
  expect_true(  cor(fittedY[,39], sampWienerD[,39] ) > 0.85 )  
  
})
