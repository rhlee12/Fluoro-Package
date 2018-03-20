batch.correct=function(eem.dir){

    find.files=function(direct){
        contents=list.files(path = direct)
        raman.file=contents[grepl(pattern = "^RA", x = contents, ignore.case = T)|grepl(pattern = "raman", x = contents, ignore.case = T)]
        blank.file=contents[grepl(pattern = "blank", x = contents, ignore.case = T)|grepl(pattern = "blank", x = contents, ignore.case = T)]
        eem.files=grep(pattern = ".csv", x = contents, ignore.case = T)
        uv.files=grep(pattern = ".csv", x = contents, ignore.case = T)
    }

    sub.dirs=list.dirs(eem.dir,recursive = F) #Check: Are there sub directories?


     if(length(sub.dirs)>0){ #If there are, loop through them to correct each file in them.
        for(i in 1:length(sub.dirs)){
            files=find.files(sub.dirs[i])
        }
    }




}
