#' @title Read in a Corrected EEM
#'
#' @author Robert Lee
#'
#' @details This file reads in the corrected EEMs produced by "f4.eem.correct",
#' and correctly formats it for use with other functions in the 'fluoro' package.
#'
#' @param \code{file} - A character path pointing to the corrected eem file.
#' File should be a CSV, typically output by the f4.eem.correct function.
#'
#' @return A properly formatted EEM, as a data frame.
#'
#' @example
#'
#' \dontrun{
#' file=system.file("extdata", "corr_eem.csv", package = "fluoro")
#' eem=read.corr.eem(file)
#' }
#'
#' @export
#'

read.corr.eem=function(file){
  temp.eem=read.csv(file=file)
  row.names=temp.eem[,1]
  col.names=gsub(pattern = "X", replacement = "", x = colnames(temp.eem))[-1]

  corr.eem=temp.eem[,-1]
  rownames(corr.eem)=row.names
  colnames(corr.eem)=col.names
  return(corr.eem)
}
