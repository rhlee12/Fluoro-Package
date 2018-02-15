#test blox
file="../A4575E_c.csv"


read.corr.eem=function(file){
  temp.eem=read.csv(file=file)
  row.names=temp.eem[,1]
  col.names=gsub(pattern = "X", replacement = "", x = colnames(temp.eem))[-1]

  corr.eem=temp.eem[,-1]
  rownames(corr.eem)=row.names
  colnames(corr.eem)=col.names
  return(corr.eem)
}
