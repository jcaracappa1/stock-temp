#Script to extract bottom trawl survey bottom temperature by area by date

#Load coordinate data
coords = read.csv(here::here('data-raw','bts_coordinates.csv')) |> 
  dplyr::select(lat,lon,date)
  

EDABUtilities::extract_daily_coord(input.dir = 'C:/Users/Joseph.Caracappa/Documents/Data/GLORYS/GLORYS_daily/',
                                   input.prefix = 'GLORYS_daily_BottomTemp_',
                                   input.type = 'annual',
                                   output.dir = 'C:/Users/joseph.caracappa/Documents/Data/GLORYS/bts_stations/',
                                   output.prefix = 'bottom_trawl_survey_strata_GLORYS_',
                                   coordinates = coords,
                                   var.name = 'BottomT',
                                   statistics = c('mean','sd'),
                                   write.out =T)
