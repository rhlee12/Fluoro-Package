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
    ## VERY IMPORTANT!!
    options(stringsAsFactors = F)

    #read in files
    raw.eem=read.delim(eem.file, header = F)
    blank=read.delim(blank.file, header = F)
    raman=read.delim(raman.file, header=F)
    uv=read.csv(abs.file, header = T)

    raman.area=fluoro:::raman.correct(raman) #Generate the raman area

    blank.normal.raman=fluoro:::blank.raman.norm(blank, raman.area)

    # Clean up the EEM
    trim.raw.eem=raw.eem[3:length(raw.eem[,1]), 2:length(raw.eem)]
    for(i in 1:length(trim.raw.eem)){
        trim.raw.eem[,i]=as.numeric(trim.raw.eem[,i])
    }

    #clean up the UV-Vis abs file
    trim.uv=uv[-1,] #remove first row
    for(i in 1:length(trim.uv)){trim.uv[,i]=as.numeric(trim.uv[,i])}#convert all columns to numeric

    abs.254=trim.uv[trim.uv[,1]==254, 2] # from the trimmed uv file, find Abs @ 254 nm

    corrected.trim.uv=trim.uv
    corrected.trim.uv[,2]=corrected.trim.uv[,2]/uv.path.length #correct UV meas to path length

    #Set up inner filter correction
    IFC=fluoro:::ifc(raw.eem, corrected.trim.uv)

    #Perform EEM corrections w/ IFC, raman, and blank
    Aci=trim.raw.eem*10^(0.5*IFC)
    Acir=Aci/raman.area
    Asub=Acir-blank.normal.raman

    ## Perform dillution factor correction
    corr.eem=Asub*dil.fact

    rownames(corr.eem)=fluoro:::gen.seq(raw.eem)$em ## ADDS LABELS to CORR EEM
    colnames(corr.eem)=fluoro:::gen.seq(raw.eem)$ex ## ADDS LABELS to CORR EEM

    ## Old code returns EEMs to 2 digits- do that here?
    corr.eem=round(corr.eem, digits = 2)

    write.csv(corr.eem, file = paste0(save.dir, "/", save.name, ".csv"), row.names = T)
    return(corr.eem)
}
