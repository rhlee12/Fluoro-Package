## This script takes an input XLS, performs the indicated subtractions,
#  Rayleigh masks it, and saves a plot of the final EEM.

# FILE NAME CLEANUP
# #Trim out the spaces, so that the Excel sheet will work
# rename=data.frame(original=list.files("../180316/", full.names = T),
#                   rename=gsub(list.files("../180316/", full.names = T),
#                               replacement = "", pattern = " "))
#
# file.rename(from=rename$original, to=rename$rename)


input=readxl::read_excel(path = "../F4SPF_LOG SHEET_BBWM_180426.xlsx")
#View(input)

input$Blank=stringr::str_split(input$Blank, pattern = ", ")

save.dir="../180316/corrected/"
if(!dir.exists(save.dir)){dir.create(save.dir)}

for(i in 1:nrow(input)){
    print(paste0("ROW ", i))
    print(input$`Name of Raw EEM`[i])


    sample=fluoro::read.raw.eem(file = paste0("../180316/", input$`Name of Raw EEM`[i], ".dat"))
    corrections=input$Blank[i]
    print(corrections)
    out=sample

    for(c in 1:length(corrections)){
        print(paste0("Issue:",unlist(corrections)[c]))
        out=out-read.raw.eem(paste0("../180316/", unlist(corrections)[c], ".dat"))
    }
    save.name=input$`Corrected Name`[i]
    write.csv(out, file = paste0(save.dir, "/", save.name, ".csv"), row.names = T)
}


corrected=list.files(path="../180316/corrected/")
grouping=data.frame(group=input$`Name of Raw EEM`, corrected=corrected, plot.title=input$`Notes Column`)

grps=unique(grouping$group)

for(g in 1:length(grps)){
    sample=grps[g]
    files=paste0("../180316/corrected/", input$`Corrected Name`[input$`Name of Raw EEM`==sample], ".csv")
    names=input$`Corrected Name`[input$`Name of Raw EEM`==sample]
    for(f in 1:length(files)){
        p.eem=read.corr.eem(file = files[f])
        p.eem.out=rayleigh.mask(p.eem)
        eem.plot(corr.eem = p.eem.out, sample.name = names[f], save.dir = "../180316/corrected/")
    }
}
