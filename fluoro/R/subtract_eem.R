#' @title Subtract two Equal-Dimension EEMs
#'
#' @author Robert Lee
#'
#' @details Perfoms quailty checks before performing straight subtraction of the 's.eem' input from
#' 'p.eem' (p.eem=s.eem). If the 'neg.to.zero' parameter is set to TRUE, then negative values are
#' coerced to 0
#'
#' @param \code{p.eem} - An EEM to be subtracted from, either a raw or corrected EEM.
#' @param \code{s.eem} - An EEM to subtract from \code{p.eem}, either a raw or corrected EEM.
#' @param \code{neg.to.zero} - Optional, defaults to FALSE. IF set to TRUE, negative values are
#' coerced to 0.
#'
#' @return Corrected EEMs as CSVs saved in grouped subdirectories of a "corrected" subdirectory created
#'  in the specified input directory. An index file is also saved for the EEMs in the "corrected"
#'  folder. See \code{\link{make.indicies}} for details.
#'
#' @export
#'
#'

## TEST BLOCK
#p.eem=fluoro::read.corr.eem(file="../example_data/batch_correct/corrected/180103/A4420E_c.csv")
#s.eem=fluoro::read.corr.eem(file = "../example_data/batch_correct/corrected/180103/A4422E_c.csv")

subtract.eem=function(p.eem, s.eem, neg.to.zero=FALSE){
    p.dim=dim(p.eem)
    s.dim=dim(s.eem)

    if(!all(s.dim==p.dim)){stop("EEM dimensions do not match! Please verify inputs.")}

    diff=p.eem-s.eem

    if(neg.to.zero){
       diff[diff<0]=0
    }
    return(diff)
}
