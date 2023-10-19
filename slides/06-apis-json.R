# 06-apis-json
library(rvest)
library(jsonlite)
library(plyr)

# JSON
'{"animal" : "dog", "color" : "grey", "name" : "John"}' %>% fromJSON()

myjson <- '{"animals": [
  {"animal" : "dog", "color" : "grey", "name" : "John"},
  {"animal" : "cat", "color" : "white", "name" : ["Charlie", "Kitty", "Bruno"]}
]}' 

fromJSON(myjson)

fromJSON(myjson)$animals %>% unnest_longer("name")

# Typical call to an API: Address, endpoint, "?", 
# then list of parameters separated by "&".
"https://api.com/v1/endpoint?key1=value1&key2=value2"

# Load the page
myhtml <- read_html("https://geocoding-api.open-meteo.com/v1/search?name=Rostock")

# Get only the text
myjson <- html_text2(myhtml)

cat(myjson)

# Convert the JSON into an R object
parse_json(myjson)

fromJSON(myjson)

fromJSON("https://geocoding-api.open-meteo.com/v1/search?name=Rostock")

# Store in a dataframe
mydata <- fromJSON(myjson)$results

# Take only the first row
mydata[1, ]

# How do we get several cities at once?
cities <- c("New York", "Berlin", "Bitterfeld", "Santiago", "Shenzen", "Mombasa", "Auckland", "Cape Town", "Delhi")

# For loop

# Use coordinates on a map
library(ggplot)

world <- map_data("world")

ggplot() +
    geom_map(
      data = world , map = world,
      aes(long, lat, map_id = region), fill = "grey", color = "white", size = .1) +
    geom_point(data = city_data, aes(longitude, latitude, fill = country), color = "black", size = 2, shape = 21) + 
    coord_fixed()

# Load weather data using coordinates
latitude <- -33.92584
longitude <- 18.42322

api_request <- str_c("https://archive-api.open-meteo.com/v1/archive?latitude=", latitude, "&longitude=", longitude,"&start_date=2020-05-16&end_date=2020-05-17&hourly=temperature_2m")

mydata <- fromJSON(api_request)

data.frame(mydata$hourly)

URLencode(" ")


##############
# YOUR TURN
##############

# The paper from the presentation uses data from the FEC.
# The FEC offers various ways to access their data through their API.
# The API requires authentication through a token that you can get by registering. 
# To test the API, you can use the token "DEMO_KEY". 
# The API calls will look like "https://api.open.fec.gov/v1/endpoint/?key1=value1&token=DEMO_KEY"

# This is a call to the endpoint "names/candidates/", with the parameters api_key and q (query).
fec_data <- fromJSON("https://api.open.fec.gov/v1/names/candidates/?api_key=DEMO_KEY&q=Joseph%20Crowley")

# 1. Look at the documentation at: "https://api.open.fec.gov/developers/"

# 2. Find the correct call to get the filings for Joseph Crowley.
# You can find his ID in the results from the call above.
# Remember that URLs cannot contain spaces.
fec_data <- fromJSON("https://api.open.fec.gov/v1/candidate/H8NY07046/filings?api_key=DEMO_KEY")
fec_data

# 3. What types of data can you find in the results?