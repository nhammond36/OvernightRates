
# r2d3: https://rstudio.github.io/r2d3
#


    
# Example function
# add_numbers <- function(a, b) {
#   sum <- a + b
#   return(sum)
# }
# 
# # Save the function to a binary file
# save(olsgmm, file = "olsgmm.Rdata")
# source("C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Code/olsgmmv2.R")
#save(olsgmmv2, file = "C:/Users/Zenobia/Documents/Research/MonetaryPolicy/MonetaryPolicy/Code/olsgmmv2.R") 

 olsgmmv2 <- function(
    lhv,
    rhv,
    lags,
    weight){
      
    
    # --------------------------------------------------------------------------------     
    ## % function olsgmm does ols regressions with gmm corrected standard errors
    ## % Inputs:
    ## %  lhv T x N vector, left hand variable data 
    ## %  rhv T x K matrix,N< right hand variable data
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
    print(lhv)
    print(nrow(lhv))
    print(nrow(rhv))
    print('Is error here 1')
    # ----- check we can do the analysis
    if (nrow(lhv) != nrow(rhv)){
      print(nrow(lhv))
      print(nrow(rhv))
      stop("# olsgmm: left and right sides must have same number of rows. Current rows are:\n",
           "  # ----- lhv .... ", nrow(lhv), "; rhv .... ", nrow(rhv), "\n")
    }
    
    # --------------------------------------------------------------------------------
    # ----- initialize
    res   = NULL
    #Ftest = matrix(NA, N, 3)
    
    lags = lags[1];
    ## weight=1 ;
    
    Tobs    = dim(rhv)[1];   # number or rows
    N       = dim(lhv)[2];   # number or columns
    K       = dim(rhv)[2];
    print(Tobs)
    print(N)
    print(K)
    #
    
    print(mean(lhv))
    print(ones(Tobs, 1))
    
    Ftest = matrix(NA, N, 3)
    print(Ftest)
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
      # dim(errv) [1] 1709    5
      # dim(bv)  [1] 6 5
      print(errv)
      #s2     = mean(errv^2) # dim(s2) NULL   s2 [1] 74.80025
      
      s2 =colMeans(errv^2,dim(errv))
      #EFFR      OBFR      TGCR      BGCR      SOFR 
      #33.14544  49.96864 104.78123 105.42146  80.68448 
      
      #colMeans(lhv,dim(lhv))
      #EFFR     OBFR     TGCR     BGCR     SOFR 
      #108.3745 104.8578 104.4833 105.6173 108.1761 
      vary   = lhv - ones(Tobs,1) %*% colMeans(lhv,dim(lhv)); # mean(lhv) [1] 106.3018
      
      
      # The code snippet you provided is written in R programming language. Let me break down the code for you:
      # lhv: This is a variable or a matrix that contains data. It represents the Left Hand Variable.
      # ones(Tobs, 1): This creates a column vector of ones with Tobs rows and 1 column. In R, ones() is not a built-in function, so this code is likely using a custom function or the user has defined the ones() function elsewhere in the code.
      # mean(lhv): This calculates the mean of the lhv matrix, which represents the mean of the Left Hand Variable.
      # %*%: This is the matrix multiplication operator in R.
      # Putting it all together, the code computes the variable vary, which represents the difference between the lhv matrix and the mean of the lhv matrix, where the mean is subtracted from each row of the lhv matrix. The result is a new matrix with the same dimensions as the original lhv matrix.
      # vary   = mean(vary^2);
      
      R2v    = t(1-s2/vary); # dim(R2v)  [1]    5 1709
      R2vadj = t( 1 - (s2/vary) * (Tobs-1)/(Tobs-K) );
      
      #mean(lhv)
      
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
      print(list_res)
      
    } # end of else clause
    
    return(list_res)
  }