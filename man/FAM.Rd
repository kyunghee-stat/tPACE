% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/FAM.R
\name{FAM}
\alias{FAM}
\title{Functional Additive Models}
\usage{
FAM(
  Y,
  Lx,
  Lt,
  nEval = 51,
  newLx = NULL,
  newLt = NULL,
  bwMethod = 0,
  alpha = 0.7,
  supp = c(-2, 2),
  optns = NULL
)
}
\arguments{
\item{Y}{An \emph{n}-dimensional vector whose elements consist of scalar responses.}

\item{Lx}{A list of \emph{n} vectors containing the observed values for each individual. See \code{FPCA} for detail.}

\item{Lt}{A list of \emph{n} vectors containing the observation time points for each individual. Each vector should be sorted in ascending order. See \code{FPCA} for detail.}

\item{nEval}{The number of evaluation grid points for kernel smoothing (default is 51. If it is specified as 0, then estimated FPC scores in the training set are used for evaluation grid instead of equal grid).}

\item{newLx}{A list of the observed values for test set. See \code{predict.FPCA} for detail.}

\item{newLt}{A list of the observed time points for test set. See \code{predict.FPCA} for detail.}

\item{bwMethod}{The method of bandwidth selection for kernel smoothing, a positive value for designating K-fold cross-validtaion and zero for GCV (default is 50)}

\item{alpha}{The shrinkage factor (positive number) for bandwidth selection. See Han et al. (2016) (default is 0.7).}

\item{supp}{The lower and upper limits of kernel smoothing domain for studentized FPC scores, which FPC scores are divided by the square roots of eigenvalues (default is [-2,2]).}

\item{optns}{A list of options control parameters specified by list(name=value). See \code{FPCA}.}
}
\value{
A list containing the following fields:
\item{mu}{Mean estimator of \eqn{EY}}
\item{fam}{A \emph{N} by \emph{K} matrix whose column vectors consist of the component function estimators at the given estimation points.}
\item{xi}{An \emph{N} by \emph{K} matrix whose column vectors consist of \emph{N} vectors of estimation points for each component function.}
\item{bw}{A \emph{K}-dimensional bandwidth vector.}
\item{lambda}{A \emph{K}-dimensional vector containing eigenvalues.}
\item{phi}{An \emph{nWorkGrid} by \emph{K} matrix containing eigenfunctions, supported by \code{WorkGrid}. See \code{FPCA}.}
\item{workGrid}{An \emph{nWorkGrid} by \emph{K_j} working grid, the internal regular grid on which the eigen analysis is carried on. See \code{FPCA}.}
}
\description{
Functional additive models with a single predictor process
}
\details{
\code{FAM} fits functional additive models for a scalar response and single predictor process proposed by M??ller and Yao (2007) that \deqn{E(Y | \mathbf{X}) = \sum_{k=1}^K g_{k}(\xi_{k}),} where \eqn{\xi_{k}} stand for the k-th FPC score of the the predictor process.
}
\examples{
set.seed(1000)

library(MASS)

f1 <- function(t) 0.5*t
f2 <- function(t) 2*cos(2*pi*t/4)
f3 <- function(t) 1.5*sin(2*pi*t/4)
f4 <- function(t) 2*atan(2*pi*t/4)

n <- 100
N <- 100

sig <- diag(c(4.0,2.0,1.5,1.2))

scoreX <- mvrnorm(n,mu=rep(0,4),Sigma=sig)
scoreXTest <- mvrnorm(N,mu=rep(0,4),Sigma=sig)

Y <- f1(scoreX[,1]) + f2(scoreX[,2]) + f3(scoreX[,3]) + f4(scoreX[,4]) + rnorm(n,0,0.1)
YTest <- f1(scoreXTest[,1]) + f2(scoreXTest[,2]) + 
  f3(scoreXTest[,3]) + f4(scoreXTest[,4]) + rnorm(N,0,0.1)

phi1 <- function(t) sqrt(2)*sin(2*pi*t)
phi2 <- function(t) sqrt(2)*sin(4*pi*t)
phi3 <- function(t) sqrt(2)*cos(2*pi*t)
phi4 <- function(t) sqrt(2)*cos(4*pi*t)

grid <- seq(0,1,length.out=21)
Lt <- Lx <- list()
for (i in 1:n) {
  Lt[[i]] <- grid
  Lx[[i]] <- scoreX[i,1]*phi1(grid) + scoreX[i,2]*phi2(grid) + 
    scoreX[i,3]*phi3(grid) + scoreX[i,4]*phi4(grid) + rnorm(1,0,0.01)
}

LtTest <- LxTest <- list()
for (i in 1:N) {
  LtTest[[i]] <- grid
  LxTest[[i]] <- scoreXTest[i,1]*phi1(grid) + scoreXTest[i,2]*phi2(grid) + 
    scoreXTest[i,3]*phi3(grid) + scoreXTest[i,4]*phi4(grid) + rnorm(1,0,0.01)
}


# estimation
fit <- FAM(Y=Y,Lx=Lx,Lt=Lt)

xi <- fit$xi

op <- par(mfrow=c(2,2))
j <- 1
g1 <- f1(sort(xi[,j]))
tmpSgn <- sign(sum(g1*fit$fam[,j]))
plot(sort(xi[,j]),g1,type='l',col=2,ylim=c(-2.5,2.5),xlab='xi1')
points(sort(xi[,j]),tmpSgn*fit$fam[order(xi[,j]),j],type='l')

j <- 2
g2 <- f2(sort(xi[,j]))
tmpSgn <- sign(sum(g2*fit$fam[,j]))
plot(sort(xi[,j]),g2,type='l',col=2,ylim=c(-2.5,2.5),xlab='xi2')
points(sort(xi[,j]),tmpSgn*fit$fam[order(xi[,j]),j],type='l')

j <- 3
g3 <- f3(sort(xi[,j]))
tmpSgn <- sign(sum(g3*fit$fam[,j]))
plot(sort(xi[,j]),g3,type='l',col=2,ylim=c(-2.5,2.5),xlab='xi3')
points(sort(xi[,j]),tmpSgn*fit$fam[order(xi[,j]),j],type='l')

j <- 4
g4 <- f4(sort(xi[,j]))
tmpSgn <- sign(sum(g4*fit$fam[,j]))
plot(sort(xi[,j]),g4,type='l',col=2,ylim=c(-2.5,2.5),xlab='xi4')
points(sort(xi[,j]),tmpSgn*fit$fam[order(xi[,j]),j],type='l')
par(op)

# fitting
fit <- FAM(Y=Y,Lx=Lx,Lt=Lt,nEval=0)
yHat <- fit$mu+apply(fit$fam,1,'sum')
plot(yHat,Y)
abline(coef=c(0,1),col=2)


# R^2
R2 <- 1-sum((Y-yHat)^2)/sum((Y-mean(Y))^2)
R2


# prediction
fit <- FAM(Y=Y,Lx=Lx,Lt=Lt,newLx=LxTest,newLt=LtTest)
yHat <- fit$mu+apply(fit$fam,1,'sum')
plot(yHat,YTest,xlim=c(-10,10))
abline(coef=c(0,1),col=2)
}
\references{
\cite{M??ller, H.-G. and Yao, F. (2005), "Functional additive models", JASA, Vol.103, No.484, p.1534-1544.}
}
