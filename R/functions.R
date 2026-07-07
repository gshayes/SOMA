#========================================================================================================================
#FUNCTIONS

#' Fixed Effects SO MA of overlapping studies
#'
#' @param ES Effect sizes from the meta analyses
#' @param SE Standard errors corresponding to the effect sizes
#' @param cor_mat Correlation matrix of the effect sizes
#'
#' @returns 
#' * `Mean ES` mean effect size estimate
#' 
#' * `SE` standard error
#' 
#' * `Q` test statistic of test for heterogeneity
#' 
#' * `df` degrees of freedom of test for heterogeneity
#' 
#' * `p` p-value of test for heterogeneity
#' @export
somaf <- function(ES, SE, cor_mat) {
  
  # number of MAs
  k = length(ES)
  
  # vector of 1s
  O = matrix(nrow = k, ncol = 1, data = 1)
  O_t = t(O)
  
  # initialize Sigma matrix
  Sig = matrix(nrow = k, ncol = k)
  
  # fill in Sigma values with variances and covariances
  for (i in 1:k) {
    for (j in 1:k) {
      if(i==j) { Sig[i,j] = SE[i]^2} else { 
        Sig[i,j] = cor_mat[i,j] * SE[i] * SE[j] }
    }
  }
  
  # solve for inverse Sigma
  Sig_inv = solve(Sig)
  
  # compute mean effect size (this is equation 44)
  mu_hat = (O_t %*% Sig_inv %*% ES) / (O_t %*% Sig_inv %*% O)
  
  # compute variance of the estimator (this is equation 45)
  V_mu_hat = 1 / (O_t %*% Sig_inv %*% O)
  
  # compute standard error of the estimator 
  SE_mu_hat = sqrt(V_mu_hat)
  
  # compute Q (this is equation 46)
  Q = t(ES) %*% Sig_inv %*% ES - (O_t %*% Sig_inv %*% ES)^2 / (O_t %*% Sig_inv %*% O)
  
  # compute degrees of freedom for chi-square distribution
  df = k-1
  
  # compute p-value for heterogeneity test
  pvalue <- pchisq(q=Q, df=df, lower.tail=FALSE)
  
  # print out results
  ANS <- matrix(nrow=1,ncol=5)
  colnames(ANS) <- c("Mean ES", "SE","Q","df", "p" )
  
  ANS[1] <- mu_hat
  ANS[2] <- SE_mu_hat
  ANS[3] <- Q
  ANS[4] <- df
  ANS[5] <- pvalue
  return(ANS)
}

#' Random Effects SO MA of overlapping studies
#'
#' @param ES Effect sizes from the meta analyses
#' @param SE Standard errors corresponding to the effect sizes
#' @param cor_mat Correlation matrix of the effect sizes
#' @param iter Number of iterations
#' @param type ML or REML
#'
#' @returns 
#' * `Mean ES` mean effect size estimate
#' 
#' * `SE_KH` standard error with Knapp-Hartung adjustment
#' 
#' * `Q` test statistic of test for heterogeneity
#' 
#' * `df` degrees of freedom of test for heterogeneity
#' 
#' * `p` p-value of test for heterogeneity
#' 
#' * `tau` measure of heterogeneity from ML or REML estimation
#' 
#' * `tau_MM` measure of heterogeneity from MOM estimation
#' 
#' * `SE_model` model based standard error
#' @export
somar <- function(ES, SE, cor_mat, iter, type) {
  
  # initial fixed-effect results
  fix_results  = somaf(ES, SE, cor_mat)
  mu  = fix_results[1]
  Q   = fix_results[3]
  df  = fix_results[4]
  p   = fix_results[5]
  
  # number of meta-analyses
  k = length(ES)
  
  # vector of 1s
  O = matrix(nrow = k, ncol = 1, data = 1)
  O_t = t(O)
  
  # starting value for tau^2
  tau2 = 0
  
  # create covariance matrix under fixed model
  Sigma_F <- outer(SE, SE)*cor_mat
  diag(Sigma_F) <- SE^2
  
  # create covariance matrix under random model (this is equation 49)
  Sig <- Sigma_F
  diag(Sig) <- diag(Sigma_F) + tau2
  
  # store iteration estimates
  iter_store = matrix(nrow = iter, ncol = 3)
  
  # begin iteration
  for (t in 1:iter) {
    
    # This is equation (56)
    Sig_inv = solve(Sig)
    V_mu = 1 / (O_t %*% Sig_inv %*% O)
    W = O_t %*% Sig_inv
    
    # REML correction term (this is equation 55)
    REML_correction = 0
    if (type == "REML") {
      REML_correction = 1 / (W %*% O)
    }
    
    # update tau^2 estimator (this is equation 54)
    tau2 = sum(W^2 * ((ES - mu)^2 - SE^2)) / sum(W^2) + REML_correction
    tau2 <- max(0, as.numeric(tau2))
    
    # update Sig
    Sig <- Sigma_F
    diag(Sig) <- diag(Sigma_F) + tau2
    
    # now compute mean effect size (this is equations (50) and (51))
    mu <- as.numeric(O_t %*% Sig_inv %*% ES / (O_t %*% Sig_inv %*% O))
    SE_mu <- sqrt(as.numeric(1 / (O_t %*% Sig_inv %*% O)))
    
    # store progress
    tau = ifelse(tau2 >= 0, sqrt(tau2), 0)
    iter_store[t, 1] = mu
    iter_store[t, 2] = SE_mu
    iter_store[t, 3] = tau
  }
  
  # Compute the method of moments estimator of tau (this is equation (52))
  Sigma_F_inv <- solve(Sigma_F)
  tau2MM <- 0
  for (i in 1:k){tau2MM <- tau2MM +  Sigma_F_inv[i,i]}  
  tau2MM <- tau2MM - O_t%*%Sigma_F_inv%*%Sigma_F_inv%*%O/O_t%*%Sigma_F_inv%*%O
  tau2MM <- (Q - k +1)/tau2MM
  if (tau2MM < 0){tau2MM <- 0}
  tauMM <- sqrt(tau2MM)
  
  # Implement the Knapp-Hartung adjustment (these are equations 57 and 58)
  SigInv <- solve(Sig)
  c <- O_t%*%SigInv%*%O
  Qstar <- t(ES)%*%SigInv%*%ES - (O_t%*%SigInv%*%ES)^2/c
  
  # KH adjustment factor with minimum value of 1
  KH <- max(1, Qstar/(k-1))
  SE_model <- SE_mu
  SE_KH <- SE_mu*sqrt(KH)
  
  # output results
  ANS = matrix(nrow = 1, ncol = 8)
  colnames(ANS) = c("Mean_ES", "SE_KH", "Q", "df", "p", "tau","tauMM", "SE_model")
  
  ANS[1] = mu
  ANS[2] = SE_KH
  ANS[3] = Q
  ANS[4] = df
  ANS[5] = p
  ANS[6] = tau
  ANS[7] = tauMM
  ANS[8] = SE_model
  return(ANS)
}
