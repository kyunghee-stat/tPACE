#' Creates a correlation surface plot based on the results from FPCA() or FPCder().
#'
#' This function will open a new device if not instructed otherwise.
#'
#' @param fpcaObj returned object from FPCA().
#' @param covPlotType a string specifying the type of covariance surface to be plotted:
#'                     'Smoothed': plot the smoothed cov surface 
#'                     'Fitted': plot the fitted cov surface
#' @param corr a boolean value indicating whether to plot the fitted covariance or correlation surface from the fpca object
#'                      TRUE: fitted correlation surface;
#'                      FALSE: fitted covariance surface;
#'                      default is FALSE; 
#'                      Only plotted for fitted fpca objects
#' @param isInteractive an option for interactive plot:
#'                      TRUE: interactive plot; FALSE: printable plot
#' @param colSpectrum character vector to be use as input in the 'colorRampPalette' function defining the colouring scheme (default: c('blue','red'))
#' @param ... other arguments passed into persp3d, persp3D, plot3d or points3D for plotting options
#'
#' @examples
#' set.seed(1)
#' n <- 20
#' pts <- seq(0, 1, by=0.05)
#' sampWiener <- Wiener(n, pts)
#' sampWiener <- Sparsify(sampWiener, pts, 10)
#' res <- FPCA(sampWiener$Ly, sampWiener$Lt, 
#'             list(dataType='Sparse', error=FALSE, kernel='epan', verbose=TRUE))
#' CreateCovPlot(res) ##plotting the covariance surface
#' CreateCovPlot(res, corr = TRUE) ##plotting the correlation surface
#' @export

CreateCovPlot = function(fpcaObj, covPlotType = 'Fitted', corr= FALSE, isInteractive = FALSE, colSpectrum = NULL, ...){
  if(corr == TRUE){
    if(toString(class(fpcaObj)) != 'FPCA'){
      stop("Input object must be class: 'FPCA' for fitted correlation surface")
    }
    if(covPlotType != 'Fitted'){
      stop("Correlation surface is computed only for the positive definite fitted covariance surface")
    }
    if(is.null(fpcaObj$fittedCorr)){
      stop("Correlation cannot be computed- covariance matrix has zero diagonals.")
    }
    corrSurf = fpcaObj$fittedCorr
    
  } else{
    if(!(class(fpcaObj) %in% c('FPCA','FSVD','FPCAder'))){
      stop("Input object must be class: 'FPCA','FSVD' or 'FPCAder'.")
    }
    if('FSVD' == class(fpcaObj)){
      if('Fitted' != covPlotType){
        stop("Only 'Fitted' cross-covariance is available when using FSVD objects.")
      }
      covPlotType == 'Fitted';
    }
    ## Check if plotting covariance surface for fitted covariance surface is proper
    if(covPlotType == 'Fitted'){
      no_opt = ifelse('FSVD' == class(fpcaObj), length(fpcaObj$sValues), length(fpcaObj$lambda))
      if(length(no_opt) == 0){
        warning('Warning: Input is not a valid FPCA, FSVD or FPCder output.')
        return()
      } else if(no_opt == 1){
        warning('Warning: Covariance surface is not available when only one principal component is used.')
        return()
      }
    }
    ## Define the variables to plot
    if(covPlotType == 'Smoothed'){
      covSurf = fpcaObj$smoothedCov # smoothed covariance matrix
    } else if(covPlotType == 'Fitted'){
      if('FSVD' == class(fpcaObj)){
        covSurf = fpcaObj$CrCov # fitted cross-covariance matrix
      } else {
        covSurf = fpcaObj$fittedCov # fitted covariance matrix
      }
    } else {
      warning("Covariance plot type no recognised; using default ('Fitted').")
      covSurf = fpcaObj$fittedCov 
      covPlotType = 'Fitted'
    }
  }
  if(is.null(colSpectrum)){
    colFunc = colorRampPalette( c('blue','red') );
  } else {
    colFunc = colorRampPalette(colSpectrum)
  } 
  
  ## Check if rgl is installed
  if (isInteractive == FALSE && !requireNamespace("plot3D", quietly=TRUE)) {#(!'plot3D' %in% installed.packages()[, ])
    stop("CreateCovPlot requires package 'plot3D'")
  }
  if(isInteractive == TRUE && !requireNamespace("rgl", quietly=TRUE)){#!is.element('rgl', installed.packages()[,1])
    stop("Interactive plot requires package 'rgl'")
  }
  
  ## Define the plotting arguments
  args1 <- list( xlab='s', ylab='t', col =  colFunc(24), zlab = 'C(s,t)', lighting=FALSE)
  if( covPlotType == 'Fitted' ){
    if('FSVD' == class(fpcaObj)){
      args1$main = 'Fitted cross-covariance surface';
    } else {
      if(corr == FALSE){
        args1$main = 'Fitted covariance surface';
      }
      else if(corr == TRUE){
        if(is.null(fpcaObj$fittedCorr)){
          stop("Correlation cannot be computed-covariance matrix has zero diagonals.")
        } else{
        args1$main = 'Fitted correlation surface';
        }
      }
    }
  } else {
    args1$main = 'Smoothed covariance surface';
  }
  if (isInteractive){ # If is interactive make it blue instead of topological
    args1$col = 'blue'
  }
  inargs <- list(...)
  args1[names(inargs)] <- inargs 
  if('FSVD' == class(fpcaObj)){
    if(corr == FALSE){
      args2 = list (x = fpcaObj$grid1, y = fpcaObj$grid2, z = covSurf)
    }
    else if(corr == TRUE){
      if(is.null(fpcaObj$fittedCorr)){
        stop("Correlation cannot be computed-covariance matrix has zero diagonals.")
      } else{
        args2 = list (x = fpcaObj$grid1, y = fpcaObj$grid2, z = corrSurf)
      }
    }
    
  } else {
    workGrid = fpcaObj$workGrid
    if(corr == FALSE){
      args2 = list (x = workGrid, y = workGrid, z = covSurf)
    }
    else if(corr == TRUE){
      if(is.null(fpcaObj$fittedCorr)){
        stop("Correlation cannot be computed-covariance matrix has zero diagonals.")
      } else{
          args2 = list (x = workGrid, y = workGrid, z = corrSurf)
      }
    }
    
  }
  
  ## Plot the thing
  if(isInteractive){ # Interactive Plot 
    do.call(rgl::persp3d, c(args2, args1)) 
  } else { # Static plot 
    do.call(plot3D::persp3D, c(args2, args1))    
  }  
}
