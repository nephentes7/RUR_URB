##############################################################
#Zonal statistics by country
#############################################################

#Import low density (l) pop files
popl_files <-  list.files(path=(paste0(ruc_pop_dir)), pattern="^r(.*)l.tif$",full.names=TRUE,recursive=FALSE)
popl_files 

#Import high density (h) pop files
poph_files <-  list.files(path=(paste0(ruc_pop_dir)), pattern="^r(.*)h.tif$",full.names=TRUE,recursive=FALSE)
poph_files 

#Import adm boundary files (shapefile)

shp <- readOGR(paste0("~/SOFA2020/GIS/","g2015_2014_0.shp"))
shp
#Create a copy
shpori <- shp

#This can be done for both high and low pop together- here examle for low density layers
popl_files.names <- basename(popl_files)
popl_files.names
s <-stack(popl_files)
s
#Start the loop
strt<-Sys.time()
#for (i in 1:length(popl_files)){
for (i in 1:2){ #for testing - just two files
  print(i)
  poly <- sf::st_as_sfc(shp)
  ex <- exact_extract(s, poly, 'sum')

}
print(Sys.time()-strt)
#)

#write to a data frame
df <- data.frame(ex)
df
head(df)


shpdf <- as.data.frame(shp)
results <- append(shpdf, df) 
f <- as.data.frame((results))
f
head(f)
fori <- f
f <- fori
# Across all columns, replace all instances of "sum" with " "
names(f) <- gsub("sum.r", "r", names(f))
head(f)
write.csv(f, file = paste0(ruc_pop_dir, "stat_lowpop.csv"))





