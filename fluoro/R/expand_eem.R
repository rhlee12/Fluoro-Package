#' @title Expand an EEM into a 1 nm resolution size
#'
#' @author Robert Lee
#'
#' @details For an EEM of any whole nanometer resolution, perform a spline interpolation on both
#' dimensions of the EEM to expand the EEM into a 1 nm resolution data frame. Warning- this function
#' differs slightly from the interp2 function used in original Matlab code.
#'
#' @param \code{eem} - An eem with row names and column names
#'  corresponding to the excitation/emission wavelengths. If the eem has been corrected by the fluoro
#'  package, then it can be loaded with the \code{read.corr.eem} function.
#'
#'
#' @return Returns the expanded EEM as a data frame
#'
#' @example
#' \dontrun{
#' eem=corr.eem
#' expanded.eem=expand.eem(eem)
#' }
#'
#' @export
#'

expand.eem=function(eem){

    temp.exp=lapply(seq(from=300, to=600, by=2),
                    function(u)
                        akima::aspline(x=as.numeric(colnames(eem)),
                                       y = eem[rownames(eem)==u,],
                                       xout = seq(from=240, to = 450, by=1)
                        )
    )

    temp.exp=lapply(temp.exp, "[[", "y")

    temp.exp.2=data.frame(do.call(rbind, temp.exp))

    colnames(temp.exp.2)=seq(from=240, to=450, by=1)
    row.names(temp.exp.2)= seq(from=300,  to=600, by=2)

    rough.exp=lapply(seq(from=240, to=450),
                     function(u)
                         akima::aspline(x=as.numeric(rownames(temp.exp.2)),
                                        y = temp.exp.2[,colnames(temp.exp.2)==u],
                                        xout = seq(from=300, to = 600, by=1)
                         )
    )
    temp.exp=lapply(rough.exp, "[[", "y")

    expanded.eem=data.frame(do.call(cbind, temp.exp))
    colnames(expanded.eem)=seq(from=240, to=450, by=1)
    row.names(expanded.eem)= seq(from=300,  to=600, by=1)

    return(expanded.eem)
}
