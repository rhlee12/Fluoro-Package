#' @title Perform PARAFAC Modeling on Corrected EEMs
#'
#' @author Robert Lee
#'
#' @details Given all input files and prarameters, this code performs EEM corrections as in the
#' orignial Matlab code. Only a corrected EEM is output, other functions should be invoked to plot the
#'  correctred EEM or to calculate indicies. Function assumes un-altered F4 files have not been
#'  altered to remove headers.
#'
#' @param \code{eem.file} - The filepath to the raw EEM file, a .dat file produced by a Flouromax F4.
#' @param \code{blank.file} - The filepath to the blank file corresponding to the raw EEM.
#' A .dat file produced by a Flouromax F4.
#' @param \code{uv.file} - The filpath to the UV-Vis abosrbance spectra for the raw eem being
#' corrected.
#' @param \code{raman.file} - The filepath to the blank file corresponding to the raw EEM.
#' A .dat file produced by a Flouromax F4.
#' @param \code{save.name} - The desired filename of the corrected EEM.
#' @param \code{save.dir} - Where the corrected eem (as a CSV) will be saved.
#' @param \code{dil.fact} - Optional, defaults to 1 (no dillution). Only anter a value reflecting your
#' dilution factor if the sample has been dilluted.
#' @param \code{uv.path.length} - Optional, defaults to 1 cm. Only enter this value if a different
#' cuvette size was used.
#'
#' @return A the corrected EEM, and a CSV of the EEM is also saved to the specified save directory.
#'
#' @examples
#' \dontrun{
#' abs.file=system.file("extdata", "abs.csv", package = "fluoro")
#' blank.file=system.file("extdata", "blank.dat", package = "fluoro")
#' eem.file=system.file("extdata", "eem.dat", package = "fluoro")
#' raman.file=system.file("extdata", "raman.dat", package = "fluoro")
#'
#' corr.eem=f4.eem.correct(eem.file, blank.file, abs.file, raman.file,
#' save.dir=tempdir(), save.name="corrected_eem")
#' }
#'
#' @export
#'

#### FUNCTION START ####

f4.eem.correct=function(eem.file, blank.file, abs.file, raman.file, save.name, save.dir, dil.fact=1, uv.path.length=1){
options(stringsAsFactors = F)
    #read in files
    raw.eem=read.delim(eem.file, header = F)
    blank=read.delim(blank.file, header = F)
    raman=read.delim(raman.file, header=F)
    uv=read.csv(abs.file, header = T)



#Guess at the increments for the EEM
    em.inc=as.numeric(raw.eem[4, 1])-as.numeric(raw.eem[3, 1]) # Emission increment-Reads the second emission wavelength minus the first, assuming header is present
    ex.inc=as.numeric(raw.eem[1, 3])-as.numeric(raw.eem[1, 2]) # Excitation increment-Reads the second emission wavelength minus the first, assuming header is present

    #generate
    em.seq=as.numeric(raw.eem[3:length(raw.eem[,1]), 1]) # HEADER IS NEEEDED
    ex.seq=as.numeric(raw.eem[1, 2:length(raw.eem)]) # HEADER IS NEEEDED

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

    trim.blank=blank[3:length(blank[,1]), 2:length(blank)]
    for(i in 1:length(trim.blank)){
        trim.blank[,i]=as.numeric(trim.blank[,i])
    }

    blank.normal.raman=trim.blank/raman.area

    trim.raw.eem=raw.eem[3:length(raw.eem[,1]), 2:length(raw.eem)]
    for(i in 1:length(trim.raw.eem)){
        trim.raw.eem[,i]=as.numeric(trim.raw.eem[,i])
    }

    waves=as.numeric(uv[3:length(uv[,1]),1]) ## ?? WAVES?

    trim.uv=uv[-1,]
    for(i in 1:length(trim.uv)){trim.uv[,i]=as.numeric(trim.uv[,i])}

    abs.254=trim.uv[trim.uv[,1]==254, 2]

    corrected.trim.uv=trim.uv
    corrected.trim.uv[,2]=corrected.trim.uv[,2]/uv.path.length

    ex.abs=corrected.trim.uv[corrected.trim.uv[,1] %in% ex.seq,2]
    em.abs=corrected.trim.uv[corrected.trim.uv[,1] %in% em.seq,2]

    ### IFC Stuff
    IFC=data.frame(matrix(data=NA, nrow=length(em.abs), ncol = length(ex.abs)))

    for(ex in 1:length(ex.abs)){
        for(em in 1:length(em.abs)){
            IFC[em, ex]=em.abs[em]+ex.abs[ex]
        }
    }

    Aci=trim.raw.eem*10^(0.5*IFC)
    Acir=Aci/raman.area
    Asub=Acir-blank.normal.raman

    ## Perform dillution factor
    corr.eem=Asub*dil.fact

    rownames(corr.eem)=em.seq ## ADDS LABELS to CORR EEM
    colnames(corr.eem)=ex.seq ## ADDS LABELS to CORR EEM

    ## Old code returns EEMs to 2 digits- do that here?
    corr.eem=round(corr.eem, digits = 2)

    write.csv(corr.eem, file = paste0(save.dir, "/", save.name, ".csv"), row.names = T)
    return(corr.eem)
}
