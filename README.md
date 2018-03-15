# Fluoro-Package
Repo for porting PARAFAC and EEM plot generation from Matlab. 

Currently, EEM correction and plotting are supported. Functions for calculating key indicies are also contained in the package, but a function to output all indicies for a given EEM is still being developed. 

## Prerequisites
A GitHub account: https://github.com
R: https://cran.r-project.org/
RStudio: https://www.rstudio.com/products/rstudio/download/ (free version)


## Current Installable Package

The current version of the package can be installed by saving the `fluoro_0.0.3.tar.gz` file to your computer, then running the following command in the R console:  

`install.packages(file.choose(), repos=NULL, type="source")`

A file browser window will open. Select the .tar.gz file you saved, and open it. R wil then install the package and restart.

To load the package, use the command `library("fluoro")`. This will make all the functions and data in the package available in the console. You can also invoke a function directly by using `fluoro::<function>`, which is helpful when writing scripts.

## Basic Workflow

To correct and plot an EEM, the following workflow should be used. 
 1. Locate all data files needed to correct an EEM.
 1. Enter the file paths to the data files in the `f4.eem.correct` 
 function (see `?fluoro::f4.eem.correct for more details`). 
 1. Point the output of the function to a variable, such as `corr.eem` (e.g. `corr.eem=fluoro::f4.eem.correct(eem.file=`... )
 1. Run the function. The corrected EEM should now be saved as a CSV in the directory specified in the `save.dir`, and in the `corr.eem` variable.
 1. Use `View(corr.eem)` to open up a viewer of the corrected eem, just to make sure it looks OK (optional).
 1. Now `corr.eem` can be passed to other fucntions, like `fresh.calc(corr.eem)` or `fresh.calc(corr.eem=corr.eem)`. 
 1. Use `eem.plot(corr.eem=corr.eem, sample.name="Example EEM", save.dir=tempdir())` to output a plot of the corrected EEM!
