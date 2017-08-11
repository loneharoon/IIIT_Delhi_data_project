change_year <- function(xts_yeardata){
  #function used to change the year of given input xts timeseries
  y = xts_yeardata
  year = unique(lubridate::year(index(y)))
  if(year==2016){
    step = 0
  }else if(year > 2016){
    step = 2016-year
  }else{
    step = 2016-year
  }
  print(step)
  index(y) <- index(y) + step * 365*24*60*60
  return(y)
}


