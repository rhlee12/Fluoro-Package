raman.mask=function(){

    #??
    for(i in 1:length(expanded.eem[,1])){
        ex.cut=as.numeric(rownames(expanded.eem[i,]))+cut.th
        expanded.eem[i, as.numeric(colnames(expanded.eem))<ex.cut]=NA
    }
}
