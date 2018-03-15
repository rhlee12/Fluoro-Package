#' @title Perform PARAFAC Modeling on Corrected EEMs
#'
#' @author
#'
#' @details
#'
#' @param \code{} -
#'
#' @return
#'
#' @example
#'
#' #export when finished
#'
cut.th=20

run.parafac=function(corr.eem){

  ## STEP 1 - Expand the eem from 10 nm excitation incriments to 5 nm incr. This shouls be the equivalent of BigMatrix steps
  ex=seq(from=240, to=450, by=10)
  em=seq(from=300, to=550, by=2)

  ex.5=seq(from=240, to=450, by=5)

  temp.matrix=corr.eem[rownames(corr.eem) %in% em,colnames(corr.eem) %in% ex]

  temp=lapply(seq(length(em)), function(x) approx(x=as.numeric(temp.matrix[x,]), n = 43, method = "linear", f=0.5))

  y.list=data.frame(do.call(rbind, temp))$y

  expanded.eem=data.frame(do.call(rbind, y.list))
  rownames(expanded.eem)=em
  colnames(expanded.eem)=ex.5

  ## STEP 2 - EEMcutPB (overwrites values where emission data < exitation wavelength plus user value=NA, optionally plots output)
  for(i in 1:length(expanded.eem[,1])){
    ex.cut=as.numeric(rownames(expanded.eem[i,]))+cut.th
    expanded.eem[i, as.numeric(colnames(expanded.eem))<ex.cut]=NA
  }

  ## STEP 3 - Run the damn model already
  # Needs the expanded eem, number of factors to model on


  }


