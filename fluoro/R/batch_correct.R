eem.dir="../example_data/batch_correct/"


batch.correct=function(eem.dir){

    build.input=function(eem.dir){
        sub.dirs=list.dirs(path = eem.dir,recursive = F, full.names = F)
        contents=list.files(path = eem.dir, full.names = T, recursive = T)
        f.contents=list.files(path = eem.dir, full.names = F, recursive = T)
        raman.files=contents[grepl(pattern = "RA\\d\\d\\d\\d\\d\\d", x = contents, ignore.case = T)|grepl(pattern = "*raman*", x = contents, ignore.case = T)]
        blank.files=contents[grepl(pattern = "blank", x = contents, ignore.case = T)|grepl(pattern = "blnk", x = contents, ignore.case = T)]
        eem.files=f.contents[grep(pattern = "\\.dat", x = contents, ignore.case = T)]
        eem.files=eem.files[!(eem.files %in% raman.file)&!(eem.files %in% blank.files)]#don't add raman and blanks to eem list
        uv.files=contents[grep(pattern = "\\.csv", x = contents, ignore.case = T)]

        index=data.frame(eems.dir=eem.files, eem.files=gsub(x =stringr::str_extract(string = eem.files, pattern = "/..*"), pattern = "/", replacement = ""))
        index$group=rep(NA, times=length(index[,1]))
        index$group=substr(x= index$eems.dir, start=1, stop= regexpr("/", text =index$eems.dir)-1)
        for(i in 1:nrow(index)){
            index$blank[i]=blank.files[grepl(x = blank.files, pattern = index$group[i])]
        }
        for(j in 1:nrow(index)){
            index$raman[j]=raman.files[grepl(x = raman.files, pattern = index$group[j])]
        }
        index$save.dir=paste0(eem.dir, "/corrected/")
        index$save.name=gsub(pattern = "\\.dat", replacement = "_c.csv", x = index$eem.files)
        return(index)
    }
    input=build.input(eem.dir = eem.dir)
    for(f in 1:nrow(input)){
        fluoro::f4.eem.correct(eem.file = paste0(eem.dir,"/", input$eems.dir[f]), blank.file = input$blank, abs.file = )
    }


    #sub.dirs=list.dirs(eem.dir,recursive = F) #Check: Are there sub directories?

     if(length(sub.dirs)>0){ #If there are, loop through them to correct each file in them.
        for(i in 1:length(sub.dirs)){
            files=find.files(sub.dirs[i])
        }
    }




}
