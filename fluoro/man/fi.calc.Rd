% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fi_calc.R
\name{fi.calc}
\alias{fi.calc}
\title{Calculate the Fluorecence Index (FI) for a corrected EEM}
\usage{
fi.calc(corr.eem)
}
\arguments{
\item{\code{corr.eem}}{- A previosuly corrected EEM, generated by the \code{f4.eem.correct}
function. If the EEM isn't loaded, read it in with the \code{read.corr.eem} function.}
}
\value{
The FI value for the corrected EEM.
}
\details{
Adapted from the original Matlab F4CorrectFunII, authored by Laurel Larsen, (5/25/07),
Kaelin Cawley (6/18/09), Rachel Gabor, Bailey Simone, and Mike SanClements (April 2010).
}
\examples{
\dontrun{
eem=read.corr.eem("../A4575E_c.csv")
FI=fi.calc(eem)
}

}
\author{
Robert Lee <rhlee@colorado.edu>
}
