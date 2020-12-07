########################################################################
#Step 8: Create HD and LD population layers + multiple HD LD pop by mask
########################################################################

#Create HD and LD pop masks
#Import population layer if not yet imported
ghs_pop <- raster(paste0(pop_dir, "GHS_POP_E2015_GLOBE_R2019A_4326_30ss_V1_0.tif"))
crs(ghs_pop) #wgs
plot(ghs_pop)

#Functions for reclassification
f3 <- function(x){ifelse(x < 1500,NA,x)} #POP ld
f4 <- function(x){ifelse(x >= 1500,NA,x)} #POP hd

beginCluster()
strt<-Sys.time()
#HD mask
s <- clusterR(stack(ghs_pop), overlay, arg= list(fun=f3))
print(paste0("Export POP ",substr((capture.output(f3)),21,22),"1500: LD pop layer  ..."))
writeRaster(s, filename = paste0(paste0(pop_dir), "pop_ld"), format="GTiff", overwrite=TRUE)
#LD mask
ss <- clusterR(stack(ghs_pop), overlay, arg= list(fun=f4))
print(paste0("Export POP ",substr((capture.output(f4)),21,23),"1500: HD pop layer  ..."))
writeRaster(ss, filename = paste0(paste0(pop_dir), "pop_hd"), format="GTiff", overwrite=TRUE)
#plot(s)
print(Sys.time()-strt)
endCluster()
#Time difference of 31.57672 mins
