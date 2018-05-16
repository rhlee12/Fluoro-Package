#' @title Perform Batch Correction of EEMs
#'
#' @author Robert Lee
#'
#' @details Given all input files and prarameters, this code performs EEM corrections as in the
#' orignial Matlab code. Only a corrected EEM is output, other functions should be invoked to plot the
#'  correctred EEM or to calculate indicies. Function assumes un-altered F4 files have not been
#'  altered to remove headers.
#'
#' @param \code{eem.dir} - The filepath to the top directory housing raw EEM files, as .dat files
#' produced by a Flouromax F4.
#'
#' @return Corrected EEMs as CSVs saved in grouped subdirectories of a "corrected" subdirectory created
#'  in the specified input directory. An index file is also saved for the EEMs in the "corrected"
#'  folder. See \code{\link{make.indicies}} for details.
#'
#' @export
#'
#'

#### FUNCTION START ####
batch.correct=function(eem.dir){

    options(stringsAsFactors = F)

    build.input=function(eem.dir){
        sub.dirs=list.dirs(path = eem.dir,recursive = F, full.names = F)
        contents=list.files(path = eem.dir, full.names = T, recursive = T)
        f.contents=list.files(path = eem.dir, full.names = F, recursive = T)
        raman.files=contents[grepl(pattern = "RA\\d\\d\\d\\d\\d\\d", x = contents, ignore.case = T)|grepl(pattern = "*raman*", x = contents, ignore.case = T)]
        blank.files=contents[grepl(pattern = "blank", x = contents, ignore.case = T)|grepl(pattern = "blnk", x = contents, ignore.case = T)]
        eem.files=f.contents[grep(pattern = "\\.dat", x = contents, ignore.case = T)]
        eem.files=na.omit(eem.files[!(grepl(pattern = "RA\\d\\d\\d\\d\\d\\d", x = eem.files, ignore.case = T)|grepl(pattern = "*raman*", x = eem.files, ignore.case = T)|grepl(pattern = "blank", x = eem.files, ignore.case = T)|grepl(pattern = "blnk", x = eem.files, ignore.case = T))])#don't add raman and blanks to eem list)
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
        index$save.name=gsub(pattern = "\\.dat", replacement = "_c", x = index$eem.files)
        index$name=tolower(gsub(pattern = "\\.dat", replacement = "", x = index$eem.files))

        uv.match=stringr::str_split(string = uv.files, pattern = "/")
        uv.opts=data.frame(uv.file=uv.files, group=rep("", times=length(uv.match)))

        for(u in 1:length(uv.match)){
            uv.opts$file[u]=uv.match[[u]][length(uv.match[[u]])]
            uv.opts$group[u]=uv.match[[u]][length(uv.match[[u]])-1]
            # uv.opts$match.index[u]=which(grepl(pattern=gsub(x=tolower(uv.opts$file[u]), pattern = ".csv", replacement = ""),
            #                                    x = gsub(x=tolower(index$eem.files), pattern = ".dat", replacement = "")))
        }


        uv.opts$name=gsub(x=tolower(uv.opts$file), pattern = ".csv", replacement = "")
        index=merge(index, uv.opts, by="name", all = T)
        index$dil.fact=stringr::str_extract(string = index$name, pattern = "dil\\d*")
        index$dil.fact[is.na(index$dil.fact)]=1
        index$dil.fact = as.numeric(gsub(x=index$dil.fact, pattern = "dil", replacement = ""))

        index=index[-which(is.na(index$eems.dir)),]

        return(index)
    }

    input=build.input(eem.dir = eem.dir)
    top.save.dir=paste0(eem.dir, "/corrected/")
    if(!dir.exists(top.save.dir)){dir.create(top.save.dir)}

    write.csv(x = input, file = paste0(top.save.dir, "input_file.csv"), row.names = F)

    for(g in 1:length(unique(input$group.x))){
        dir.create(paste0(top.save.dir, unique(input$group.x)[g], "/"))
    }

    for(f in 1:nrow(input)){
        log.con=paste0(top.save.dir, "fail_log.txt")
        log.entry=paste0("No UV file for ", input$eem.files[f], ". Requires a file called '", input$name[f], ".csv'")

        if(is.na(input$uv.file[f])){
            message(
                paste0("No matching UV file for ",
                       input$eem.files[f],
                       ", make sure an absorbance file with the EXACT name as the EEM file is present in the correction directory.")
            )

            if(file.exists(log.con)&is.na(input$uv.file[f])){
                log.contents=readLines(con=log.con)
                log.contents=append(log.contents, log.entry)
                writeLines(text = log.contents, con = log.con)
            }
            if(!file.exists(log.con)&is.na(input$uv.file[f])){
                writeLines(text = log.entry, con = log.con)
            }
        }
        print(f)
        if(!is.na(input$uv.file[f])){
            corr.eem=fluoro::f4.eem.correct(eem.file = paste0(eem.dir,"/", input$eems.dir[f]),
                                   blank.file = input$blank[f],
                                   abs.file = input$uv.file[f],
                                   raman.file = input$raman[f],
                                   save.name = input$save.name[f],
                                   save.dir = paste0(top.save.dir, input$group.x[f], "/"),
                                   dil.fact=input$dil.fact[f])
            fluoro::make.indicies(corr.eem = corr.eem, uv.file = input$uv.file[f], save.dir = top.save.dir)
        }
    }
}
