#############  COMPUTE SOLAR RADIATION / ASOS & FORECAST

### Start with ASOS observed data
 ## Use QC data set / set Working Directory
 setwd("/home/wpage/Documents/ASOS")

 ## Read-in QC obs data
 data = read.csv("asos2015_mod.csv")
 data$X = NULL
 data$datetime = as.character(data$datetime)
 
 ## Create function
 solFun = function(datetime,lat,lon) {
  # Break up datetime
  time = unlist(strsplit(datetime,"[-: ]"))
  Year = time[1]
  Month = time[2]
  Day = time[3]
  hour = time[4]
  min = time[5]
  sec = time[6]
  # Build call
  changedir = "cd /home/wpage/Documents/firewx-evaluation/src/solpos/build && "
  solar = paste(changedir,"./compute_solar ","--year ",Year," --month ",Month,
  " --day ",Day," --hour ",hour," --minute ",min," --second ",sec," --lat ",lat,
  " --lon ",lon," --tz 0",sep="")
  # Run the program
  run = as.numeric(system(solar,intern=TRUE))
  return(run)  }

 ## Run function
 data$solarMax_wm2 = mapply(solFun,data$datetime,data$lat,data$lon)
  
 ## Convert to station solar radiation by accounting for cloud cover
 cloudFun = function(cloud_percent,maxsolar) {
  try1 = ifelse(cloud_percent < 10, (0.93*maxsolar),ifelse(cloud_percent >= 10&
  (cloud_percent < 50), (0.8*maxsolar),ifelse((cloud_percent >= 50) & 
  (cloud_percent <90),(0.63*maxsolar),ifelse(cloud_percent >= 90, 
  (0.25*maxsolar),"error"))))
  return(try1)  }

 ## Run solar correction function
 solar_wm2 = mapply(cloudFun,data$cloud_cover_percent,data$solarMax_wm2)
 data = cbind(data,solar_wm2)
  
 ## Fix the output order to match other data
 data = data[c("station_id","station_type","data_type","lon","lat","datetime",
 "air_temp_c","rh","wind_speed20ft_mps","wind_speedMid_mps","wind_direction_deg",
 "cloud_cover_percent","precip_mm","solar_wm2","FM40","asp_deg","elev_m","slope_deg",
 "CBD_kgm3","CBH_m","CC_percent","CH_m")]

 ## Save final output
 write.csv(data,file="asos2015_final.csv")


### Run ASOS forecast data
 ## Set Working Directory
 setwd("/media/wpage/Elements/Page/NDFD_Project/Weather/ASOS")

 ## Read-in data
 data = read.csv("/media/wpage/Elements/Page/NDFD_Project/Weather/ASOS/asos2015pred_mod.csv")
 data$X = NULL
 data$datetime = as.character(data$datetime)

 ## Clean up / remove cloud cover rows with NAs
 data = data[complete.cases(data$cloud_cover_percent),]
 data = data[with(data,order(station_id,datetime)),]

 ## Run function
 solarMax_wm2 = mapply(solFun,data$datetime,data$lat,data$lon)

 ## Run solar correction function
 solar_wm2 = mapply(cloudFun,data$cloud_cover_percent,data$solarMax_wm2)
 data = cbind(data,solar_wm2)

 ## Save backup
 write.csv(data,file="/Elements/Page/NDFD_Project/Weather/ASOS/asos2015pred_mod.csv")

 ## Fix the output order to match other data
 data = data[c("station_id","station_type","data_type","lon","lat","datetime",
 "air_temp_c","rh","wind_speed20ft_mps","wind_speedMid_mps","wind_direction_deg",
 "cloud_cover_percent","precip_mm","solar_wm2","FM40","asp_deg","elev_m","slope_deg",
 "CBD_kgm3","CBH_m","CC_percent","CH_m")]

 ## Save final output
 write.csv(data,file="asos2015pred_final.csv")



### Run RAWS forecast data

 ## Set Working Directory
 setwd("/media/wpage/Elements/Page/NDFD_Project/Weather/RAWS/NDFD_Forecast_mod")

 ## Read-in data
 data = read.csv("raws2015pred_mod.csv")
 data$datetime = as.character(data$datetime)

 ## Clean up / remove cloud cover rows with NAs
 data = data[complete.cases(data$cloud_cover_percent),]
 data = data[with(data,order(station_id,datetime)),]

 ## Run function / Parallel
 solarMax_wm2 = mcmapply(solFun,data$datetime,data$lat,data$lon,mc.cores = 4)
 
 ## Add solarMax to dataframe
 data = cbind(data,solarMax_wm2)

 ## Run solar correction function
 solar_wm2 = mcmapply(cloudFun,data$cloud_cover_percent,data$solarMax_wm2,mc.cores=4)
 data = cbind(data,solar_wm2)

 ## Fix the output order to match other data
 data = data[c("station_id","station_type","data_type","lon","lat","datetime",
 "air_temp_c","rh","wind_speed20ft_mps","wind_speedMid_mps","wind_direction_deg",
 "cloud_cover_percent","precip_mm","solar_wm2","FM40","asp_deg","elev_m","slope_deg",
 "CBD_kgm3","CBH_m","CC_percent","CH_m")]

 ## Save final output
 write.csv(data,file="raws2015pred_final.csv")

