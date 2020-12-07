#################################################################
#Step 1: mask out the urban clusters for each accessibility layer
#################################################################

#City types refers to a combination of settlement type (SMOD) and population size (details in the doc/00README.rtf file originally prepared by Nelson A.:
#class1 where population >= 5000000 and SMOD = 30
#class2 where population >= 1000000 and population < 5000000 and SMOD = 30
#class3 where population >=  500000 and population < 1000000 and SMOD = 30
#class4 where population >=  250000 and population <  500000 and SMOD = 30
#class5 where population >=  100000 and population <  250000 and SMOD = 30
#class6 where population >=   50000 and population <  100000 and SMOD = 30
#class7 where population >=   20000 and population <   50000 and SMOD = 23

#e.g. class_1.tif (-> raster related to the traveldistance for city type 1) with the actual location of the cities type 1 in (class_ll1.tif: each city has a class code/ID, from 1 to 71)

#Ensure same pixel size and extent across data
#Please note that currently, layers class_1.tif etc have different extent (first here below) and same pixel size from the layers class_ll1.tif etc...
##extent     : -180.0001, 179.9997, -60, 84.99994  (xmin, xmax, ymin, ymax)
#extent     : -180, 180, -60, 85  (xmin, xmax, ymin, ymax)

#r_list <- list.files(path=(paste0(path_, "1/")), pattern="^_(.*)d.tif$",full.names=TRUE,recursive=FALSE)
#_har: harmonized in terms of extent
#### <- basename(##)
#for (i in 1:length(####)){  #-te %s %s %s %s
#  system(sprintf("gdalwarp -te %s %s %s %s -of GTiff -multi -wo NUM_THREADS=ALL_CPUS -co COMPRESS=LZW -overwrite %s %s",
                 #-180,# extent 1 3 2 4
                 #-90,
                 #180,
                 #90,
                 #res(raster(#))[1],
                 #res(raster(#))[2],
                 #r_list[[i]],
                 #paste0(substr(r_list[i],1,nchar(r_list[i])-4),"_har.tif")
  #))
#}

file.names <- dir(tt_dir, pattern ="^class_(.*).tif$")
#for(id in c(1:length(file.names))){
 for(id in c(5:5)){ #just to check first two files
  #print(paste0("file name: ", id))
  class_file <- paste0(tt_dir, 'class_',id,'.tif')
  print(paste0("raster ",id, " in ",class_file))
  if(!dir.exists(tt_dir_outmsk_dir)){dir.create(tt_dir_outmsk_dir, recursive = T)}
  system(sprintf("gdal_calc.py -A %s -B %s --type=Int32  --NoDataValue=-2147483647 --quiet --co COMPRESS=LZW --outfile=\"%s\" --calc=%s", 
                 paste0(ghs_mask_dir,"class_ll",id,".tif"),
                 paste0(tt_dir,"class_", id,".tif"),
                 paste0(tt_dir_outmsk_dir,"acc_c",id,".tif"),
                 "\"-2147483647*(A>=1)+B*(A<1)\""))}


#check result- first layer
plot(raster(paste0(tt_dir_outmsk_dir,"acc_c1.tif")))
#Check no data value #-Inf
NAvalue(raster(paste0(tt_dir_outmsk_dir,"acc_c1.tif")))

######################################################################################
#Step 2: Creation of travel masks
######################################################################################
#make a list of the cluster30 files and compute reclassification (where values based on the different travel times are set to 1 and rest is set to 0)
#Change no data value- not used yet
#system(sprintf("gdalwarp -srcnodata %s -dstnodata %s -of GTiff -multi -wo NUM_THREADS=ALL_CPUS -co COMPRESS=LZW -overwrite %s %s",
#               -3.39999999999999996e+38,
#               255,
#               paste0(path_dir2004, "10km_PEy_ASy_c1_s1s2_allp_nd.tif"),
#               asis_cr_10km_reclnodata
#))
###############################################################################################
#TRAVEL TIME: 0-1 hour (0-60 minutes): tt1 from cities to peri-urban  - peri urban travel masks
###############################################################################################

for(id in c(1:6)){
  acc_files <- list.files(path=tt_dir_outmsk_dir, pattern ="^acc_c(.*).tif$", recursive = FALSE)
  # <- paste0(tt_dir_outmsk_dir, 'acc_c' ,id,'.tif')
  acc_file <- paste0(tt_dir_outmsk_dir, 'acc_' ,id,'.tif')
    print(paste0("accessibility layer - GHSL typology 30 clusters : classes ",id, " in ", acc_file))
  if(!dir.exists(tt_0to60min)){dir.create(tt_0to60min, recursive = T)}
  if(!file.exists(paste0(tt_0to60min,"tt1_acc_c",id,".tif")))
    system(sprintf("gdal_calc.py -A %s --co COMPRESS=LZW --quiet --outfile=%s --calc=\"%s\"",  #--type=Int32
                   paste0(tt_dir_outmsk_dir,"acc_c", id,".tif"),
                   paste0(tt_0to60min,"tt1_acc_c", id,".tif"),
                   paste0("(A>0)*(A<60)*1+",
                   "(A==60)*1+",
                   "(A==0)*1+",
                   "(A>60)*-2147483647")))}

