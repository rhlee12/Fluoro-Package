
##TEST BLOCK
raw.eem.file="../example_data/F4_files/180104/A4575E.dat"

raw.eem=read.delim(file="../example_data/F4_files/180104/A4575E.dat", header = F)
blank=read.delim(file="../example_data/F4_files/180104/Blank180104.dat", header = F)
uv=read.csv(file="../example_data/MaineHighElevLakes_UV/A4575E.CSV", header = T)
raman=read.delim(file="../example_data/F4_files/180104/RA180104.dat", header = F)

dil.fact=1
uv.path.length=1

file.temp=unlist(stringr::str_split(raw.eem.file, pattern = "/"))
file.name=paste0(gsub(file.temp[length(file.temp)], pattern = ".dat", replacement = ""),"_c")
save.dir="../"

#Function assumes un-altered F4 headers and uv vis files are loaded in as data frames
#### FUNCTION START ####
f4.eem.correct=function(raw.eem, blank, uv, raman, file.name, save.dir, dil.fact, uv.path.length){
  em.inc=as.numeric(raw.eem[4, 1])-as.numeric(raw.eem[3, 1]) # Emission increment-Reads the second emission wavelength minus the first, assuming header is present
  ex.inc=as.numeric(raw.eem[1, 3])-as.numeric(raw.eem[1, 2]) # Excitation increment-Reads the second emission wavelength minus the first, assuming header is present

  em.seq=as.numeric(raw.eem[3:length(raw.eem[,1]), 1]) # HEADER IS NEEEDED
  ex.seq=as.numeric(raw.eem[1, 2:length(raw.eem)]) # HEADER IS NEEEDED

  raman.begin=as.numeric(raman[3,1]) #raman start wavelenth
  raman.end=as.numeric(raman[length(raman[,1]),1]) # raman end wavelength
  no.head.raman=raman[3:length(raman[,1]),]
  #trim.raman=as.numeric(raman[-c(1,2),]) #USE FULL SCAN?
  trim.raman=data.frame(no.head.raman[which(as.numeric(no.head.raman[,1])>=370),]) #pegged at a start of 370 nm
for(i in 1:length(trim.raman)){
  trim.raman[,i]=as.numeric(trim.raman[,i])
}
  r.sum=0

  for( i in 1:(length(trim.raman[,1])-1)){ #This integrates from RamanBegin to RamanEnd.
    y0 = as.numeric(trim.raman[i, 3])
    y1 = as.numeric(trim.raman[i+1, 3])
    dx = as.numeric(trim.raman[i+1, 1]) - as.numeric(trim.raman[i, 1])
    r.sum = r.sum + dx * (y0 + y1)/2;
  }

  base.rect=(trim.raman[1,3]+trim.raman[length(trim.raman[,1])-1,1])/2*(trim.raman[length(trim.raman[,1])-1,1]-trim.raman[1,1])

  raman.area=r.sum-base.rect

  trim.blank=blank[3:length(blank[,1]), 2:length(blank)]
  for(i in 1:length(trim.blank)){
    trim.blank[,i]=as.numeric(trim.blank[,i])
  }

  blank.normal.raman=trim.blank/raman.area

  trim.raw.eem=raw.eem[3:length(raw.eem[,1]), 2:length(raw.eem)]
  for(i in 1:length(trim.raw.eem)){
    trim.raw.eem[,i]=as.numeric(trim.raw.eem[,i])
  }

  waves=as.numeric(uv[3:length(uv[,1]),1]) ## ?? WAVES?

  trim.uv=uv[-1,]
  for(i in 1:length(trim.uv)){trim.uv[,i]=as.numeric(trim.uv[,i])}

  abs.254=trim.uv[trim.uv[,1]==254, 2]

  corrected.trim.uv=trim.uv
  corrected.trim.uv[,2]=corrected.trim.uv[,2]/uv.path.length

  ex.abs=corrected.trim.uv[corrected.trim.uv[,1] %in% ex.seq,2]
  em.abs=corrected.trim.uv[corrected.trim.uv[,1] %in% em.seq,2]

  ### IFC Stuff
  IFC=data.frame(matrix(data=NA, nrow=length(em.abs), ncol = length(ex.abs)))

  for(ex in 1:length(ex.abs)){
    for(em in 1:length(em.abs)){
      IFC[em, ex]=em.abs[em]+ex.abs[ex]
      }
  }

  Aci=trim.raw.eem*10^(0.5*IFC)
  Acir=Aci/raman.area
  Asub=Acir-blank.normal.raman

  corr.eem=Asub*dil.fact

  write.csv(x = corr.eem, file = paste0(save.dir, file.name, ".csv"), row.names = F)
  rownames(corr.eem)=em.seq ## ADDS LABELS to CORR EEM
  colnames(corr.eem)=ex.seq ## ADDS LABELS to CORR EEM

  write.csv(corr.eem, file = paste0(save.dir, "/", file.name, ".csv"), row.names = T)
  return(corr.eem)
}
