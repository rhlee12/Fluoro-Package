#' @title Perform F3 Instrument Correction on F3 Files
#'
#' @author Robert Lee
#'
#' @details Given a raw EEM, Blank and (optionally) Raman file from an F3 instrument,
#' instrument corrected versions are returned for use in correcting raw F3 EEMs.
#' Raman files are optional only to accomodate the correction of solid state EEMs-
#' \strong{raman correction information must be supplied when correcting an EEM of
#' aqueous samples!}
#'
#'
#' @param \code{f3.eem} - An F3 EEM read in by the \code{\link{read.f3.eem}} function
#' @param \code{f3.blank} - An F3 Blank file read in by the \code{\link{read.f3.eem}} function
#' @param \code{em.corr.file} - The path to the emission correction file specific to the F3 used. Must be an XLS file.
#' @param \code{em.corr.file} - The path to the emission correction file specific to the F3 used. Must be an XLS file.
#' @param \code{f3.raman} -  An
#' F3 raman file read in by the \code{\link{read.f3.eem}} function
#' @param \code{corr.fact} - The
#' correction factor specific to the F3 used.
#' @param \code{ramman.corr.file} - The path to the Raman correction file specific to the F3 used. Must be an XLS file.
#'
#'
#' @return A list of 3 objects:
#' \itemize{
#' \item{\code{ic.eem}}: The instrument corrected EEM
#' \item{\code{ic.blank}}: The instrument corrected Blank
#' \item{\code{ic.raman}}: The instrument corrected Raman.
#' }
#' @export
#'


## TEST BLOCK
# em.corr.file="../info/PARAFAC/Correction Files for McKnight Fluorometers/fl3_mcorrect_300_550_2.xls"
# ex.corr.file="../info/PARAFAC/Correction Files for McKnight Fluorometers/fl3_xcorrect_240_450_10.xls"
# raman.corr.file="../info/PARAFAC/Correction Files for McKnight Fluorometers/fl3_RamanMC_370_450_05.xls"
# corr.fact = 0.959242

f3.inst.corr=function(f3.eem, f3.blank, em.corr.file, ex.corr.file, f3.raman, corr.fact, ramman.corr.file){

    raman.corr = as.numeric(unlist(readxl::read_excel(raman.corr.file, col_names = F))) #Raman Correction

    ic.raman=(f3.raman*raman.corr)*corr.fact

    ic.blank=fluoro:::em.ex.corr(eem=f3.blank, em.corr.file, ex.corr.file)

    ic.eem=fluoro:::em.ex.corr(eem=f3.eem, em.corr.file, ex.corr.file)

    return(list(ic.eem=ic.eem, ic.blank=ic.blank, ic.raman=ic.raman))
}
