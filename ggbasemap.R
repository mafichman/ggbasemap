# Code by Matt Harris for putting a ggmap basemap on a ggplot with sf data

#First libraries and a key function

library(sf)
library(ggmap)
library(tidyverse)
library(jsonlite)

#the magic happens here
ll <- function(dat, proj4 = 4326){
st_transform(dat, proj4)
}

#Next download some neighborhoods and crime data

#get some neighborhoods data and find just the spruce hill nhood
nhoods <- st_read("https://raw.githubusercontent.com/azavea/geo-data/master/Neighborhoods_Philadelphia/Neighborhoods_Philadelphia.geojson")
spruceHill <- filter(nhoods, name == "SPRUCE_HILL") %>% st_transform('ESRI:102728')

crimes <- 
fromJSON("https://phl.carto.com/api/v2/sql?q=SELECT%20*%20FROM%20incidents_part1_part2%20WHERE%20(dispatch_date_time%20%3E=%20current_date%20-%2030)%20AND%20Text_General_Code%20in%20(%27Aggravated%20Assault%20No%20Firearm%27,%20%27Aggravated%20Assault%20Firearm%27,%20%27Burglary%20Residential%27,%20%27Motor%20Vehicle%20Theft%27)")$rows

spruceHill_crimes <- 
crimes %>%
na.omit %>%
st_as_sf(coords = c("point_x", "point_y"), crs = 4326) %>%
st_transform('ESRI:102728') %>%
.[spruceHill,]

#Get a basemap

#get a basemap
base_map <- get_map(location = unname(st_bbox(ll(st_buffer(st_centroid(spruceHill),11000)))),
maptype = "satellite")

#map base map
ggmap(base_map)

#Map your crimes onto the basemap

ggmap(base_map) + 
geom_sf(data=ll(spruceHill_crimes), inherit.aes = FALSE) + 
ggtitle("Recent Spruce Hill Crimes") 
