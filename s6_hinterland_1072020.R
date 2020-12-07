#####################################################################################################
#Step 6: Classify each remaining towns as "dispersed towns" in the hinterland (over 3h from any city)
#####################################################################################################

#Import typ23max20k and layers
typ23max20k <- list((paste0(towns_msk_dir, "typ23max20k.tif")))
typmsk <-  list.files(path=(paste0(towns_msk_dir)) ,pattern="^typ(.*)[21,22]_msk.tif$|typ23max20k.tif",full.names=TRUE,recursive=FALSE)
#Stack of the trhee layers
typmsk3 <- stack(typmsk)
nlayers(typmsk3)


library(parallel)
beginCluster()
ftest <- function(x,y){ifelse(x==1 & y==1, 1, NA)}
f1_list <- list()
s <- stack()

strt<-Sys.time()

for (i in 1:nlayers(typmsk3)) { 
  f1_list[[i]] <- clusterR(stack(raster(paste0(tt_ruc_msk_dir, "hinter2.tif")), typmsk3[[i]]), overlay, arg= list(fun=ftest))
  print(paste0("Processing ruc28typ2",i, ".tif ..."))
  y <- stack(f1_list)}
#Create ruc18.tif agregating all towns - 21-22-23
  fun = function(x, na.rm=FALSE) {sum(x, na.rm = na.rm)} 
  s <- clusterR(y, stackApply, args=list(indices=c(1,1,1), fun=fun)) #it works in parallel
  print(paste0("Exportg ruc28.tif ..."))
  writeRaster(s, filename=paste0((tt_ruc_msk_dir), "ruc28"), format="GTiff", datatype='INT1U', options="COMPRESS=LZW", overwrite=TRUE)#}
  #create one layer from typmsk: typ23max20k.tif- typ21_msk.tif - typ22_msk.tif
  p <- clusterR(typmsk3,stackApply, args=list(indices=c(1,1,1), fun=fun))
  print(paste0("Export type21_22_23.tif ..."))
  writeRaster(p, filename=paste0((tt_ruc_msk_dir), "typ21_22_23"), format="GTiff", datatype='INT1U', options="COMPRESS=LZW", overwrite=TRUE)
  
print(Sys.time()-strt)
endCluster()