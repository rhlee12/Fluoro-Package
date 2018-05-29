gen.seq=function(raw.eem){
    em=as.numeric(raw.eem[3:length(raw.eem[,1]), 1]) # HEADER IS NEEEDED
    ex=as.numeric(raw.eem[1, 2:length(raw.eem)]) # HEADER IS NEEEDED
    return(list(em=em,ex=ex))
}

raman.correct=function(raman){

    raman.begin=as.numeric(raman[3,1]) #raman start wavelenth
    raman.end=as.numeric(raman[length(raman[,1]),1]) # raman end wavelength
    no.head.raman=raman[3:length(raman[,1]),]
    #trim.raman=as.numeric(raman[-c(1,2),]) #USE FULL SCAN?

    trim.raman=data.frame(no.head.raman[which(as.numeric(no.head.raman[,1])>=370),]) #pegged at a start of 370 nm
    for(i in 1:length(trim.raman)){
        trim.raman[,i]=as.numeric(trim.raman[,i])
    }
    r.sum=0

    for( i in 1:(length(trim.raman[,1])-1)){ #This integrates from RamanBegin to RamanEnd.
        y0 = as.numeric(trim.raman[i, 3])
        y1 = as.numeric(trim.raman[i+1, 3])
        dx = as.numeric(trim.raman[i+1, 1]) - as.numeric(trim.raman[i, 1])
        r.sum = r.sum + dx * (y0 + y1)/2;
    }

    base.rect=(trim.raman[1,3]+trim.raman[length(trim.raman[,1])-1,1])/2*(trim.raman[length(trim.raman[,1])-1,1]-trim.raman[1,1])

    raman.area=r.sum-base.rect

    return(raman.area)
}

# Normailize the blank to the raman (F4 only)
# Takes a blank file and raman.area, the output of raman.correct
blank.raman.norm=function(blank, raman.area){
    trim.blank=blank[3:length(blank[,1]), 2:length(blank)]
    for(i in 1:length(trim.blank)){
        trim.blank[,i]=as.numeric(trim.blank[,i])
    }

    blank.normal.raman=trim.blank/raman.area
    return(blank.normal.raman)
}

ifc=function(raw.eem, corrected.trim.uv){
    seq=fluoro:::gen.seq(raw.eem)

    ex.abs=corrected.trim.uv[corrected.trim.uv[,1] %in% seq$ex,2]
    em.abs=corrected.trim.uv[corrected.trim.uv[,1] %in% seq$em,2]
    #empty data frame
    IFC=data.frame(matrix(data=NA, nrow=length(seq$em), ncol = length(seq$ex)))

    for(ex in 1:length(ex.abs)){
        for(em in 1:length(em.abs)){
            IFC[em, ex]=em.abs[em]+ex.abs[ex]
        }
    }
    return(IFC)
}


##Emission Excitation Correction for F2/F3 EEM-like objects
em.ex.corr=function(eem, em.corr.file, ex.corr.file){
    em.corr = as.numeric(unlist(readxl::read_excel(em.corr.file, col_names = F)))  #Emission Correction
    ex.corr = as.numeric(unlist(readxl::read_excel(ex.corr.file, col_names = F))) #Excitation Correction

    Y=diag(em.corr)
    X=diag(ex.corr)

    int.eem=t(as.matrix(eem) %*% X) # Make sure all this squares w/ Matlab code
    corr.eem=data.frame(t(int.eem %*% Y)) # Make sure all this squares w/ Matlab code
    ic.eem=corr.eem %>% `colnames<-`(value=colnames(eem)) %>% `rownames<-`(value=rownames(eem))

    return(ic.eem)
}
