#############  QUALITY CONTROL OBS WEATHER DATA  ############

### Set Working Directory
setwd("/home/wpage/Documents/RAWS")

### Read in state records data and raws state data
records = read.csv("records.csv")
wrcc = read.csv("wrcc.csv")
wrcc$WRCC_ID = tolower(wrcc$WRCC_ID)

### Work with RAWS data
 ## Set Working Directory
 setwd("/home/wpage/Documents/RAWS")

 ## Read-in modifed 2015 RAWS data - full version has 11594657 rows
 data = read.csv("raws2015_mod.csv")
 data$X = NULL

 ## Remove any row with a NA in it - nrow = 11592315
 data = data[complete.cases(data),]

 ## Sort data by station_id then datetime
 data = data[with(data,order(station_id,datetime)),]

 ## Fix RH: remove obs <0 or >100; obs constant > 24 hours - nrow= 11463082
 work = subset(data,(data$rh > 0) & (data$rh < 101))
 work = subset(work,(sequence(rle(as.character(work$rh))$lengths))< 24)
  
 ## Fix wind speed: remove obs <0 or > 51 mps; constant > 12 hours  - nrow= 11281145
 work = subset(work,(work$wind_speed20ft_mps >=0) & (work$wind_speed20ft_mps <51))
 work = subset(work,(sequence(rle(as.character(work$wind_speed20ft_mps))$lengths))< 12)

 ## Fix wind direction: remove obs <0 or > 360; constant > 8 hours  - nrow= 11241887
 work = subset(work,(work$wind_direction_deg >= 0) & (work$wind_direction_deg <=360))
 work = subset(work,(sequence(rle(as.character(work$wind_direction_deg))$lengths))<= 8)

 ## Organize state records
 n.rec = records[,c("State","Element","Value","Units")]
 n.rec$StateCode = state.abb[match(n.rec$State,state.name)]
 n.rec = subset(n.rec,Element=="All-Time Maximum Temperature"| Element==
 "All-Time Minimum Temperature"|Element=="All-Time Greatest 24-Hour Precipitation")
 n.rec$State = as.character(n.rec$State)
 n.rec$Element = as.character(n.rec$Element)
 n.rec$Units = as.character(n.rec$Units)
 n.rec$Value = as.numeric(as.character(n.rec$Value))
 for (i in 1:length(n.rec[,1])) {              # Fix units
 if(n.rec$Units[i]=="degrees F") {n.rec$nValue[i] = (n.rec$Value[i]-32)*(5/9)} else 
 {n.rec$nValue[i]= (n.rec$Value[i]*25.4)} }
 n.rec = n.rec[complete.cases(n.rec),]

 n.wrcc = wrcc[,c("StateCode","WRCC_ID")]
 n.rec$StateCode = state.abb[match(n.rec$State,state.name)]
 f.rec = merge(n.rec,n.wrcc,by=c("StateCode"))
 
 ## Fix air temp: constant > 24 h - nrow= 11237906
 work = subset(work,(sequence(rle(as.character(work$air_temp_c))$lengths))<= 24)

 ## Fix precip: precip < 0 - nrow= 11237906 
 work = subset(work,(precip_mm >= 0))

 ## Fix air temp and precip based on historical max and min - nrow = 11247617 
 n.df = data.frame() 
 st = unique(f.rec$StateCode)
 for (i in 1:length(st)) {
  temp = subset(f.rec,StateCode==st[i])
  stn = temp$WRCC_ID
  temp2 = subset(work,station_id %in% stn)
  maxT = temp[(which(temp$Element=="All-Time Maximum Temperature"))[1],c("nValue")]
  minT = temp[(which(temp$Element=="All-Time Minimum Temperature"))[1],c("nValue")]
  maxP = temp[(which(temp$Element=="All-Time Greatest 24-Hour Precipitation"))[1],
  c("nValue")]
  temp3 = subset(temp2,(air_temp_c >= minT) & (air_temp_c <= maxT) & (precip_mm <=    
  maxP))
  n.df = rbind(temp3,n.df) }
  work = n.df

 ## Fix solar radiation: remove values < 0 - nrow = 11038215 - 5% drop
 work = subset(work,(solar_wm2 >= 0))

 ## Export out QC data
 write.csv(work,file="raws2015_final.csv")



