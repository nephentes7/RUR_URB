###################################################################################################
#Step 3: Establish hierarchy of travel masks by prioritizing shorter travel to larger, dense cities
#(Create masks with all the cities classes set to 1, called city masks)
###################################################################################################
file.names <- dir(ghs_mask_dir, pattern ="^class_ll(.*).tif$")
file.names
#for(id in c(1:length(file.names))){
  for(id in c(3:7)){ #to check first files
  class_file <- paste0(tt_dir, 'class' ,id,'.tif')
  print(paste0("raster ",id, " in ",class_file))
  if(!dir.exists(tt_ruc_msk_dir)){dir.create(tt_ruc_msk_dir, recursive = T)}
  system(sprintf("gdal_calc.py -A %s  --type=Byte --NoDataValue=255 --quiet --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
                 paste0(ghs_mask_dir,"class_ll",id,".tif"), # input
                 paste0(tt_ruc_msk_dir,"ruc",id,".tif"),
                 "\"1*(A>=1)+0*(A<1)\""))}

#Create a stack with all the city maskslayers ruc1:ruc7
city_masks <- list.files(path=paste0(tt_ruc_msk_dir), pattern='^ruc(.*).tif$',full.names=TRUE,recursive=TRUE)
city_masks
city_masks_17 <- stack(city_masks)
city_masks_sum2 <- calc(city_masks_17, sum, na.rm=FALSE)
plot(city_masks_sum2)
#writeRaster(city_masks_sum2, filename = paste0(tt_ruc_msk_dir, "ruc1_7.tif"),format="GTiff", overwrite=TRUE)
############################################
#Reclassify overlapping pixels of value =2 
############################################
#ruc1__7 <- paste0(tt_ruc_msk_dir,"ruc1__7.tif")
#check max value
maxValue(city_masks_sum2)
# reclassify 2 to 1 (overlap for few cells if city 7 is added)
system(sprintf("gdal_calc.py -A %s --type=Byte --NoDataValue=255 --quiet --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
               paste0(tt_ruc_msk_dir,"ruc1_7.tif"),
               paste0(tt_ruc_msk_dir,"ruc1__7.tif"),
               #"\"1*(A>=1)+0*(A<1)\"")) 
               "\"1*(A>=1)+255*(A<1)\"")) #use no data value 255 instead of zero

ruc1__7r <- raster(paste0(tt_ruc_msk_dir,"ruc1__7.tif"))
plot(ruc1__7r)
