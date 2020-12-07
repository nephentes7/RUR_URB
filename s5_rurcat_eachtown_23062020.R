#################################################################################
#Step 5: Classify rural category for each town
#################################################################################
library(parallel)  #multicore processing for speed

#Create a list of files...

#ruRUC <-  list.files(path=(paste0(tt_ruc_msk_dir)) ,pattern="^ruc(.*).tif$",full.names=TRUE,recursive=TRUE) #exporting in qgis
ruRUC <-  list.files(path=(paste0(tt_ruc_msk_dir)) ,pattern="^ruc(.*).tif$",full.names=TRUE,recursive=FALSE)
ruRUC

#subset
ruRUC <- ruRUC[!grepl('.*ruc.*._.*\\.tif',ruRUC)] 
ruRUC

#Ordering the raster in the list so that the first is ruc8.tif etc. - otherwise use code s7 script to keep layer name, regardless the order
#bands <- as.numeric(sapply(ruRUC, function(x) x <- gsub("(ruc)(.*?)(_.*)", "\\2", basename(x))))
#s <- as.numeric(sapply(ruRUC, function(x) x <- gsub("(ruc)(.*?) \\.tif", basename(x))))
#ruRUCtmp <- as.numeric(sapply(ruRUC, function(x) x <- gsub("(ruc|.tif)", "", basename(x))))
#ruRUCo <- ruRUCtmp[order(ruRUCtmp)]

split <- strsplit(ruRUC, "ruc") 
split
split <- as.numeric(sapply(split, function(x) x <- sub(".tif", "", x[3])))
split
#ruRUCo <- ruRUC[order(split)]
#ruRUCo <-lapply(1:length(ruRUCo), function (x) {raster(ruRUCo[x])}) 
#ruRUCo
#ruRUCol <- list(ruRUCo)
#ruRUC_s <- stack(ruRUCo)

#Import typ23max20k.tif
#typ23max20k <- paste0(towns_msk_dir, "typ23max20k.tif")
#typ23max20k  <- list(stack(typ23max20k))
#typ23max20ks <- stack(typ23max20k)
#Import the list of typ masks- not needed
#typmisk <-  list.files(path=(paste0(towns_msk_dir)) ,pattern="^typ(.*)_msk.tif$",full.names=TRUE,recursive=FALSE)

#File names do not have same name : i.e.  "typ23max20k.tif" and "typ22_msk.tif and typ21_msk.tif" 
#one option would be renaming "typ23max20k.tif" to "typ23_mskk.tif" otherwise:
typlist <- c( "typ23max20k.tif", "typ22_msk.tif", "typ21_msk.tif")

for(id in c(8:max(split))){
  for(j in c(1:3)){
    print(paste0("Extract by mask: ruc ",id, " with ", typlist[j]))
    system(sprintf("gdal_calc.py -A %s -B %s --type=Byte --NoDataValue=255  --quiet --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
                 paste0(tt_ruc_msk_dir,"ruc",id,".tif"),
                 paste0(towns_msk_dir,typlist[j]),
                 #paste0(towns_msk_dir, "typ23max20k.tif"),
                 #paste0(tt_ruc_msk_dir,"ruc",id, j,"_typ23.tif"),
                 paste0(tt_ruc_msk_dir,"ruc",id,"_", substr(typlist[j],1,5), ".tif"),
                 "\"B*(A==1)+255*(A!=1)\""))}}