### Work with ASOS data
 ## Set Working Directory
 setwd("/home/wpage/Documents/ASOS")

 ## Read-in modifed 2015 ASOS data - full version has 8136648 rows
 files = list.files("/home/wpage/Documents/ASOS/ASOS_modified")
 data = data.frame()
 for (i in 1:length(files)) {
  temp = read.csv(paste("/home/wpage/Documents/ASOS/ASOS_modified/",files[i],sep=""))
  data = rbind(temp,data) }
 data$X = NULL

 ## Get station_ids for each state
 Stn=data.frame()
 for (i in 1:length(files)) {
  temp = read.csv(paste("/home/wpage/Documents/ASOS/ASOS_modified/",files[i],sep=""))
  temp$station_id = as.character(temp$station_id)
  stns = data.frame(unique(temp$station_id))
  stns$State = files[i]
  Stn = rbind(stns,Stn) }
 colnames(Stn)[1] = "station_id"
 for (i in 1:length(Stn[,1])) {
 nam = unlist(strsplit(Stn$State[i],split='.csv'))[1]
 Stn$St[i] = nam }
 Stn$StateCode = state.abb[match(Stn$St,state.name)]
 
 ## Remove any row with a NA in it - nrow = 7751705
 data = data[complete.cases(data),]

 ## Sort data by station_id then datetime
 data = data[with(data,order(station_id,datetime)),]

 ## Fix RH: remove obs <0 or >100; obs constant > 24 hours - nrow= 7732738 
 work = subset(data,(data$rh > 0) & (data$rh < 101))
 work = subset(work,(sequence(rle(as.character(work$rh))$lengths))< 24)
  
 ## Fix wind speed: remove obs <0 or > 51 mps; constant > 12 hours  - nrow= 7645838
 work = subset(work,(work$wind_speed20ft_mps >=0) & (work$wind_speed20ft_mps <51))
 work = subset(work,(sequence(rle(as.character(work$wind_speed20ft_mps))$lengths))< 12)

 ## Fix wind direction: remove obs <0 or > 360; constant > 8 hours  - nrow= 7563276
 work = subset(work,(work$wind_direction_deg >= 0) & (work$wind_direction_deg <=360))
 work = subset(work,(sequence(rle(as.character(work$wind_direction_deg))$lengths))<= 8)

 ## Fix air temp: constant > 24 h - nrow= 7563074
 work = subset(work,(sequence(rle(as.character(work$air_temp_c))$lengths))<= 24)

 ## Fix precip: precip < 0 - nrow= 7563074 
 work = subset(work,(precip_mm >= 0))

 ## Fix air temp and precip based on historical max and min - nrow = 6457448
 f.rec = merge(n.rec,Stn,by=c("StateCode")) 
 n.df = data.frame() 
 st = unique(f.rec$StateCode)
 for (i in 1:length(st)) {
  temp = subset(f.rec,StateCode==st[i])
  stn = temp$station_id
  temp2 = subset(work,station_id %in% stn)
  maxT = temp[(which(temp$Element=="All-Time Maximum Temperature"))[1],c("nValue")]
  minT = temp[(which(temp$Element=="All-Time Minimum Temperature"))[1],c("nValue")]
  maxP = temp[(which(temp$Element=="All-Time Greatest 24-Hour Precipitation"))[1],
  c("nValue")]
  temp3 = subset(temp2,(air_temp_c >= minT) & (air_temp_c <= maxT) & (precip_mm <=    
  maxP))
  n.df = rbind(temp3,n.df) }
  work = n.df

 ## nrow = 6457448 - 21% drop

 ## Export out QC data
 write.csv(work,file="asos2015_final.csv")


### Continue QC on final data base
 ## Import data
 setwd("/media/wpage/Elements/Page/NDFD_Project/Weather")
 library(data.table)
 data = fread("final.csv")
 data = as.data.frame(data)

 ## Order data
 data = data[with(data,order(station_type,station_id,datetime,data_type)),]

 ## Fix solar radiation: it appears that station ccpt during part of December had solar
 ## radiation values that were 1000 too big 
 b.loc = grep(TRUE,ifelse(data$solar_wm2 > 2000,'TRUE',data$solar_wm2))
 
 for (i in 1:length(b.loc)) {
  data$solar_wm2[b.loc[i]] = data$solar_wm2[b.loc[i]] / 1000  }

 ### Save new output
 setwd("/media/wpage/Elements/Page/NDFD_Project/Weather")
 library(data.table)
 fwrite(data,"final2.csv")


