########################################
#Multiple HD and LD populations by masks
########################################
#The rdisagg files in the original script (in the folder rucT and in rucR) are in the same folder: tt_ruc_msks
#and filter is applied to filter out the needed files/rasters
#If preferred, create separate folders/subfolders in s0 script and provide location/path based on the directory name created

#########################################################################################
#Starting with "rucT" folder rasters: ruc8typ21, ruc8 typ22, ruc8typ23, ruc9typ21 etc..
########################################################################################

#Select only ruc*typ* files
#rucT_files <-  list.files(path=(paste0(tt_ruc_msk_dir)), pattern="^ruc(.*)_typ(.*).tif$",full.names=TRUE,recursive=FALSE)
#rucT_files

#create an object stack  
#rucT_s <- stack(rucT_files)

#Import pop layers- ld and hd
pop_ld <- raster(paste0(pop_dir, "pop_ld.tif"))
pop_ld
pop_hd <- raster(paste0(pop_dir, "pop_hd.tif"))
#Create a list
pop_list <- list(pop_ld,pop_hd)
pop_list

#Check extent- they have different extent 
#extent(pop_ld)
#extent(rucT_s[[1]])

#Ensure the same extent: ymax 85 vs ymax 90 ymin -60 ymin -90 - same res
#for (i in 1:length(rucT_files)){  #-te %s %s %s %s
#system(sprintf("gdalwarp -te %s %s %s %s -of GTiff -multi -wo NUM_THREADS=ALL_CPUS -co COMPRESS=LZW -overwrite %s %s",
#               -180,# extent 1 3 2 4
#               -90,
#               180,
#               90,
               #res(raster(#####))[1],
               #res(raster(#####))[2],
#               rucT_files[[i]],
#               paste0(substr(rucT_files[i],1,nchar(rucT_files[i])-4),"_e.tif")
#))}


#########################################
#Layers with same extent
#########################################
#Select only ruc*typ* files with same extent of the other pop layers
rucT_files_e <-  list.files(path=(paste0(tt_ruc_msk_dir)), pattern="^ruc(.*)_typ(.*)_e.tif$",full.names=TRUE,recursive=FALSE)
rucT_files_e
rucT_es <- stack(rucT_files_e)

#Function and empty list
f5 <- function(x,y){ifelse(y == 1, x, NA)} #otherwise to zero as last step is to set NA to zero but maybe 'heavier' 

f5_popl <- list() #low densities
f5_poph <- list() #high densities

#Start processing 
beginCluster()

strt<-Sys.time()

#Start processing
for (i in 1:2) { #length(rucT_files_e)
  #ld
  f5_popl[[i]] <- clusterR(stack(pop_list[[1]], rucT_es[[i]]), overlay, arg = list(fun = f5)) 
  print(paste0("Export ",substr(basename(rucT_files_e[i]),1,13), "l.tif ..." ))
  writeRaster(f5_popl[[i]], filename=paste0((ruc_pop_dir), substr(basename(rucT_files_e[i]),1,13), "l"), format="GTiff", datatype='INT2S', overwrite=TRUE)
  # hd
  f5_poph[[i]] <- clusterR(stack(pop_list[[2]], rucT_es[[i]]), overlay, arg = list(fun = f5)) 
    #Print and export
  print(paste0("Export ",substr(basename(rucT_files_e[i]),1,13), "h.tif ..." ))
  writeRaster(f5_poph[[i]], filename=paste0((ruc_pop_dir), substr(basename(rucT_files_e[i]),1,13), "h"), format="GTiff", datatype='INT2S', overwrite=TRUE)}

print(Sys.time()-strt)
endCluster()

#######################################################
##Continue with the regular rural classes and the cities
#######################################################
  
rucR_files <-  list.files(path=(paste0(tt_ruc_msk_dir)), pattern="^ruc(.*)r.tif$",full.names=TRUE,recursive=FALSE)
rucR_files
rucR <- stack(rucR_files)
#extent(rucR[[1]])

#Ensure the same extent: ymax 85 vs ymax 90 ymin -60 ymin -90 - same res
for (i in 1:length(rucR_files)){  #-te %s %s %s %s
system(sprintf("gdalwarp -te %s %s %s %s -of GTiff -multi -wo NUM_THREADS=ALL_CPUS -co COMPRESS=LZW -overwrite %s %s",
               -180,# extent 1 3 2 4
               -90,
               180,
               90,
               rucR_files[[i]],
               paste0(substr(rucR_files[i],1,nchar(rucR_files[i])-4),"_e.tif")
))} 