###############################################################
#TRAVEL TIME: 1-2 hours (60-120 minutes): tt2 from cities to ...
##############################################################

for(id in c(1:6)){
  #acc_files <- list.files(path=tt_dir_outmsk_dir, pattern ="^acc_(.*).tif$", recursive = FALSE)
  acc_file <- paste0(tt_dir_outmsk_dir, 'acc_c' ,id,'.tif')
  print(paste0("TRAVEL TIME 1-2h- Accessibility layer - GHSL typology 30 cluster : class ",id, " in ", acc_file))
  if(!dir.exists(tt_60to120min)){dir.create(tt_60to120min, recursive = T)}
  if(!file.exists(paste0(tt_60to120min,"tt2_acc_c",id,".tif"))){
    system(sprintf("gdal_calc.py -A %s --quiet --co COMPRESS=LZW --NoDataValue=-2147483647 --outfile=%s --calc=\"%s\"",
                   paste0(tt_dir_outmsk_dir,"acc_c",id,".tif"),
                   paste0(tt_60to120min,"tt2_acc_c",id,".tif"),
                   paste0("(A>60)*(A<=120)*1+",
                          "(A<=60)*-2147483647+",
                          "(A>120)*-2147483647")))}}

################################################################
#TRAVEL TIME: 2-3 hours (120-180 minutes): tt3 from cities to...
################################################################

for(id in c(1:6)){
#for(id in c(1:2)){
  acc_files <- list.files(path=tt_dir_outmsk_dir, pattern ="^acc_(.*).tif$", recursive = FALSE)
  acc_file <- paste0(tt_dir_outmsk_dir, 'acc_c' ,id,'.tif')
  print(paste0("TRAVEL TIME 2-3h- Accessibility layer - GHSL typology 30 cluster : class ",id, " in ", acc_file))
  if(!dir.exists(tt_120to180min)){dir.create(tt_120to180min, recursive = T)}
  if(!file.exists(paste0(tt_120to180min,"tt3_acc_c",id,".tif"))){
  system(sprintf("gdal_calc.py -A %s --type=Int32 --NoDataValue=-2147483647 --quiet --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
                 paste0(tt_dir_outmsk_dir,"acc_c",id,".tif"),
                 paste0(tt_120to180min,"tt3_acc_c",id,".tif"),
                 paste0("(A>120)*(A<=180)         * 1+", 
                        "(A<=120)           * -2147483647+",
                        "(A>180)           * -2147483647")))}}

#####################################################################################################################
#TRAVEL TIME: 0-2h (0-120 minutes) for towns 20-50,000 peope from GHSL typology 23  #explain why...
#In the case of towns ('adjusted cities 7') the travel mask is computed for a travel time of 0-2 hours (0-120 minutes) 
#####################################################################################################################
#only layer 7
for(id in c(7:7)){ #7th layer city type
  #for(id in c(1:2)){
  acc_file <- paste0(tt_dir_outmsk_dir, 'acc_c' ,id,'.tif')
  print(paste0("TRAVEL TIME 0-2h- Accessibility layer - GHSL typology 23 cluster  : class ",id, " in ", acc_file))
  if(!dir.exists(towns20to50)){dir.create(towns20to50, recursive = T)}
  if(!file.exists(paste0(towns20to50,"tt12_acc_c",id,".tif"))){
    system(sprintf("gdal_calc.py -A %s --type=Int32 --NoDataValue=-2147483647 --quiet --co COMPRESS=LZW --outfile=\"%s\" --calc=\"%s\"",
                   paste0(tt_dir_outmsk_dir,"acc_c",id,".tif"),
                   paste0(towns20to50,"tt12_acc_c",id,".tif"),
                   paste0("(A>0)*(A<120)*1+",
                    "(A==120)*1+",
                    "(A==0)*1+",
                    "(A>120)*-2147483647")))}}  #120 pixels are then classified in the tt 2-3 h (ensure are incldued)

########################
#TRAVEL TIME: 2-3h (120-180 minutes) for towns 20-50,000 peope from GHSL typology 23  #explain why...
for(id in c(7:7)){
  #for(id in c(1:2)){
  acc_files <- list.files(path=tt_dir_outmsk_dir, pattern ="^acc_(.*).tif$", recursive = FALSE)
  acc_file <- paste0(tt_dir_outmsk_dir, 'acc_c' ,id,'.tif')
  print(paste0("TRAVEL TIME 2-3h- Accessibility layer - GHSL typology 23 cluster  : class ",id, " in ", acc_file))
  if(!dir.exists(towns20to50)){dir.create(towns20to50, recursive = T)}
  if(!file.exists(paste0(towns20to50,"tt3_acc_c",id,".tif"))){
    system(sprintf("gdal_calc.py -A %s --type=Int32 --NoDataValue=-2147483647 --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
                   paste0(tt_dir_outmsk_dir,"acc_c",id,".tif"),
                   paste0(towns20to50,"tt3_acc_c",id,".tif"),
                          paste0("(A>120)*(A<180)         * 1+", 
                                 "(A<=120)           * -2147483647+",
                                 "(A>180)           * -2147483647")))}}
                          

