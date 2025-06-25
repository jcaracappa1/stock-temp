#Script to generate monthly bottom temperature from GLORYS for Longfin assessment
library(terra)
library(dplyr)

data.dir = 'C:/Users/joseph.caracappa/Documents/Data/GLORYS/GLORYS_daily/'
data.prefix = 'GLORYS_daily_BottomTemp_'
years = 1993:2024

stock.files = list.files(here::here('geometry','yellowtail_cod_stock_area'),pattern = '*\\.shp$',full.names = T)
stock.names = gsub('.shp','',basename(stock.files))

df.ind = 1
j=1
data.month.ls = list()
for(j in 1:length(stock.files)){
  
  # file.shp = terra::project(),'+proj=longlat +datum=WGS84 +no_defs ')  
  file.shp =terra::vect(stock.files[j])
  terra::crs(file.shp) = '+proj=longlat +datum=WGS84 +no_defs '
  
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
                                                           shp.file = NA,
                                                           var.name = 'BottomT',
                                                           agg.time = 'months',
                                                           statistics = 'mean',
                                                           file.time = 'annual',
                                                           touches = T,
                                                           area.names = NA
    )[[1]] %>%
      terra::rast()

    terra::writeCDF(data.month.nc,here::here('data','yellowtail',paste0('GLORYS_BottomT_monthly_yellowtail_',stock.names[j],years[i],'.nc')),varname = 'BottomT',overwrite = T)

    data.month.stat = EDABUtilities::make_2d_summary_ts(data.in = data.mask,
                                                        shp.file =NA,
                                                        var.name = 'BottomT',
                                                        agg.time = 'months',
                                                        area.names = NA,
                                                        statistics = c('mean','sd'),
                                                        file.time = 'annual',
                                                        write.out =F)

    data.month.ls[[df.ind]] = dplyr::bind_rows(data.month.stat) %>%
      dplyr::mutate(month = month.name[time],
                    year = years[i],
                    stock = stock.names[j])%>%
      select(year,month,stock,var.name,statistic,value)
    
    print(stock.names[j])
    print(nrow(data.month.ls[[df.ind]]))
    df.ind = df.ind +1 
    print(df.ind)
  } 
}
data.month.out = dplyr::bind_rows(data.month.ls)

write.csv(data.month.out,here::here('data','yellowtail','GLORYS_monthly_BottomT_ECOMON6_1993_2024.csv'),row.names = F)

