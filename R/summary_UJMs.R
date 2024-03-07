#' summary_UJMs function
#'
#'
#' @description
#' Compute summary statistics for one-marker or two-marker joint models.
#'
#'
#' @details
#' It present the summary statistics for one-marker or two-marker joint models.
#'
#'
#' @param UDPObject an object of class 'UDP' fitted by function UDP().
#' @param num_marker Number of marker for presenting the summary statistics. If num_marker="All", the summaries of all markers will be given.
#'
#' @return
#' - Summary_UJM: summary statistics for each joint model (one-marker or two-marker).
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

summary_UJMs=function(UDPObject,num_marker=2){
  Summary_UJM=c()
  if(num_marker=="All"){
    Summary_UJM=UDPObject[[2]]
  }else{
    Summary_UJM=UDPObject[[2]][[num_marker]]
  }
;Summary_UJM
}

