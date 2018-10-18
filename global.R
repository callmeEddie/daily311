library(data.table)
library(dplyr)
library(spdplyr)
library(lubridate)
library(geojsonio)
library(tm)
library(NLP)
library(tm)
library(SnowballC)
library(wordcloud)
library(dygraphs)
library(shiny)
library(shinydashboard)
library(leaflet)
library(markdown)
library(RColorBrewer)
library(plotly)


# Read in yearly updated file & preprocess
request_yearly = fread("http://104.248.4.242/data_yearly.csv") %>%

  mutate(created_date = ymd_hms(created_date),
         closed_date = ymd_hms(closed_date),
         incident_zip = trimws(incident_zip)) 


# Read in daily updated file & preprocess
request_daily = fread("http://104.248.4.242/data_daily.csv") %>%

  mutate(created_date = ymd_hms(created_date),
         closed_date = ymd_hms(closed_date),
         incident_zip = trimws(incident_zip))


# Count by zip code 
byzip_yearly = request_yearly %>% 
  group_by(incident_zip) %>% 
  summarize(n = n()) %>% 
  arrange(desc(n))


# Shape file 
nyzip = geojsonio::geojson_read("./zip.json", what='sp') %>%
  left_join(byzip_yearly, by=c("zip"="incident_zip")) %>% 
  mutate(n = ifelse(is.na(n), 0, n))


# List of zip code
listzip = nyzip %>% 
  select(zip, n) %>% 
  arrange(desc(n)) %>% 
  as.data.frame()



