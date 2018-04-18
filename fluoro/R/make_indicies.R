#' @title Make a File of Summary Indicies Used in Analyzing EEMs
#'
#' @author Robert Lee
#'
#' @details Given all input files and prarameters, this code produces summary indicies for the corrected
#' eem. The specifically, the UV-Visible absorbance at 254 nm, maximium emission at 370 nm excitation,
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
#' @param \code{uv.file} - The filepath to the UV-Vis abosrbance spectra for the raw eem being
#' @param \code{save.dir} - Where the index file ("indicies.csv") will be saved.
#'
#' @return A CSV of the calculated indicies, with column names and the sample ID corresponding to the indicies.
#'  If a file of indicies already exists in the save.dir, the values for the current EEM will be appended.
#'
#' @examples
#' \dontrun{
#' #Save an example index file to the current working directory
#' uv.file=system.file("extdata", "abs.csv", package = "fluoro")
#' corr.eem=fluoro::read.corr.eem(file=system.file("extdata", "corr_eem.csv", package = "fluoro"))
#'
#' fluoro::make.indicies(uv.file=uv.file, corr.eem=corr.eem, save.dir=getwd())
#' }
#'
#' @export
#'

#### FUNCTION START ####

make.indicies=function(corr.eem, uv.file, save.dir){
    uv=read.csv(uv.file, header = T)
    sample=unlist(stringr::str_split(string = uv.file, pattern = "/"))
    sample=gsub(sample[length(sample)], replacement = "", pattern = ".csv", ignore.case = T)
    indicies=data.frame(
        Sample.ID=sample,
        Abs.254=round(uv[uv[,1]=="254",2], digits = 3),
        Max.Em.370=max(corr.eem$`370`),
        FI=fluoro::fi.calc(corr.eem = corr.eem),
        HIX=fluoro::hix.calc(corr.eem = corr.eem),
        Freshness=fluoro::fresh.calc(corr.eem=corr.eem)
    )

    if(!file.exists(paste0(save.dir, "/indicies.csv"))){
        write.csv(x = indicies, file = paste0(save.dir, "/indicies.csv"), row.names = F)
    }
    else if(file.exists(paste0(save.dir, "/indicies.csv"))){
        temp=read.csv(file = paste0(save.dir, "/indicies.csv"))
        indicies=rbind(temp, indicies)
        write.csv(x=temp, file = paste0(save.dir, "/indicies.csv"), row.names = F)
    }
}
