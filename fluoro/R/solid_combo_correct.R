#' @title Batch Correcrt Solid State EEMs with Specifierd Combinations
#'
#' @author Robert Lee
#' @author Maggie Bowman
#'
#' @details - This function takes specified correction combinationsc specified in the file passed to
#'  \code{combo.file}, and performs the outlined corrections.
#'
#'
#' @param \code{corr.dir} - The directory where corrected EEMs live
#' @param \code{combo.file} - The spreadsheet (Excel or CSV) of desired combinations. Required columns:
#' \itemize{
#' \item{"Name of Raw EEM"}
#' \item{"Corrected Name"}
#' \item{"Notes Column"}
#' }
#'
#' @return Corrected EEMs are saved with concatenated file names a "corrected" subdirectory of the
#' path passed to \code{eem.dir}.\cr{}
#' The direct output to the parent environment is a list with objects \code{input} and \code{corr.dir}.
#' These outputs exist only for passing to another batch function of solid state EEMs, and can be
#' ignored if not needed.
#'
#' @example
#' \dontrun{
#' #NA right now
#' }
#'
#' @export
#'

solid.combo.correct=function(eem.dir, combo.file, f3.eem=F, em.corr.file, ex.corr.file){
    options(stringsAsFactors = F)

    if(grepl(pattern = ".csv", x = combo.file, ignore.case = T)){
        input=read.csv(file = combo.file)
    }else{
        message("Function assuming combo.file is an Excel file... (make sure you are pointing to a CSV or XLS file)")
        input=readxl::read_excel(path = combo.file)
    }

    input$Blank=stringr::str_split(input$Blank, pattern = ", ")

    save.dir=paste0(eem.dir, "/corrected/")
    if(!dir.exists(save.dir)){dir.create(save.dir)}

    for(i in 1:nrow(input)){
        if(f3.eem){
            sample=fluoro::read.f3.eem(f3.eem.file = paste0(eem.dir, "/", input$`Name of Raw EEM`[i], ".xls"))
            sample=fluoro:::em.ex.corr(eem = sample, em.corr.file = em.corr.file, ex.corr.file = ex.corr.file)

            corrections=input$Blank[i]
            print(corrections)
            out=sample

            for(c in 1:length(unlist(corrections))){
                print(paste0("Issue:",unlist(corrections)[c]))
                temp=fluoro::read.f3.eem(paste0(eem.dir, "/", unlist(corrections)[c], ".xls"))
                out=out-fluoro:::em.ex.corr(eem = temp, em.corr.file = em.corr.file, ex.corr.file = ex.corr.file)
            }
            save.name=input$`Corrected Name`[i]
            write.csv(out, file = paste0(save.dir, "/", save.name, ".csv"), row.names = T)
        }

        if(!f3.eem){
            sample=fluoro::read.raw.eem(file = paste0(eem.dir, "/", input$`Name of Raw EEM`[i], ".dat"))
            corrections=input$Blank[i]
            print(corrections)
            out=sample

            for(c in 1:length(unlist(corrections))){
                print(paste0("Issue:",unlist(corrections)[c]))
                out=out-read.raw.eem(paste0(eem.dir, "/", unlist(corrections)[c], ".dat"))
            }
            save.name=input$`Corrected Name`[i]
            write.csv(out, file = paste0(save.dir, "/", save.name, ".csv"), row.names = T)
        }


    }
    usefull.out=list(input, corr.dir=save.dir)
    return(usefull.out)
}
