#' @title Mask Rayleigh Scatter
#'
#' @author Robert Lee
#'
#' @details Masks first and second order Rayleigh Scatter on the supplied EEM with the specified value
#' (defaulting to 0 if no value entered.)
#'
#' @param \code{eem} - A properly-formatted EEM, produced or read by a \code{fluoro} function.
#' @param \code{mask.value} - Optional, defaults to zero. The numeric value that values in the mask area should be forced to.
#' \strong{NA/NaN/NULL values will prevent ploting in \code{fluoro}!}
#'
#' @return A masked EEM with dimensions and names preserved.
#'
#' @export
#'
#'

rayleigh.mask=function(eem, mask.value=0){

    pri.math=function(x){(base::trunc(0.95*x*10^-1)/10^-1)-20}
    sec.math=function(x){(base::trunc(1.7*x*10^-1)/10^-1)+65}

    logi.matrix=as.data.frame(matrix(data=TRUE, nrow = dim(eem)[1], ncol=dim(eem)[2]))
    rownames(logi.matrix)=rownames(eem)
    colnames(logi.matrix)=colnames(eem)

    for(i in 1:nrow(logi.matrix)){
        for(j in 1:ncol(logi.matrix)){
            col=colnames(logi.matrix)[j]

            s.row.span= sec.math(as.numeric(col))
            row=as.numeric(rownames(logi.matrix)[i])
            start=as.numeric(rownames(logi.matrix)[1])
            stop=500#as.numeric(rownames(logi.matrix))
            logi.matrix[i,j]=(!(row %in% s.row.span:start))
            if(logi.matrix[i,j]){eem[i,j]=0}
        }
    }
    for(i in 1:nrow(logi.matrix)){
        for(j in 1:ncol(logi.matrix)){
            row=rownames(logi.matrix[i,])
            p.col.span=pri.math(as.numeric(row))

            col=as.numeric(colnames(logi.matrix[j]))
            start=as.numeric(colnames(logi.matrix[1]))
            stop=as.numeric(colnames(logi.matrix[length(logi.matrix)]))
            logi.matrix[i,j]=!(col %in% p.col.span:start)#&(!(col %in% s.col.span:start))
            if(logi.matrix[i,j]){eem[i,j]=mask.value}
        }
    }
return(eem)
}
