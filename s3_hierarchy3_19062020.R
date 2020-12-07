####################################################
#Step 3: Create peri urban travel masks starting with peri-urban masks 
#(tt_0to60min folder: tt1 accessibility layers) -from cities to peri-urban  - peri urban travel masks 
####################################################
library(parallel)  #multicore processing for speed

#Create empty list
f1_list <- list() # files called ruc8, ruc9, ruc 10 ...NA in values of ruc1__7.tif ==1 and remaining the acc_ c1_tt1 fies and so on..

#functions
f1 <- function(x,y){ y[x == 1] <- NA; y} 
f2 <- function(x,y){ x[y == 1] <- 1; x} 

##################################

######################################
#List of accessibility layers at travel time 1  #pattern="^tt1_acc_c[1,2](.*).tif$ for selection of only 2 files- testing 
######################################
acc_files <- list.files(path=(paste0(tt_0to60min)) ,pattern="^tt1_acc_c(.*).tif$",full.names=TRUE,recursive=TRUE) #only 2 files selected for testing  
print(acc_files)
#create an object stack  
acc_s <- stack(acc_files) 
acc_s
#Import ruc1_7.tif
ruc1__7 <- paste0(tt_ruc_msk_dir,"ruc1__7.tif")
rucs_list <- list(stack(ruc1__7))

#variables
var_list <- list(
  var1 = 1:6,  #1:6 #1 ... 6; #set depending on the number of the accessibility layers: here six
  var2 = 2:7,  #2: 7; listing  
  var3 = 8:13  # naming starting from ruc1_8.tif (the next raster)
)


#Start processing for tt1
beginCluster()

for (i in 1:length(var_list$var1)) { #same lenght for the 3 vars
  f1_list[[var_list$var1[i]]] <- clusterR(stack(rucs_list[[var_list$var1[i]]], acc_s[[var_list$var1[i]]]), overlay, arg = list(fun = f1)) #e.g. ruc8.tif
  rucs_list[[var_list$var2[i]]] <- clusterR(stack(rucs_list[[var_list$var1[i]]], f1_list[[var_list$var1[i]]]), overlay, arg = list(fun = f2)) #e.g. ruc1_8.tif
  #Print and export
  #print(paste0("Exporting ruc1_", var_list$var3[i], ".tif and ruc",var_list$var3[i],".tif ..." ))
  print(paste0("Export ruc",var_list$var3[i],".tif and ruc1_", var_list$var3[i], ".tif ..."))
  writeRaster(f1_list[[var_list$var1[i]]], filename=paste0((tt_ruc_msk_dir), "ruc",var_list$var3[i]), format="GTiff", datatype='INT1U', overwrite=TRUE)
  writeRaster(rucs_list[[var_list$var2[i]]], filename=paste0((tt_ruc_msk_dir), "ruc1_",var_list$var3[i]), format="GTiff", datatype='INT1U', overwrite=TRUE)} # it ends alwyas with band numbers bylayer=TRUE
 
endCluster()

##############################################
#List of accessibility layers at travel time 2
#############################################
acc_files <- list.files(path=(paste0(tt_60to120min)) ,pattern="^tt2_acc_c(.*).tif$",full.names=TRUE,recursive=TRUE) 
print(acc_files)
#Import ruc1_13.tif
ruc1_13 <- paste0(tt_ruc_msk_dir,"ruc1_13.tif")
rucs_list <- list(stack(ruc1_13))
#create an object stack  
acc_s <- stack(acc_files) 
#Empty the list
f1_list <- list() 
#variables
var_list <- list(var1 = 1:6, var2 = 2:7,var3 = 14:19)
##################################
#Start processing for tt2
beginCluster()

