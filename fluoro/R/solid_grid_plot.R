#' @title Generate a Grid of Solid State Corrected EEM Plots
#'
#' @author Robert Lee
#' @author Maggie Bowman
#'
#' @details - This function takes specified correction combinations (from previously corrected solid
#' state eems, see \code{\link{solid.combo.correct}}) on a given base EEM, and plots all the
#' combinations specified in a grid.
#'
#'
#' @param \code{corr.dir} - The directory where corrected EEMs live
#' @param \code{combo.file} - The spreadsheet (Excel or CSV) of desired combinations. Reuired columns:
#' \itemize{
#' \item{"Name of Raw EEM"}
#' \item{"Corrected Name"}
#' \item{"Notes Column"}
#' }
#'
#' @return Files are saved to the \code{corr.dir} location specefied.
#'
#' @example
#' \dontrun{
#' #NA right now
#' }
#'
#' @export
#'

eem.grid.plot=function(corr.dir, combo.file){

    corrected=list.files(path=corr.dir)
    grouping=data.frame(group=input$`Name of Raw EEM`,
                        corrected=paste0(input$`Corrected Name`, ".csv"),
                        plot.title=input$`Notes Column`)

    grps=unique(grouping$group)

    for(g in 1:length(grps)){
        sample=grps[g]
        files=paste0(corr.dir, input$`Corrected Name`[input$`Name of Raw EEM`==sample], ".csv")
        names=input$`Corrected Name`[input$`Name of Raw EEM`==sample]

        info=data.frame(files, names)

        make.plot=function(info){
            p.eem=read.corr.eem(file = info$files)
            p.eem.out=rayleigh.mask(p.eem)
            eem.plot=eem.plot(corr.eem = p.eem.out, sample.name = info$name, save.dir = corr.dir)
            return(eem.plot)
        }

        plots=lapply(seq(nrow(info)), function(x) make.plot(info[x,]))
        gridded=gridExtra::grid.arrange(grobs=plots, ncol=2)
        ggsave(filename = paste0(sample,".png"),
               plot = gridded,
               device = "png",
               path = corr.dir,
               width = 8.5,
               units = "in",
               height = 11,
               dpi = 300) ## Most papers want 600 dpi- maybe make this an optional input.
    }

graphics.off()
}
