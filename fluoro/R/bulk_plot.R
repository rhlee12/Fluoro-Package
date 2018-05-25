bulk.plot=function(eem.folder, rayliegh.mask=T){

    ## Bulk EEM plotting
    eems=list.files(path = eem.folder, pattern = "_c.csv", recursive = T, full.names = T) #find all corrected files
    names=stringr::str_split(string = eems, pattern = "/") #get names of files
    names=unlist(lapply(names, function(x) x[[length(x)]])) #more name stuff
    names=gsub(pattern = "_c.csv", replacement = "", x = names)

    save.dir=paste0(eem.folder, "/plots/")
    if(!dir.exists(save.dir)){dir.create(save.dir)}


    #this bit plots them all
    if(rayliegh.mask){
        lapply(seq(length(eems)), function(x) eem.plot(corr.eem = fluoro::rayleigh.mask(eem=read.corr.eem(eems[x]), mask.value = 0),
                                                       sample.name = names[x],
                                                       save.dir = save.dir))
    }else if(rayliegh.mask==F){
        lapply(seq(length(eems)), function(x) eem.plot(corr.eem = read.corr.eem(eems[x]),
                                                       sample.name = names[x],
                                                       save.dir = save.dir))
    }
}