for (i in 1:length(var_list$var1)) { #same lenght for the 3 vars
  f1_list[[var_list$var1[i]]] <- clusterR(stack(rucs_list[[var_list$var1[i]]], acc_s[[var_list$var1[i]]]), overlay, arg = list(fun = f1)) #e.g. ruc8.tif
  rucs_list[[var_list$var2[i]]] <- clusterR(stack(rucs_list[[var_list$var1[i]]], f1_list[[var_list$var1[i]]]), overlay, arg = list(fun = f2)) #e.g. ruc1_8.tif
    #Print and export
  print(paste0("Export ruc1_", var_list$var3[i], ".tif ... "))
  writeRaster(rucs_list[[var_list$var2[i]]], filename=paste0((tt_ruc_msk_dir), "ruc1_",var_list$var3[i]), format="GTiff", datatype='INT1U', overwrite=TRUE)} # it ends alwyas with band numbers bylayer=TRUE

endCluster() 

######################################################################################################
#After ruc19.tif create the travel mask around towns of 20k to 50k using the raster 'acc_c7_tt12.tif'
#####################################################################################################
#List of accessibility layers at travel time  1 and 2 for towns 20-50k
#acc_files <- list.files(path=(paste0(towns20to50)) ,pattern="^tt12_acc_c(.*).tif$",full.names=TRUE,recursive=TRUE) 
acc_files <- "/home/daietti/SOFA/data/travel_masks/towns20to50//tt12_acc_c7.tif"
ruc1_19 <- paste0(tt_ruc_msk_dir,"ruc1_19.tif")
stck <- stack(ruc1_19,acc_files)
f1_list <- list()
##################################
#Start processing for towns 20-50k
beginCluster()

f1_result <- clusterR(stck,overlay, arg = list(fun = f1)) 
stck2 <- stack(ruc1_19,f1_result)
ruc_result <- clusterR(stck2, overlay, arg = list(fun = f2)) 
#Print and export
print(paste0("Export ruc1_20.tif ..."))
writeRaster(ruc_result, filename=paste0((tt_ruc_msk_dir), "ruc1_20.tif"), format="GTiff", datatype='INT1U', overwrite=TRUE)
endCluster


#############################################
#List of accessibility layers at travel time 3
#############################################

#Create a copy of the raster in the tt3_cc_c7.tif in the tt_120to180min folder (at the moment is in towns20to50)
writeRaster(raster(paste0(towns20to50,"tt3_acc_c",id,".tif")), filename=paste0((tt_120to180min), "tt3_acc_c7.tif"), format="GTiff", datatype='INT1U', overwrite=TRUE)

acc_files <- list.files(path=(paste0(tt_120to180min)) ,pattern="^tt3_acc_c(.*).tif$",full.names=TRUE,recursive=TRUE)
print(acc_files)

#Import ruc1_20.tif
ruc1_20 <- paste0(tt_ruc_msk_dir,"ruc1_20.tif")
rucs_list <- list(ruc1_20) #can be use original object name used for tt1

#create an object stack  
acc_s <- stack(acc_files) 
#Create empty list
f1_list <- list() 
#variables
var_list <- list(var1 = 1:7, var2 = 2:8, var3 = 21:27)
#var_list <- list(var1 = 1:6, var2 = 2:7, var3 = 21:26)
##################################
#Start processing for tt3
beginCluster()

for (i in 1:length(var_list$var1)) { #same lenght for the 3 vars
  f1_list[[var_list$var1[i]]] <- clusterR(stack(rucs_list[[var_list$var1[i]]], acc_s[[var_list$var1[i]]]), overlay, arg = list(fun = f1)) #e.g. ruc8.tif
  rucs_list[[var_list$var2[i]]] <- clusterR(stack(rucs_list[[var_list$var1[i]]], f1_list[[var_list$var1[i]]]), overlay, arg = list(fun = f2)) #e.g. ruc1_8.tif
  #Print and export
  print(paste0("Export ruc1_", var_list$var3[i], ".tif ... "))
  writeRaster(rucs_list[[var_list$var2[i]]], filename=paste0((tt_ruc_msk_dir), "ruc1_",var_list$var3[i]), format="GTiff", datatype='INT1U', overwrite=TRUE)} # it ends alwyas with band numbers bylayer=TRUE

endCluster() 