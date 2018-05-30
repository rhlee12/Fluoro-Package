#Aqueous EEM bluk processing script

eem.dir="../example_data/MaggieExtracts/"

fluoro::batch.correct(eem.dir = eem.dir)
## THIS BIT SQUELCHES 300,300 PEAK in CORRECTED EEMS ##
fluoro:::mask.300(eem.dir=eem.dir)

fluoro::batch.plot(eem.dir = eem.dir)
