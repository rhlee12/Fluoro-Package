fi.calc=function(corr.eem){
  FI=corr.eem[row.names(corr.eem)==470, colnames(corr.eem)==370]/corr.eem[row.names(corr.eem)==520, colnames(corr.eem)==370]
  return(FI)
}
