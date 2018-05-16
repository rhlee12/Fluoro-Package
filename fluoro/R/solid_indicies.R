#' @title Make a File of Summary Indicies Used in Analyzing Solid-state EEMs
#'
#' @author Robert Lee
#'
#' @details Given all input files and prarameters, this code produces summary indicies for the corrected
#' eem. The specifically, maximium emission at 370 nm excitation,
#' the fluorescence Index (FI), Humification Index, and Freshness Index are returned in the output file.
#' For specifics of on the calculation of FI, HIX, Freshness, see the following help files:
#' \enumerate{
#'   \item \code{\link{fi.calc}}
#'   \item \code{\link{hix.calc}}
#'   \item \code{\link{fresh.calc}}
#' }
#'
#'
#' @param \code{corr.eem} - A corrected eem, either the output of \code{f4.eem.correct} or \code{read.corr.eem}.
#' @param \code{sample} - The sample name associated with the EEM.
#' @param \code{save.dir} - Where the index file ("indicies.csv") will be saved.
#'
#' @return A CSV of the calculated indicies, with column names and the sample ID corresponding to the indicies.
#'  If a file of indicies already exists in the save.dir, the values for the current EEM will be appended.
#'
#' @examples
#' \dontrun{
#' #Save an example index file to the current working directory
#' corr.eem=fluoro::read.corr.eem(file=system.file("extdata", "corr_eem.csv", package = "fluoro"))
#'
#' fluoro::solid.indicies(uv.file=uv.file, sample="sample_name", save.dir=getwd())
#' }
#'
#' @export
#'

#### FUNCTION START ####

solid.indicies=function(corr.eem, sample, save.dir){
    options(stringsAsFactors = F)
    #uv=read.csv(uv.file, header = T)
    indicies=data.frame(
        Sample.ID=sample,
        # Abs.254=round(uv[uv[,1]=="254",2], digits = 3),
        Max.Em.370=max(corr.eem$`370`),
        FI=fluoro::fi.calc(corr.eem = corr.eem),
        HIX=fluoro::hix.calc(corr.eem = corr.eem),
        Freshness=fluoro::fresh.calc(corr.eem=corr.eem)
    )

    if(!file.exists(paste0(save.dir, "/ss_indicies.csv"))){
        write.csv(x = indicies, file = paste0(save.dir, "/ss_indicies.csv"), row.names = F)
    }
    if(file.exists(paste0(save.dir, "/ss_indicies.csv"))){
        temp=read.csv(file = paste0(save.dir, "/ss_indicies.csv"))
        indicies=rbind(temp, indicies)
        write.csv(x=indicies, file = paste0(save.dir, "/ss_indicies.csv"), row.names = F)
    }
}
