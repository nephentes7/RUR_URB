####################################################
#Step 7: For rural RUC classes (8:27) set null where there is a town:
####################################################
library(parallel)  #multicore processing for speed

#Create empty list
f1_list <- list() # files called ruc8, ruc9, ruc 10 ...NA in values of ruc1__7.tif ==1 and remaining the acc_ c1_tt1 fies and so on..

#function
f1 <- function(x,y){ y[x == 1] <- NA; y} 

##################################
#List of ruc layers from ruc8.tif to ruc27.tif- here for testing only untile ruc13.tif
#list ruc 'original' files
ruRUC_files <-  list.files(path=(paste0(tt_ruc_msk_dir)) ,pattern="^ruc(.*).tif$",full.names=TRUE,recursive=FALSE)
ruRUC_files <- ruRUC_files[!grepl('.*ruc.*._.*\\.tif',ruRUC_files)] 
ruRUC_files <- ruRUC_files[!grepl('.*ruc.*.typ.*\\.tif',ruRUC_files)] 
ruRUC_files <- ruRUC_files[!grepl('.*ruc.*.(28).*\\.tif',ruRUC_files)] #until ruc27- exclude ruc28
print(ruRUC_files) #are not ordered print(ruRUC_files[1])

#create an object stack  
ruRUC_s <- stack(ruRUC_files) 

#Import typ21_22_23.tif
typ21_22_23 <- paste0(tt_ruc_msk_dir,"typ21_22_23.tif")
out_list <- list(stack(typ21_22_23))

#variables
var_list <- list(
  var1 = 1:6,  #1:6 #1 ... 6; #set depending on the number of the ruc layers 
  var2 = 2:7  #2: 7; l
)


#Start processing for tt1
beginCluster()

for (i in 1:length(var_list$var1)) { #same lenght for the 3 vars
  f1_list[[var_list$var1[i]]] <- clusterR(stack(typ21_22_23, ruRUC_s[[var_list$var1[i]]]), overlay, arg = list(fun = f1)) #e.g. ruc8.tif
  #print(paste0("Exporting ruc",var_list$var3[i],"r.tif ..."))
  print(paste0("Export ",substr(ruRUC_files[i],60,64),"r.tif ..."))
  writeRaster(f1_list[[var_list$var1[i]]], filename=paste0((tt_ruc_msk_dir),substr(ruRUC_files[i],60,63),"r"), format="GTiff", datatype='INT1U', overwrite=TRUE)}

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
var_list <- list(var1 = 1:6, var2 = 2:7, var3 = 21:26)

##################################
#Start processing for tt3
##################################
beginCluster()

for (i in 1:length(var_list$var1)) { #same lenght for the 3 vars
  f1_list[[var_list$var1[i]]] <- clusterR(stack(rucs_list[[var_list$var1[i]]], acc_s[[var_list$var1[i]]]), overlay, arg = list(fun = f1)) #e.g. ruc8.tif
  rucs_list[[var_list$var2[i]]] <- clusterR(stack(rucs_list[[var_list$var1[i]]], f1_list[[var_list$var1[i]]]), overlay, arg = list(fun = f2)) #e.g. ruc1_8.tif
  #Print and export
  print(paste0("Export ruc1_", var_list$var3[i], ".tif ... "))
  writeRaster(rucs_list[[var_list$var2[i]]], filename=paste0((tt_ruc_msk_dir), "ruc1_",var_list$var3[i]), format="GTiff", datatype='INT1U', overwrite=TRUE)} # it ends alwyas with band numbers bylayer=TRUE

endCluster() 