rucR_files_e <-  list.files(path=(paste0(tt_ruc_msk_dir)), pattern="^ruc(.*)r_e.tif$",full.names=TRUE,recursive=FALSE)
rucR_files_e
rucR_es <- stack(rucR_files_e)
  
f5_popl <- list() #low densities
f5_poph <- list() #high densities

#Start processing 
beginCluster()

strt<-Sys.time()

#Start processing
for (i in 1:2) { #length(rucR_files_e)
  #ld
  f5_popl[[i]] <- clusterR(stack(pop_list[[1]], rucR_es[[i]]), overlay, arg = list(fun = f5)) 
  print(paste0("Export ",substr(basename(rucR_files_e[i]),1,8), "l.tif ..." ))
  writeRaster(f5_popl[[i]], filename=paste0((ruc_pop_dir), substr(basename(rucR_files_e[i]),1,8), "l"), format="GTiff", datatype='INT2S', overwrite=TRUE)
  # hd
  f5_poph[[i]] <- clusterR(stack(pop_list[[2]], rucR_es[[i]]), overlay, arg = list(fun = f5)) 
  #Print and export
  print(paste0("Export ",substr(basename(rucR_files_e[i]),1,8), "h.tif ..." ))
  writeRaster(f5_poph[[i]], filename=paste0((ruc_pop_dir), substr(basename(rucR_files_e[i]),1,8), "h"), format="GTiff", datatype='INT2S', overwrite=TRUE)}

print(Sys.time()-strt)
endCluster()

#######################################################
##Continue with cities by high and low density
#######################################################

ruCit_files <-  list.files(path=(paste0(tt_ruc_msk_dir)) ,pattern="ruc[1,2,3,4,5,6].tif$|ruc7_v2hc.tif",full.names=TRUE,recursive=FALSE) #original version
#rucCit_files <-  list.files(path=(paste0(tt_ruc_msk_dir)) ,pattern="ruc[8,9].tif$|ruc7_v2hc.tif",full.names=TRUE,recursive=FALSE)
rucCit_files
rucCit <- stack(rucCit_files)
#extent(rucCit[[1]])
#Ensure the same extent: ymax 85 vs ymax 90 ymin -60 ymin -90 - same res
for (i in 1:length(rucCit_files)){  #-te %s %s %s %s
  system(sprintf("gdalwarp -te %s %s %s %s -of GTiff -multi -wo NUM_THREADS=ALL_CPUS -co COMPRESS=LZW -overwrite %s %s",
                 -180,# extent 1 3 2 4
                 -90,
                 180,
                 90,
                 rucCit_files[[i]],
                 paste0(substr(rucCit_files[i],1,nchar(rucCit_files[i])-4),"_e.tif")
  ))} 

ruCit_files_e <-  list.files(path=(paste0(tt_ruc_msk_dir)) ,pattern="ruc[1,2,3,4,5,6]_e.tif$|ruc7_v2hc_e.tif",full.names=TRUE,recursive=FALSE) #original version
#rucCit_files_e <-  list.files(path=(paste0(tt_ruc_msk_dir)) ,pattern="ruc[8,9]_e.tif$|ruc7_v2hc_e.tif",full.names=TRUE,recursive=FALSE)
rucCit_files_e
rucCit_es <- stack(rucCit_files_e)

f5_popl <- list() #low densities
f5_poph <- list() #high densities

#Start processing 
beginCluster()

strt<-Sys.time()

#Start processing
for (i in 1:2) { #length(rucR_files_e)
  #ld
  f5_popl[[i]] <- clusterR(stack(pop_list[[1]], rucCit_es[[i]]), overlay, arg = list(fun = f5)) 
  print(paste0("Export ",substr(basename(rucCit_files_e[i]),1,6), "l.tif ..." ))
  writeRaster(f5_popl[[i]], filename=paste0((ruc_pop_dir), substr(basename(rucCit_files_e[i]),1,6), "l"), format="GTiff", datatype='INT2S', overwrite=TRUE)
  # hd
  f5_poph[[i]] <- clusterR(stack(pop_list[[2]], rucCit_es[[i]]), overlay, arg = list(fun = f5)) 
  #Print and export
  print(paste0("Export ",substr(basename(rucCit_files_e[i]),1,6), "h.tif ..." ))
  writeRaster(f5_poph[[i]], filename=paste0((ruc_pop_dir), substr(basename(rucCit_files_e[i]),1,6), "h"), format="GTiff", datatype='INT2S', overwrite=TRUE)}

print(Sys.time()-strt)
endCluster()

