### batch ss correct
em.corr.file = "../info/PARAFAC/Correction Files for McKnight Fluorometers/fl3_mcorrect_300_550_2.xls"
ex.corr.file = "../info/PARAFAC/Correction Files for McKnight Fluorometers/fl3_xcorrect_240_450_10.xls"

out=fluoro::solid.combo.correct(eem.dir = "../SPF_F3_180523/", combo.file = "../F3SPF_LOG SHEET_BBWM_180523.xlsx",f3.eem = TRUE, em.corr.file = em.corr.file, ex.corr.file = ex.corr.file)
## The 'out" object is a list of (1) the info from combo file, and (2) the directory where files were saved.
## You don't need this info, it is just here to make life easier for workflows in the future

fluoro::eem.grid.plot(corr.dir = out$corr.dir, combo.file = "../F3SPF_LOG SHEET_BBWM_180523.xlsx")

