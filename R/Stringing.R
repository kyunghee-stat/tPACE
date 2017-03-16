#' Stringing for High-Dimensional data
#' 
#' @param X A matrix (n by p) of data, where X[i,] is the row vector of measurements for the ith subject.
#' @param Y A vector (n by 1), where Y[i] is the reponse associated with X[i,]
#' @param standardize A logical variable indicating whether standardization of the input data matrix is required, with default: FALSE.
#' @param disOptns A distance metric to be used, one of the following: "euclidean" (default), "correlation", "spearman", "hamming", "xycor" or "user". If specified as "xycor", the absolute difference of correlation between predictor and response is used. If specified as "user", a dissimilarity matrix for the argument "disMat" must be provided.
#' @param disMat A user-specified dissimilarity matrix, only necessary when "disOptns" is "user".
#' 
#' @return A list containing the following fields:
#' \item{Ly}{A list of n vectors, which are the random trajectories for all subjects identified by the Stringing method.}
#' \item{Lt}{A list of n time points vectors, at which corresponding measurements Ly are taken.}
#' \item{stringedPos}{A vector, indicating positions of corresponding predictors after stringing.}
#' \item{Xin}{A matrix, corresponding to the input data matrix.}
#' \item{Xstd}{A matrix, corresponding to the standardized input data matrix. It is NULL if standardize is FALSE.}
#' @examples
#' set.seed(1)
#' n <- 50
#' wiener = Wiener(n = n)[,-1]
#' p = ncol(wiener)
#' rdmorder = sample(size = p, x=1:p, replace = FALSE)
#' stringingfit = Stringing(X = wiener[,rdmorder], disOptns = "correlation")
#' diff_norev = sum(abs(rdmorder[stringingfit$stringedPos] - 1:p))
#' diff_rev = sum(abs(rdmorder[stringingfit$stringedPos] - p:1))
#' if(diff_rev <= diff_norev){
#'   stringingfit$stringedPos = rev(stringingfit$stringedPos)
#'   stringingfit$Ly = lapply(stringingfit$Ly, rev)
#' }
#' plot(1:p, rdmorder[stringingfit$stringedPos], pch=18); abline(a=0,b=1)
#' 
#' @references
#' \cite{Chen, K., Chen, K., Mueller, H. G., and Wang, J. L. (2011). "Stringing high-dimensional data for functional analysis." Journal of the American Statistical Association, 106(493), 275-284.}
#' @export

Stringing = function(X, Y = NULL, standardize = FALSE, disOptns = "euclidean", disMat = NA){
  # input check
  if(!(is.numeric(X) && is.matrix(X))){
    stop('Incorrect format for input data matrix X! Check if it is a matrix.')
  }
  if(!(disOptns %in% c("euclidean", "correlation", "spearman", "hamming", "xycor", "user"))){
    stop('Invalid distance option specified! Need to be one of "euclidean", "correlation", "spearman", "hamming" and "user".')
  }
  if(disOptns == "user" && is.na(disMat)){
    stop('User specified dissimilarity matrix is missing, which is required for distance option "User".')
  }
  if(disOptns == "xycor"){
    if(is.null(Y)){
      stop('Missing response vector Y, required when disMat is "xycor".')
    }
    if(!(is.numeric(Y) && is.vector(Y))){
      stop('Incorrect format for input response vector Y! Check if it is a vector.')
    }
    if(length(Y) != nrow(X)){
      stop('Incosistent sample size based on input design matrix X and response vector Y.')
    }
  }
  # Standardization of the input data X
  Xin = X
  if(standardize){
    Xstd = t(t(X) - colMeans(X)) %*% diag((1/sqrt(diag(cov(X)))), nrow = ncol(X))
    X = Xstd
  } else {
    Xstd = NULL
    X = Xin
  }
  
  # Calculate dissimilarity matrix
  n = nrow(X); p = ncol(X);
  if(disOptns != "user"){
    disMat = GetDisMatrix(X, disOptns, Y)
  } else { # check if the user-specified dissimilarity matrix is a well-defined
    if(!(isSymmetric(disMat) && sum(disMat > 0) == p*(p-1) && sum(abs(diag(disMat))) == 0)){
      stop("User-specified dissimilarity matrix is not valid!")
    }
  }
  
  # UDS
  uds = MASS::isoMDS(d = disMat, k = 1, trace = FALSE)
  pts = uds$points
  stringedPos = order( (pts - min(pts))/diff(range(pts)) )

  # obtain stringed data
  stringedX = X[,stringedPos]
  stringedTime = 1:p
  fpcainput = MakeFPCAInputs(IDs = rep(seq_len(n),times=p), tVec = rep(stringedTime, each=n),
                             yVec = c(stringedX))
  Ly = fpcainput$Ly
  Lt = fpcainput$Lt
  stringingObj <- list(Ly = Ly, Lt = Lt, stringedPos = stringedPos, Xin = Xin, Xstd = Xstd)
  class(stringingObj) <- "Stringing"
  return(stringingObj)
}


# function to get dissimilarity matrix for given data matrix
GetDisMatrix = function(X, disOptns = "euclidean", Y){
  p = ncol(X); n = nrow(X);
  if(disOptns == "euclidean"){
    disMat = dist(x = t(X), method = "euclidean")
  } else if(disOptns == "correlation"){
    disMat = sqrt(2*(1 - cor(X)))
  } else if(disOptns == "spearman"){
    rankX = X
    for(i in 1:p){
      rankX[,i] = rank(X[,i])
    }
    disMat = 1 - cor(rankX)
  } else if(disOptns == "hamming"){
    disMat = matrix(NA, nrow = p, ncol = p)
    for(i in 1:p){
      for(j in i:p){
        disMat[i,j] = sum(X[,i] != X[,j])/n
        if(j > i){
          disMat[j,i] = disMat[i,j]
        }
      }
    }
  } else { # xy correlation
    disMat = matrix(NA, nrow = p, ncol = p)
    XYcor = cor(cbind(Y,X))[-1,1] # the correlation vector of Xj's and Y, j=1,...,p
    for(i in 1:p){
      for(j in i:p){
        disMat[i,j] = abs(XYcor[i] - XYcor[j]);
        disMat[j,i] = disMat[i,j];
      }
    }
  }
  return(disMat)
}