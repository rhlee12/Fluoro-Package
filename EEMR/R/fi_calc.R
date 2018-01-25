fi.calc=function(corr.eem){
  FI=cor.eem[ex.seq==370, em.seq==470]/cor.eem[ex.seq==370, em.seq==520]
  return(FI)
}
