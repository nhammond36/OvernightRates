#! /usr/bin/R
#
# olsgmm.R
#
# This code is directly adapted from John Cochrane olsgmm.m matlab program
# See Cochrane's website:
# https://faculty.chicagobooth.edu/john.cochrane/teaching/35150_advanced_investments/olsgmm.m
#
# https://loualiche.gitlab.io/www/data/olsgmm.html
# Created       on December 14th 2016
# Last modified on December 14th 2016
#
# ---------------------------------------------------------


# ---------------------------------------------------------
olsgmm <- function(
    lhv,
    rhv,
    lags,
    weight = 1){
  
  # --------------------------------------------------------------------------------     
  ## % function olsgmm does ols regressions with gmm corrected standard errors
  ## % Inputs:
  ## %  lhv T x N vector, left hand variable data 
  ## %  rhv T x K matrix, right hand variable data
  ## %  If N > 1, this runs N regressions of the left hand columns on all the (same) right hand variables. 
  ## %  lags number of lags to include in GMM corrected standard errors
  ## %  weight: 1 for newey-west weighting 
  ## %          0 for even weighting
  ## %         -1 skips standard error computations. This speeds the program up a lot; used inside monte carlos where only estimates are needed
  ## %  NOTE: you must make one column of rhv a vector of ones if you want a constant. 
  ## %        should the covariance matrix estimate take out sample means?
  ## % Output:
  ## %  b: regression coefficients K x 1 vector of coefficients
  ## %  seb: K x N matrix standard errors of parameters. 
  ## %      (Note this will be negative if variance comes out negative) 
  ## %  v: variance covariance matrix of estimated parameters. If there are many y variables, the vcv are stacked vertically
  ## %  R2v:    unadjusted
  ## %  R2vadj: adjusted R2
  ## %  F: [Chi squared statistic    degrees of freedom    pvalue] for all coeffs jointly zero. 
  ## %   Note: program checks whether first is a constant and ignores that one for test
  # --------------------------------------------------------------------------------
  
  
  
  # ----- required packages
  library('matlab');
  
  
  lhv <- as.matrix(lhv)
  rhv <- as.matrix(rhv)     
  
  # ----- check we can do the analysis
  if (nrow(lhv) != nrow(rhv)){
    stop("# olsgmm: left and right sides must have same number of rows. Current rows are:\n",
         "  # ----- lhv .... ", nrow(lhv), "; rhv .... ", nrow(rhv), "\n")
    
  }
  
  # --------------------------------------------------------------------------------
  # ----- initialize
  res   = NULL
  Ftest = matrix(NA, N, 3)
  
  lags = lags[1];
  ## weight=1 ;
  
  Tobs    = dim(rhv)[1];   # number or rows
  N       = dim(lhv)[2];   # number or columns
  K       = dim(rhv)[2];
  
  sebv    = matrix(0,K,N)
  Exxprim = solve( t(rhv) %*% rhv / Tobs);
  bv      = solve( t(rhv) %*% rhv ) %*% t(rhv) %*% lhv;
  
  # --------------------------------------------------------------------------------
  ## skip ses if you don't want them.  returns something so won't get error message
  if (weight == -1){  
    sebv    = NA;
    R2v     = NA;
    R2vadj  = NA;
    v       = NA;
    Ftest   = NA;
  }
  
  # --------------------------------------------------------------------------------
  ## now compute newey-west errors
  else {
    
    errv   = lhv - rhv %*% bv;
    s2     = mean(errv^2)
    vary   = lhv - ones(Tobs,1) %*% mean(lhv);
    vary   = mean(vary^2);
    
    R2v    = t(1-s2/vary);
    R2vadj = t( 1 - (s2/vary) * (Tobs-1)/(Tobs-K) );
    
    mean(lhv)
    
    indx = 1;
    
    # Compute GMM standard errors
    while(indx <= N){
      # debug
      ## indx = 1
      
      err   = as.matrix(errv[,indx]);
      inner = t(rhv * (err %*% matrix(1,1,K) ) ) %*% (rhv * (err %*% matrix(1,1,K)) ) / Tobs;
      jindx = 1;
      
      for(jindx in seq(1, lags)){
        
        startindx = 1 + jindx; endindx = Tobs - jindx;
        inneradd  = t(rhv[1:endindx,] * err[1:endindx] %*% matrix(1,1,K)) %*% (rhv[startindx:Tobs,] * err[startindx:Tobs] %*% matrix(1,1,K)) / Tobs;
        inner     = inner + (1-weight*jindx/(lags+1)) * (inneradd + t(inneradd) );
        
      }
      
      varb = 1/Tobs * Exxprim %*% inner %*% Exxprim;
      
      # F test for all coeffs (except constant) zero -- actually chi2 test
      if (identical(as.matrix(rhv[,1]), ones(dim(rhv)[1],1))){
        chi2val         = t( bv[2:nrow(bv), indx] ) %*% solve( varb[2:nrow(bv),2:nrow(bv)]) %*% bv[2:nrow(bv), indx];
        dof             = nrow(as.matrix(bv[2:nrow(bv), 1])) 
        ## pval            = 1-cdf('chi2',chi2val, dof);
        pval            = 1 - pchisq(chi2val, dof)
        Ftest[indx,1:3] = c(chi2val, dof, pval);
      } else {
        chi2val = t(bv[,indx]) %*% solve(varb) %*% bv[,indx];
        dof     = nrow(as.matrix(bv[, 1]))
        pval            = 1 - pchisq(chi2val, dof)            
        Ftest[indx,1:3] = c(chi2val, dof, pval);            
      }
      
      # -----------------------------------------------------------------------------
      if (indx == 1) {
        v = varb;
      } else {
        v = cbind(v,varb);
      }
      
      seb = diag(varb);
      seb = sign(seb) * sqrt(abs(seb));
      sebv[,indx] = seb;
      indx=indx+1;
      
    }
    
    # get results
    res$bv = bv
    res$sebv = sebv
    
    list_res <- list(bv, sebv, R2v, R2vadj, v, Ftest)
    
    
  } # end of else clause
  
  return(list_res)
}