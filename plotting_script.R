
## Bulk EEM plotting
eems=list.files("../example_data/GRSM/corrected/", pattern = "_c.csv", recursive = T, full.names = T) #find all corrected files
names=stringr::str_split(string = eems, pattern = "/") #get names of files
names=unlist(lapply(names, function(x) x[[length(x)]])) #more name stuff
names=gsub(pattern = "_c.csv", replacement = "", x = names)

#this bit plots them all
lapply(seq(length(eems)), function(x) eem.plot(corr.eem = read.corr.eem(eems[x]),
                                                sample.name = names[x],
                                                save.dir = "../example_data/GRSM/"))




### How to plot the EEMs with custom names
eem.plot(corr.eem = read.corr.eem("../example_data/GRSM/corrected/F4 180109/G170123B_c.csv"),
         sample.name = "MY NICE NAME",
         save.dir = "../example_data/GRSM/")


fluoro::batch.correct("../example_data/GRSM/")
