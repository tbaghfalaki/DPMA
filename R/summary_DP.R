#' summary_DP function
#'
#'
#' @description
#' Compute the risk prediction base on  one-marker or two-marker model averaging.
#'
#'
#' @details
#' It present the risk prediction base on  one-marker or two-marker model averaging.
#'
#'
#' @param UDPObject an object of class 'UDP' fitted by function UDP().
#'
#' @return
#' - DP: The values of dynamic prediction by utilizing model averaging for validation set (complement of training set) for each landmark time.
#' - sd_Wald1: standard errors of the dynamic prediction based on Wald 1 approach.
#' - sd_Wald2: standard errors of the dynamic prediction based on Wald 2 approach.
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

summary_DP=function(UDPObject){
  n_dp=dim(UDPObject$RESULTS[[1]]$mpi)[[1]]
  length_S=length(UDPObject$RESULTS[[1]]$S)
  wdp=sd1=sd2=matrix(0,n_dp,length_S)
  for(j in 1:length_S){
  wdp[,j]=UDPObject$RESULTS[[j]]$dp
  Weight=UDPObject$RESULTS[[j]]$w
  Bias=UDPObject$RESULTS[[j]]$mpi-wdp[,j]
  sd1[,j]=  Weight%*%t(sqrt(Bias^2+UDPObject$RESULTS[[j]]$sdpi^2)) # Wald_1
  sd2[,j]=  sqrt(Weight%*%t(Bias^2+UDPObject$RESULTS[[j]]$sdpi^2)) # Wald_2
}
  Colnames=c()
  for(k in 1:length_S){
    Colnames[k]=paste("s=",k)
}

  colnames(wdp)=colnames(sd1)=colnames(sd2)=Colnames
    ;list(DP=wdp,sd_Wald1=sd1,sd_Wald2=sd2)
}

