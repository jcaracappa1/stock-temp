#Script to generate monthly bottom temperature from GLORYS for Longfin assessment
library(terra)
library(dplyr)

data.dir = 'C:/Users/joseph.caracappa/Documents/Data/GLORYS/GLORYS_daily/'
data.prefix = 'GLORYS_daily_BottomTemp_'
years = 1993:2024

# file.shp = terra::project(),'+proj=longlat +datum=WGS84 +no_defs ')  
file.shp =terra::vect(here::here('geometry','ECOMON6.shp'))
area.names = file.shp$SUBAREA

terra::crs(file.shp) = '+proj=longlat +datum=WGS84 +no_defs '


data.month.ls = list()
i=1
for(i in 1:length(years)){
  
  data.file = paste0(data.dir,data.prefix,years[i],'.nc')
  
  data.mask = EDABUtilities::mask_nc_2d(data.in = data.file,
                            write.out = F,
                            min.value = -10,
                            max.value = 999,
                            binary = F,
                            var.name = 'BottomT',
                            shp.file = file.shp)
  
  data.month.nc = EDABUtilities::make_2d_summary_gridded(data.in = data.mask,
                                                      write.out = F,
                                                      shp.file = file.shp,
                                                      var.name = 'BottomT',
                                                      agg.time = 'months',
                                                      statistic = 'mean',
                                                      touches = T,
                                                      area.names = area.names
                                                      )[[1]]
  
  terra::writeCDF(data.month.nc,here::here('data','longfin',paste0('GLORYS_BottomT_monthly_longfin_ECOMON6_',years[i],'.nc')),varname = 'BottomT',overwrite = T)
  
  data.month.mean = EDABUtilities::make_2d_summary_ts(data.in = data.mask,
                                    shp.file =file.shp,
                                    var.name = 'BottomT',
                                    agg.time = 'months',
                                    area.names = area.names,
                                    statistic = 'mean',
                                    write.out =F) 
  
  data.month.sd = EDABUtilities::make_2d_summary_ts(data.in = data.mask,
                                                      shp.file =file.shp,
                                                      var.name = 'BottomT',
                                                      agg.time = 'months',
                                                      area.names = area.names,
                                                      statistic = 'sd',
                                                      write.out =F) 
    
  data.month.ls[[i]] = dplyr::bind_rows(data.month.mean,data.month.sd)%>%
    dplyr::mutate(month = month.name[time],
                  year = years[i])%>%
    select(year,month,var.name,area,statistic,value)
    
}
data.month.out = bind_rows(data.month.ls)

write.csv(data.month.out,here::here('data','longfin','GLORYS_monthly_BottomT_ECOMON6_1993_2024.csv'),row.names = F)
