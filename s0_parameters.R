####################################################################################################
####################################################################################################
## 
## Contact Theresa.McMenomy@fao.org and laura.daietti@fao.org 
##Original scripts written in arcpyton by Theresa Mcmenomy. The scripts run in SEPAL or linux OS
## updated version: 2019/11/27
##Methodology and background information can be found in Nelson et. al., 2019. Contact: ###
####################################################################################################

####################################################################################################

### Read all external files with TEXT as TEXT
options(stringsAsFactors = FALSE)

### Create a function that checks if a package is installed and installs it otherwise
packages <- function(x){
  x <- as.character(match.call()[[2]])
  if (!require(x,character.only=TRUE)){
    install.packages(pkgs=x,repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
}

### Install / load necessary packages 
packages(Hmisc)
packages(RCurl)
packages(hexbin)
packages(raster)
packages(gdistance)
packages(rgdal)

packages(raster)
packages(rgeos)
packages(ggplot2)
packages(rgdal)
packages(plyr)
packages(dplyr)
packages(foreign)
packages(reshape2)
packages(survey)
packages(stringr)
packages(tidyr)
packages(devtools)
packages(exact_extract)
library(foreach)
packages(doParallel)

#Others
library(maptools)
library(raster)
library(exactextractr)
library(parallel)
library(foreach)
library(doParallel)

## Set the working directory
rootdir       <- "~/SOFA/"
setwd(rootdir)
rootdir  <- paste0(getwd(),"/")
username <- unlist(strsplit(rootdir,"/"))[3]

############ FIXED DIRECTORIES
scriptdir <- paste0(rootdir,"scripts/")
doc_dir   <- paste0(rootdir,"docs/")
data_dir  <- paste0(rootdir,"data/")
#gadm_dir  <- paste0(rootdir,"data/gadm/")
##ts_dir    <- paste0("/home/",username,"/downloads/tiles_",countrycode,"/")
#bfst_dir  <- paste0(rootdir,"data/bfast_",countrycode,"_",username,"/")
tmp_dir  <- paste0(rootdir,"tmp/")
pop_dir <- paste0(data_dir, "GHSL/")
ruc_pop_dir <- paste0(data_dir,"/ruc_pop/")
if(!dir.exists(ruc_pop_dir)){dir.create(ruc_pop_dir, recursive = T)}




############ USER-DEFINED DIRECTORIES

#travel mask directories
travel_masks_dir <- paste0(data_dir,"travel_masks/")
tt_dir_outmsk_dir <- paste0(tt_dir,"masks/")

tt_0to60min <- paste0(travel_masks_dir, "tt_0to60min/")
tt_60to120min <- paste0(travel_masks_dir, "tt_60to120min/")
tt_120to180min <- paste0(travel_masks_dir, "tt_120to180min/")
towns20to50 <- paste0(travel_masks_dir, "towns20to50/")

#GHS_masks directories
tt_dir <- paste0(data_dir,"/travel_time/")
ghs_mask_dir <- paste0(data_dir,"travel_time/GHS_masks/")
tt_ruc_msk_dir <- paste0(ghs_mask_dir, "tt_ruc_msks/")
towns_msk_dir <- paste0(ghs_mask_dir, "towns/")


#create other directories...
#rucT_dir <- paste0(data_dir, "/rucT_sameext/") #ruc8typ21, ruc8typ22 etc same extent
usa <- paste0(ghs_mask_dir, "usa/")
identifiers <- paste0(data_dir, "identifiers/")







