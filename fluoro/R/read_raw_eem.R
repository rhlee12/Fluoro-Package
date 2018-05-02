read.raw.eem=function(file){
    raw=read.delim(file)
    rows=raw[,1][-1]
    clean.raw=raw[-1, -1]
    rownames(clean.raw)=rows
    colnames(clean.raw)=gsub(pattern = "X", replacement = "", x = colnames(clean.raw))
    for(i in 1:length(clean.raw)){class(clean.raw[,i])="numeric"}
    return(clean.raw)
}
