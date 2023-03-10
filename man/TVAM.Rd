% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/TVAM.R
\name{TVAM}
\alias{TVAM}
\title{Iterative Smooth Backfitting Algorithm}
\usage{
TVAM(
  Lt,
  Ly,
  LLx,
  gridT = NULL,
  x = NULL,
  ht = NULL,
  hx = NULL,
  K = "epan",
  suppT = NULL,
  suppX = NULL
)
}
\arguments{
\item{Lt}{An \emph{n}-dimensional list of \emph{N_i}-dimensional vector whose elements consist of longitudinal time points for each \emph{i}-th subject.}

\item{Ly}{An \emph{n}-dimensional list of \emph{N_i}-dimensional vector whose elements consist of longitudinal response observations of each \emph{i}-subject corresponding to \emph{Lt}.}

\item{LLx}{A tuple of \emph{d}-lists, where each list represents longitudinal covariate observations of the \emph{j}-th component corresponding to \emph{Lt} and \emph{Ly}.}

\item{gridT}{An \emph{M}-dimensional sequence of evaluation time points for additive surface estimators. (Must be sorted in increasing orders.)}

\item{x}{An \emph{N} by \emph{d} matrix whose column vectors consist of \emph{N} vectors of evaluation points for additive surface component estimators at each covariate value.}

\item{ht}{A bandwidth for kernel smoothing in time component.}

\item{hx}{A \emph{d} vector of bandwidths for kernel smoothing covariate components, respectively.}

\item{K}{A \code{function} object representing the kernel to be used in the smooth backfitting (default is 'epan', the the Epanechnikov kernel.).}

\item{suppT}{A 2-dimensional vector consists of the lower and upper limits of estimation intervals for time component (default is \emph{[0,1]}).}

\item{suppX}{A \emph{d} by 2 matrix whose row vectors consist of the lower and upper limits of estimation intervals for each component function (default is the \emph{d}-dimensional unit rectangle of \emph{[0,1]}).}
}
\value{
A list containing the following fields:
\item{tvamComp}{A tuple of \emph{d}-lists, where each list is given by  \emph{M} by \emph{N} matrix whose elements represents the smooth backfitting surface estimator of the \emph{j}-component evaluated at \code{gridT} and the \emph{j}-th column of \code{x}.}
\item{tvamMean}{An \emph{M}-dimensional vector whose elements consist of the marginal time regression function estimated at \code{gridT}.}
}
\description{
Smooth backfitting procedure for time-varying additive models
}
\details{
\code{TVAM} estimates component surfaces of time-varying additive models for longitudinal observations based on the smooth backfitting algorithm proposed by Zhang et al. (2013). \code{TVAM} only focuses on the local constant smooth backfitting in contrast to the original development as in Zhang et al. (2013). However, the local polynomial version can be extended similarly, so that those are omitted in the development. Especially in this development, one can designate an estimation support of additive surfaces when the additive modeling is only allowed over restricted intervals or one is interested in the modeling over the support (see Han et al., 2016).
}
\examples{

set.seed(1000)

n <- 30
Lt <- list()
Ly <- list()
Lx1 <- list()
Lx2 <- list()

for (i in 1:n) {
  Ni <- sample(10:15,1)
  
  Lt[[i]] <- sort(runif(Ni,0,1))
  Lx1[[i]] <- runif(Ni,0,1)
  Lx2[[i]] <- runif(Ni,0,1)
  Ly[[i]] <- Lt[[i]]*(cos(2*pi*Lx1[[i]]) + sin(2*pi*Lx2[[i]])) + rnorm(Ni,0,0.1)
  
}

LLx <- list(Lx1,Lx2)

gridT <- seq(0,1,length.out=31)
x0 <- seq(0,1,length.out=31)
x <- cbind(x0,x0)

ht <- 0.1
hx <- c(0.1,0.1)

tvam <- TVAM(Lt,Ly,LLx,gridT=gridT,x=x,ht=ht,hx=hx,K='epan')

g0Sbf <- tvam$tvamMean
gjSbf <- tvam$tvamComp

op <- par(mfrow=c(1,2), mar=c(1,1,1,1)+0.1)
persp(gridT,x0,gjSbf[[1]],theta=60,phi=30,
      xlab='time',ylab='x1',zlab='g1(t, x1)')
persp(gridT,x0,gjSbf[[2]],theta=60,phi=30,
      xlab='time',ylab='x2',zlab='g1(t, x2)')
par(op)

}
\references{
\cite{Zhang, X., Park, B. U. and Wang, J.-L. (2013), "Time-varying additive models for longitudinal data", Journal of the 
American Statistical Association, Vol.108, No.503, p.983-998.}

\cite{Han, K., M??ller, H.-G. and Park, B. U. (2018), "Smooth backfitting for additive modeling with 
small errors-in-variables, with an application to additive functional regression for multiple predictor functions", Bernoulli, Vol.24, No.2, p.1233-1265.}
}
