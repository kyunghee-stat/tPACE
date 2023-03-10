% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/FCReg.R
\name{FCReg}
\alias{FCReg}
\title{Functional Concurrent Regression using 2D smoothing}
\usage{
FCReg(
  vars,
  userBwMu,
  userBwCov,
  outGrid,
  kern = "gauss",
  measurementError = TRUE,
  diag1D = "none",
  useGAM = FALSE,
  returnCov = TRUE
)
}
\arguments{
\item{vars}{A list of input functional/scalar covariates. Each field corresponds to a functional (a list) or scalar (a vector) covariate. The last entry is assumed to be the response if no entry is names 'Y'. If a field corresponds to a functional covariate, it should have two fields: 'Lt', a list of time points, and 'Ly', a list of function values.}

\item{userBwMu}{A scalar with bandwidth used for smoothing the mean}

\item{userBwCov}{A scalar with bandwidth used for smoothing the auto- and cross-covariances}

\item{outGrid}{A vector with the output time points}

\item{kern}{Smoothing kernel choice, common for mu and covariance; "rect", "gauss", "epan", "gausvar", "quar" (default: "gauss")}

\item{measurementError}{Indicator measurement errors on the functional observations should be assumed. If TRUE the diagonal raw covariance will be removed when smoothing. (default: TRUE)}

\item{diag1D}{A string specifying whether to use 1D smoothing for the diagonal line of the covariance. 
'none': don't use 1D smoothing; 'cross': use 1D only for cross-covariances; 'all': use 1D for both auto- and cross-covariances. (default : 'none')}

\item{useGAM}{Indicator to use gam smoothing instead of local-linear smoothing (semi-parametric option) (default: FALSE)}

\item{returnCov}{Indicator to return the covariance surfaces, which is a four dimensional array. The first two dimensions correspond to outGrid
and the last two correspond to the covariates and the response, i.e. (i, j, k, l) entry being Cov(X_k(t_i), X_l(t_j)) (default: FALSE)}
}
\value{
A list containing the following fields:
\item{beta}{A matrix for the concurrent regression effects, where rows correspond to different predictors and columns to different time points.}
\item{beta0}{A vector containing the time-varying intercept.}
\item{outGrid}{A vector of the output time points.}
\item{cov}{A 4-dimensional array for the (cross-)covariance surfaces, with the (i, j, k, l) entry being Cov(X_k(t_i), X_l(t_j))}
\item{R2}{A vector of the time-varying R2.}
\item{n}{The sample size.}
}
\description{
Functional concurrent regression with dense or sparse functional data for scalar or functional dependent variables. Note: function-to-scalar regression can also be handled using the VCAM function in fdapace.
}
\details{
If measurement error is assumed, the diagonal elements of the raw covariance will be removed. This could result in highly unstable estimate if the design is very sparse, or strong seasonality presents. 
WARNING! For very sparse functional data, setting measurementError = TRUE is not recommended.
}
\examples{
# Y(t) = \beta_0(t) + \beta_1(t) X_1(t) + \beta_2(t) Z_2 + \epsilon

# Settings
set.seed(1)
n <- 75
nGridIn <- 150
sparsity <- 5:10 # Sparse data sparsity
T <- round(seq(0, 1, length.out=nGridIn), 4) # Functional data support
bw <- 0.1
outGrid <- round(seq(min(T), 1, by=0.05), 2)

# Simulate functional data 
mu <- T * 2 # mean function for X_1
sigma <- 1

beta_0 <- 0
beta_1 <- 1
beta_2 <- 1

Z <- MASS::mvrnorm(n, rep(0, 2), diag(2))
X_1 <- Z[, 1, drop=FALSE] \%*\% matrix(1, 1, nGridIn) + matrix(mu, n, nGridIn, byrow=TRUE)
epsilon <- rnorm(n, sd=sigma)
Y <- matrix(NA, n, nGridIn)
for (i in seq_len(n)) {
  Y[i, ] <- beta_0 + beta_1 * X_1[i, ] + beta_2 * Z[i, 2] + epsilon[i]
}

# Sparsify functional data
set.seed(1)
X_1sp <- Sparsify(X_1, T, sparsity)
set.seed(1)
Ysp <- Sparsify(Y, T, sparsity)
vars <- list(X_1=X_1sp, Z_2=Z[, 2], Y=Ysp)
withError2D <- FCReg(vars, bw, bw, outGrid)
}
\references{
\cite{Yao, F., M??ller, H.G., Wang, J.L. "Functional Linear Regression Analysis for Longitudinal Data." Annals of Statistics 33, (2005): 2873-2903.(Dense data)} 
\cite{Sent??rk, D., M??ller, H.G. "Functional varying coefficient models for longitudinal data." J. American Statistical Association, 10, (2010): 1256--1264.}
\cite{Sent??rk, D., Nguyen, D.V. "Varying Coefficient Models for Sparse Noise-contaminated Longitudinal Data", Statistica Sinica 21(4), (2011): 1831-1856. (Sparse data)}
}
