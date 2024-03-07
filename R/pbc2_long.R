#' Longitudinal data of Mayo Clinic primary biliary cirrhosis data
#'
#' This data is from the Mayo Clinic trial in primary biliary cirrhosis (PBC) of the liver conducted between 1974 and 1984. A total of 424 PBC patients, referred to Mayo Clinic during that ten-year interval met eligibility criteria for the randomized placebo controlled trial of the drug D-penicillamine, but only the first 312 cases in the data set participated in the randomized trial. Therefore, the data here are for the 312 patients with largely complete data.
#'
#' @name pbc2_long
#' @format A list which contains a data frame.
#' \describe{
#'   \item{id}{patients identifier; in total there are 312 patients.}
#'   \item{year}{number of years between enrollment and this visit date, remaining values on the line of data refer to this visit.}
#'   \item{spiders}{a factor with levels No and Yes.}
#'   \item{albumin}{albumin in mg/dl.}
#'   \item{alkaline}{alkaline phosphatase in U/liter.}
#' }
#' @references
#' \enumerate{
#' \item
#' Hashemi, R., Baghfalaki, T., Philipps, V., and Jacqmin-Gadda, H. (2023). Dynamic prediction of an event using multiple longitudinal markers: a model averaging approach. \emph{Revised}.
#' }
#' @seealso \code{\link{DPMA}}
"pbc2_long"


