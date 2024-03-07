#' UDP function
#'
#'
#' @description
#' Compute dynamic prediction of an event using multiple longitudinal markers by applying a model averaging approach
#'
#'
#' @details
#' It uses a model averaging strategy to combine predictions from several joint models for the event, including one longitudinal marker only or pairwise longitudinal markers. The prediction is computed as the weighted mean of the predictions from the one- or two-marker models, with the time-dependent weights estimated by minimizing the time-dependent Brier score.
#'
#' @param Modelsurv a formula object, with the response on the left of a ~ operator, and the terms on the right. The response must be a survival object as returned by the Surv function.
#' @param Modelmvglmer a list of R formulas representing the mixed models; these should be lme4-type formulas. See Examples.
#' @param timeVar a character string indicating the time variable in the multivariate mixed effects model.
#' @param nmark a scalar for the number of outcomes.
#' @param ncl the number of nodes to be forked for parallel socket cluster.
#' @param families a list of families objects correspond to each outcome.
#' @param datalong a data.frame that contains all the variable to be used when fitting the multivariate mixed model.
#' @param datasurv a data.frame in which to interpret the variables named in the Modelsurv. The index of individual must be the same as those in datalong.
#' @param S a vector for landmark times.
#' @param W a vector for prediction windows.
#' @param index_training index of individuals for the training set.
#'
#' @return
#' - RESULTS: The values of dynamic prediction by utilizing model averaging for validation set (complement of training set).
#' - summaryJM_all: summary statistics for each joint model (one-marker or two-marker).
#' - Comp_time: Computational time.
#'
#'
#' @author Taban Baghfalaki.
#'
#' @references
#'  R. Hashemi, T. Baghfalaki, V. Philipps, H. Jacqmin-Gadda. (2021). Dynamic prediction of an event using multiple longitudinal markers: a model averaging approach. *Submitted*.
#'
#' @example inst/exampleUDP.R
#'
#' @md
#' @export

UDP <- function(Modelsurv, Modelmvglmer, timeVar, nmark = nmark, ncl = 5,
                families, S = S, W = W, index_training, datalong,
                datasurv) {
  # Index of training
  ind_1 <- index_training
  # rstan::rstan_options(auto_write = TRUE)
  # Fitting univariate JMs
  Cox <- survival::coxph(Modelsurv, data = datasurv[(datasurv$id %in% c(ind_1)), ], model = TRUE) ### Time to event sub-model
  
  startma <- Sys.time() ### For computing the computational time
  result <- list()
  for (j in 1:nmark) {
    M <- JMbayes::mvglmer(Modelmvglmer[[j]],
                          data = datalong[(datalong$id %in% c(ind_1)), ],
                          families = list(families[j]), 
                          control=list(n.processors=ncl)
    )
    JM <- JMbayes::mvJointModelBayes(M, Cox, timeVar = timeVar,
                                     control=list(n_cores=ncl)
    )
    result[[j]] <- list(JM = JM, summaryJM = summary(JM))
  }
  summaryJM_all <- list()
  for (j in 1:nmark) {
    summaryJM_all[[j]] <- result[[j]]$summaryJM
  }
  
  RESULTS <- list()
  for (jjj in 1:length(S)) { ### Risk prediction for the vector S
    s <- S[jjj]
    t <- W[jjj]
    # Computing DP for training data
    RES <- list()
    for (j1 in 1:nmark) {
      DP1 <- JMbayes::survfitJM(result[[j1]]$JM,
                                newdata = datalong[(datalong$id %in% c(ind_1)), ],
                                idVar = "id", last.time = s, survTimes = s + t
      )
      Matrix <- matrix(0, 200, length(ind_1))
      for (j in 1:200) {
        Matrix[j, ] <- 1 - unlist(DP1$full.results[[j]])
      }
      RES[[j1]] <- cbind(
        apply(Matrix, 2, mean),
        apply(Matrix, 2, stats::sd)
      )
    }
    
    a <- stats::model.frame(Modelsurv, data = datasurv)
    bextrep <- stats::model.extract(a, "response")
    NNN <- length(as.numeric(bextrep))
    
    surtime <- as.numeric(bextrep)[1:(NNN / 2)]
    deltatime <- as.numeric(bextrep)[(1 + (NNN / 2)):NNN]
    
    survt <- surtime[(datasurv$id %in% c(ind_1))]
    delta <- deltatime[(datasurv$id %in% c(ind_1))] # delta: 1=observed, 0=censored
    
    mpi <- matrix(0, length(ind_1), nmark)
    for (j in 1:nmark) {
      mpi[, j] <- RES[[j]][, 1]
    }
    
    ### Computing weight by minimizing Brier score
    BS_w <- function(w) {
      pi <- mpi %*% w
      n <- length(survt)
      I1 <- I2 <- I3 <- rep(0, n)
      I1[survt > s] <- 1
      I2[survt > (s + t)] <- 1
      I3[survt > s & survt < (s + t)] <- 1
      G1 <- nricens::get.surv.km(survt, delta, (s + t), subs = NULL) /
        nricens::get.surv.km(survt, delta, s, subs = NULL)
      G2 <- nricens::get.surv.km(survt, delta, survt, subs = NULL) /
        nricens::get.surv.km(survt, delta, s, subs = NULL)
      W <- I2 / G1 + (I3 * delta) / G2
      D <- I3 * delta
      BS_n <- sum(W * (D - pi)^2)
      BS_d <- sum(I1)
      BS <- BS_n / BS_d
      BS
    }
    eqn <- function(w) {
      sum(w)
    }
    optw <- Rsolnp::solnp(
      pars = rep(1 / nmark, nmark), BS_w, eqfun = eqn,
      eqB = 1,
      LB = rep(0, nmark),
      UB = rep(1, nmark), control = list(delta = 1.e-10, tol = 1.e-10)
    )
    w <- optw$pars
    
    
    ### DP for validation set
    RES1 <- list()
    for (j1 in 1:nmark) {
      DP1 <- JMbayes::survfitJM(result[[j1]]$JM,
                                newdata = datalong[!(datalong$id %in% c(ind_1)), ],
                                idVar = "id", last.time = s, survTimes = s + t
      )
      
      Matrix <- matrix(0, 200, length(datasurv[!(datasurv$id %in% c(ind_1)), 1]))
      for (j in 1:200) {
        Matrix[j, ] <- 1 - unlist(DP1$full.results[[j]])
      }
      
      RES1[[j1]] <- Matrix
    }
    mpi <- sdpi <- matrix(0, length(datasurv[!(datasurv$id %in% c(ind_1)), 1]), nmark)
    for (j in 1:nmark) {
      mpi[, j] <- apply(RES1[[j]], 2, mean)
      sdpi[, j] <- apply(RES1[[j]], 2, stats::sd)
    }
    dp <- w %*% t(mpi)
    ### Output for each s
    RESULTS[[jjj]] <- list(dp = w %*% t(mpi), mpi = mpi, sdpi = sdpi, w = w, S = S, nmark = nmark)
  }
  endma <- Sys.time()
  list(RESULTS = RESULTS, summaryJM_all = summaryJM_all, Comp_time = difftime(endma, startma, units = "mins"))
  
}
