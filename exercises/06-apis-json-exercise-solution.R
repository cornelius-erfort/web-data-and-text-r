# 06-apis-json-exercise

library(stringr)
library(jsonlite)
library(dplyr)

# For a research project about the role of the media, you need some data about
# news articles. Fortunately, the NY Times provides several APIs to provide the data
# you need.

# 1. Create a developer account at the NYT: "https://developer.nytimes.com/get-started"

# 2. Sign in, and go to "Apps". (This is in the top right corner.)

# 3. Create a new app, give it a name, and enable the "Article Search API".

# 4. Copy the API Key (don't share it with others ;).
apikey <- readLines("api-key-nyt.txt")

# 5. Read the documentation for the Article Search API.

# 6. Replicate the example call with you API key.
apicall <- str_c("https://api.nytimes.com/svc/search/v2/articlesearch.json?q=election&api-key=", apikey)

# 7. Send the call to the API, and store it in an object.
apiresults <- fromJSON(apicall)

# 8. Inspect the results. What types of data did the API give? How are they ordered?
View(apiresults)

# 9. Instead of "election", search for articles with "humboldt".
apicall <- str_c("https://api.nytimes.com/svc/search/v2/articlesearch.json?q=humboldt&api-key=", apikey)
apiresults <- fromJSON(apicall)

str(apiresults)
apiresults$response$docs

View(apiresults)

# 10. The API only returned data about ten articles. How many results are there in total? 
# Make a call to the API that gets you the data for results 11-20.
# (hint: This is explained in the documentation for the API.)
apicall <- str_c("https://api.nytimes.com/svc/search/v2/articlesearch.json?q=humboldt&api-key=", apikey, "&page=1")
apiresults <- fromJSON(apicall)
View(apiresults)

# 11. Force the results into a dataframe, using the function data.frame().
humboldt <- data.frame(apiresults)

# 12. Extract only the variable for the publication date.
humboldt$response.docs.pub_date

# 13. Use the function substr() to only get the year from this variable. 
# (hint: ?substr() shows you how to use the function)
?substr()
substr(humboldt$response.docs.pub_date, 1, 4)

# 14. Using the call from step 10, build a for loop for the first 3 pages of the results.
# Force the results into a dataframe, and bind the results for each call together to one
# dataframe. You can use the bind_rows() function from the dplyr package.
# MAKE SURE TO RESPECT THE RATE LIMIT of the API (hint: Sys.sleep()). You find info
# about that in the API documentation.

# Create empty dataframe
nyt_data <- data.frame()

# Build for loop that iterates through number 1-3
for (i in 1:3) {
  # API call
  apicall <- str_c("https://api.nytimes.com/svc/search/v2/articlesearch.json?q=humboldt&api-key=", apikey, "&page=", i)
  
  # Send call to API
  apiresults <- fromJSON(apicall)
  
  # Force to dataframe
  apiresults <- data.frame(apiresults)
  
  # Add to dataframe for all results
  nyt_data <- dplyr::bind_rows(nyt_data, apiresults)
  
  # Wait for >12 seconds
  Sys.sleep(12.1)
}

# Optional: Use this package to replicate the assignment: "https://github.com/mkearney/nytimes". 
# (hint: you can also provide the API key to the function using the argument "apikey = YOUR_API_KEY")
# How do your results differ?

## replace x's with nytimes article search API key which
##    you can acquire by visiting the following URL:
##    https://developer.nytimes.com/signup

install.packages("devtools")
devtools::install_github("mkearney/nytimes")

## load nytimes package
library(nytimes)

## get http response objects for search about humboldt
nytsearch <- nyt_search("humboldt", n = 30, apikey = apikey)

## convert response object to data frame
nytsearchdf <- data.frame(nytsearch)

## preview data
View(nytsearchdf)

