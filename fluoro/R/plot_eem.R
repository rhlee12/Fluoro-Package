#' @title Plot a corrected EEM
#'
#' @author Robert Lee
#'
#' @details - Given a corrected EEM, the desired sample name, and where the output
#' plot should be saved, a plotted EEM is returned.
#'
#' @param \code{corr.eem} - A corrected EEM
#' @param \code{sample.name} - The name associated with the sample
#' @param \code{save.dir} - The directory to save the EEM plot to.
#'
#' @return
#'
#' @example
#' \dontrun{
#' corr.eem=read.corr.eem(system.file("extdata", "corr_eem.csv", package = "fluoro"))
#' eem.plot(corr.eem, sample.name="Example EEM", save.dir=tempdir())
#' }
#'
#' @export
#'


eem.plot=function(corr.eem, sample.name, save.dir){

    library(ggplot2)
    library(akima)

    #colnames(corr.eem)
    plot.eem=data.frame(ex.wl=rownames(corr.eem), corr.eem)
    #test=reshape2::dcast(data=plot.eem, formula = )
    test=reshape2::melt(data = plot.eem, id.vars="ex.wl")

    test$variable=as.character(gsub(pattern = "X", replacement = "", x = test$variable))
    colnames(test)=c("Emission", "Excitation", "Value")
    test$Emission=as.numeric(test$Emission)
    test$Excitation=as.numeric(test$Excitation)

    gdat=akima::interp(x = test$Emission,
                       y=test$Excitation,
                       z = test$Value,
                       duplicate = "mean",
                       xo = seq(from=test$Emission[1], to=test$Emission[length(test$Emission)],length.out = 200),
                       yo = seq(from=test$Excitation[1], to=test$Excitation[length(test$Excitation)],length.out = 200)
    )

    gdat=data.frame(akima::interp2xyz(gdat, data.frame = T))

    plot=ggplot2::ggplot(data=gdat)+ggplot2::aes(x = x, y = y, z = z, fill = z, name="") +
        ggplot2::geom_tile() +
        ggplot2::coord_equal() +
        ggplot2::geom_contour(color = "white", alpha = 0.5, bins=40) +
        ggplot2::scale_fill_distiller(palette="Spectral", na.value="white") +
        ggplot2::theme_light()+
        ggplot2::xlab("Emission wavelength (nm)")+
        ggplot2::ylab("Excitation wavelength (nm)")+
        ggplot2::ggtitle(sample.name)+
        ggplot2::theme(legend.title=element_blank(), legend.key.height = unit(3, "line"))+
        ggplot2::theme(aspect.ratio=1)
    return(plot)
}
