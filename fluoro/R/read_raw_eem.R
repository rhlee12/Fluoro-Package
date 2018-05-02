#' @title Load a Raw EEM
#'
#' @author Robert Lee
#'
#' @details Loads a raw (uncorrected) EEM into R for use with other \code{fluoro} functions.
#'
#' @param \code{file} - The file path to the raw eem file. Should be tab-separated data.
#' @return An EEM in the format required by \code{fluoro}.
#'
#' @export
#'
#'

read.raw.eem=function(file){
    raw=read.delim(file)
    rows=raw[,1][-1]
    clean.raw=raw[-1, -1]
    rownames(clean.raw)=rows
    colnames(clean.raw)=gsub(pattern = "X", replacement = "", x = colnames(clean.raw))
    for(i in 1:length(clean.raw)){class(clean.raw[,i])="numeric"}
    return(clean.raw)
}
