### batch ss correct
out=solid.combo.correct(eem.dir = "../180516/", combo.file = "../F4SPF_LOG SHEET_BBWM_180516.xlsx")
## The 'out" object is a list of (1) the info from combo file, and (2) the directory where files were saved.
## You don't need this info, it is just here to make life easier for workflows in the future

eem.grid.plot(corr.dir = out$corr.dir, combo.file = "../F4SPF_LOG SHEET_BBWM_180516.xlsx")
