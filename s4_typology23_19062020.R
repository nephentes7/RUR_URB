####################################################
#Step 4: Mask out clusters from typolog 23 (with pop less than 20k), 22 and 21 
#Create masks for towns
#Subtract ruc7 from typ23 etc. ... (from original script)
################################################################
#Import packages for parallel processing
library(doParallel)
library(parallel)

####################################################
#Reprojection to wgs if needed
#############################################################################
#Import one ruc file to be used in case reprojection of ghsl layer is needed
ruc1_20.r <- raster(paste0(tt_ruc_msk_dir,"ruc1_20.tif"))
wgs <- crs(ruc1_20.r)
##ghsl_smod <- raster(paste0(pop_dir, "GHS_SMOD_POP2015_GLOBE_R2019A_54009_1K_V1_0.tif"))
#check projection
#print(crs(ghsl_smod)) #mollweide
#Reproject the rasters wgs
#crs(r)
#projectRaster(ghsl_smod, crs=wgs)
#crs(ghsl_smod)
#Export 
#writeRaster(ghsl_smod, filenamepaste0(pop_dir, "GHS_SMOD_POP2015_GLOBE_R2019A_54009_1K_V1_0_wgs_tmp.tif"), format="GTiff", overwrite=TRUE)

###############################################################################################
#Import projected raster if already available
##############################################################################################
ghsl_smod_wgs <- raster(paste0(pop_dir, "GHS_SMOD_POP2015_GLOBE_R2019A_54009_1K_V1_0_wgs.tif")) #please note the verion used here is slighlty different from the one of Theresa
#make a copy
A <- ghsl_smod_wgs
#ghsl_smod_wgss <- stack(ghsl_smod_wgs)
#ghsl_smod_wgs <- raster(paste0(pop_dir, "GHS_SMOD_POP2015_GLOBE_R2019A_54009_1K_V1_0_WGS1984.tif")) #version used by Theresa

#check/ compare extent and res of the rasters
#compareRaster(ghsl_smod_wgs,ruc1_20.r,extent=TRUE) #,res=TRUE
#library(testthat)
#capture_warnings(compareRaster(ghsl_smod_wgs,ruc1_20.r, res=T, orig=T, stopiffalse=F, showwarning=T))
#print(res(ghsl_smod_wgs))
#res(ruc1_20.r)
#check estent 
extent(ghsl_smod_wgs)
#extent(ruc1_20.r)
#layers have same extent and resolution
res(ghsl_smod_wgs)
#res(ruc1_20.r)

#create testing area
#test <- crop(A, extent(-10, 30, 30, 45)) ##Crop Raster to manageable size

###############################################################################################
#Start parallel processing for creating the typ21:23 masks rasters
##############################################################################################
rast_list <- list()
var1 <- list(21, 22, 23) 

beginCluster()
cl <-getCluster()
clusterExport(cl, list("var1"))
strt<-Sys.time()
for (i in 1:length(var_list$var1)) {
  vartmp <- var1[[i]]
  vartmp
  f1 <- function(x){ifelse(x != vartmp | is.na(x), NA, 1)}
  rast_list[[i]]  <- clusterR(ghsl_smod_wgs, calc, args=list(fun=f1),export='vartmp') #test
  print(paste0("Exporting typ", var1[i], "mask.tif ... "))
  writeRaster(rast_list[[i]], filename = paste0(paste0(towns_msk_dir), "typ",var1[i], "_msk.tif"), format="GTiff", overwrite=TRUE)}
print(Sys.time()-strt)
stopCluster(cl)

###############################################################################################
#Subtract ruc7 etc...
##############################################################################################
#Create the raster ruc1_6.tif combigin all rasters ruc1:ruc6
city_masks16 <-  list.files(path=(paste0(tt_ruc_msk_dir)) ,pattern="ruc[1,2,3,4,5,6].tif$",full.names=TRUE,recursive=FALSE) #original version
city_masks16s <- stack(city_masks16)
city_masks16s_sum <- calc(city_masks16s, sum, na.rm=FALSE)
writeRaster(f5_poph[[i]], filename=paste0((tt_ruc_msk_dir), "ruc1_6"), format="GTiff", datatype='INT2S', overwrite=TRUE)

#Import layer ruc7.tif and original (from Theresa) ruc1_6.tif [if not created]
#ruc7 <- "/home/daietti/SOFA/data/travel_time/GHS_masks/tt_ruc_msks/ruc7.tif" #acc_files
ruc7 <-  list.files(path=(paste0(tt_ruc_msk_dir)) ,pattern="^ruc7(.*)hc.tif$",full.names=TRUE,recursive=TRUE) #exporting in qgis extent set manually
#ruc1_6 <- paste0(tt_ruc_msk_dir,"ruc1_6.tif")  
ruc1_6 <- paste0(tt_ruc_msk_dir,"ruc1_6_v2hc.tif") #original does no work - exported from qgis

stck <- stack(ruc1_6,ruc7)
f1_list <- list()
#function
f1 <- function(x,y){ y[x == 1] <- NA; y} 

##################################
#Start processing for towns 20-50k

beginCluster()

f1_result <- clusterR(stck,overlay, arg = list(fun = f1)) #ruc7_rev
print(paste0("Export ruc7_rev.tif ..."))
writeRaster(f1_result, filename=paste0((tt_ruc_msk_dir), "ruc7_rev.tif"), format="GTiff", datatype='INT1U', overwrite=TRUE)
typ23mask <- paste0(towns_msk_dir,"typ23_msk.tif")
stck2 <- stack(f1_result, typ23mask)
typ23max20k <- clusterR(stck2, overlay, arg = list(fun = f1))  #typ23ma20k
 #Print and export
print(paste0("Export typ23max20k.tif ..."))
writeRaster(typ23max20k, filename=paste0((towns_msk_dir), "typ23max20k.tif"), format="GTiff", datatype='INT1U', overwrite=TRUE)

endCluster


