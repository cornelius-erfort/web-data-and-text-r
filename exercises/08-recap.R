# 08-recap

library(rvest)
library(xml2)
library(stringr)

# Most useful file system functions

# get a list of files
dir()
# or
list.files()

# get a list of all folders
list.dirs()

# Ger a list of files in a specific folder
list.files("nrw")

"1.html" %in% list.files("nrw")

# Get a list with the full file path (including the folder name)
list.files("nrw", full.names = T)

# Create a folder
?dir.create()

# Check whether a folder already exists
dir.exists("nrw")

# Only create a folder, if it doesn't already exist
!dir.exists("nrw")
if(dir.exists("nrw")) dir.create("nrw")

# Check whether a file exists 
file.exists("nrw/1.html")

# Lets only get the file name from a file path
basename("nrw/1.html")

# This also works for URLs
basename("https://posit.cloud/spaces/362605/content/5802995")

# Get the file location (everything but the file name!)
dirname("nrw/1.html")
dirname("https://posit.cloud/spaces/362605/content/5802995")

# Other functions
# file.remove(), file.copy(), file.rename(), ...

# Errors
urls <- c("https://www.hu-berlin.de", "https://www.hu-berlin.dede", "https://www.tu-berlin.de", "https://www.fu-berlin.de")


# Download these URLs (the loop should stop, because the second URL is wrong)
for (url in urls) {
  read_html(url)
}


# Add the try() function
for (url in urls) {
  myhtml <- try(read_html(url))
  if(any(class(myhtml) == "try-error")) next 
}

# Make a folder for our files
dir.create("errors")

# Read and write the HTML
for (url in urls) {
  myhtml <- read_html(url)
  write_html(myhtml, str_c("errors/", basename(url)))
}


# Together with the try() function
for (url in urls) {
  myhtml <- try(read_html(url))
  if(any(class(myhtml) == "try-error")) next 
  write_html(myhtml, str_c("errors/", basename(url)))
}

# Add an if condition to skip files that are already downloaded
urls[1]

basename(urls[1])

str_c("errors/", basename(urls[1]))

file.exists(str_c("errors/", basename(urls[1])))

!file.exists(str_c("errors/", basename(urls[1])))


for (url in urls) {
  if(!file.exists(str_c("errors/", basename(urls[1])))) next
  myhtml <- read_html(url)
  write_html(myhtml, str_c("errors/", basename(url)))
}



# Progress feedback
for (i in 1:100) {
  Sys.sleep(.5)
  cat(".")
}

for (i in 1:100) {
  Sys.sleep(.5)
  cat(i, "of", 100, "\n") 
}


for (url in urls) {
  cat(".")
  myhtml <- try(read_html(url))
  if(any(class(myhtml) == "try-error")) next 
  write_html(myhtml, str_c("errors/", basename(url)))
}



##### More advanced functions: Using httr/httr2 for GET and POST requests

library(httr)
library(httr2)

# Create a (GET) request and show it
"https://www.parlament.gv.at/recherchieren/personen/nationalrat/?WFW_002STEP=1000&WFW_002NRBR=NR&WFW_002GP=AKT&WFW_002R_WF=FR&WFW_002R_PBW=WK&WFW_002M=M&WFW_002W=W&WFW_002page=2" %>% 
  request() %>%  # Define a request
  req_dry_run() # Show it but don't send it

# Not let's send it and have a look
"https://www.parlament.gv.at/recherchieren/personen/nationalrat/?WFW_002STEP=1000&WFW_002NRBR=NR&WFW_002GP=AKT&WFW_002R_WF=FR&WFW_002R_PBW=WK&WFW_002M=M&WFW_002W=W&WFW_002page=2" %>% 
  request() %>% # Define a request
  req_perform() %>% # Send the request
  resp_body_html() %>% html_text2() %>% cat() # Convert the response

# Now let's add an empty body
"https://www.parlament.gv.at/Filter/api/json/post?jsMode=EVAL&FBEZ=WFW_002&listeId=undefined&pageNumber=3&pagesize=10&feldRnr=1&ascDesc=ASC" %>% 
  request %>% # Define a request
  req_body_json(list()) %>% # The body is added here
  req_perform() %>% # Send the request
  resp_body_json() # This converts the answer from JSON

# Let's copy the body from the browser
"https://www.parlament.gv.at/Filter/api/json/post?jsMode=EVAL&FBEZ=WFW_002&listeId=undefined&pageNumber=3&pagesize=10&feldRnr=1&ascDesc=ASC" %>% 
  request %>% # Define a request
  req_body_raw('{"STEP":["1000"],"NRBR":["NR"],"GP":["AKT"],"R_WF":["FR"],"R_PBW":["WK"],"M":["M"],"W":["W"]}') %>% # Add body
  req_perform() %>% # Send the request
  resp_body_string() # Convert the response

# This is how the request looks like
"https://www.parlament.gv.at/Filter/api/json/post?jsMode=EVAL&FBEZ=WFW_002&listeId=undefined&pageNumber=3&pagesize=10&feldRnr=1&ascDesc=ASC" %>% 
  request %>% # Define a request
  req_body_raw('{"STEP":["1000"],"NRBR":["NR"],"GP":["AKT"],"R_WF":["FR"],"R_PBW":["WK"],"M":["M"],"W":["W"]}') %>% # Add body
  req_dry_run() # Show it but don't send it

# Now let's save the answer
mydata <- "https://www.parlament.gv.at/Filter/api/json/post?jsMode=EVAL&FBEZ=WFW_002&listeId=undefined&pageNumber=3&pagesize=10&feldRnr=1&ascDesc=ASC" %>% 
  request %>% # Define a request
  req_body_raw('{"STEP":["1000"],"NRBR":["NR"],"GP":["AKT"],"R_WF":["FR"],"R_PBW":["WK"],"M":["M"],"W":["W"]}') %>% # Add body
  req_perform() %>% # Send the request
  resp_body_string() # Convert the response

mydata

# Looks like a JSON
mydata %>% fromJSON

# Sometimes the server requires cookies
# "CookieJSESSIONID=Lk4vbl0mh7xQvQOHTrKqD-oSQ8zHF9_eLDrbs4Zg.appsrv04e; pddsgvo=j; _pk_id.1.26ca=6875b77360f2e737.1685984810.; _pk_ses.1.26ca=1"

# Sometimes the server requires authentication
?httr2::req_auth_basic()

# Sometimes the server requires a header
?httr2::req_headers()

# Instead of httr2, you can use httr with the functions GET(), POST(), and content()
mydata <- POST("https://www.parlament.gv.at/Filter/api/json/post?jsMode=EVAL&FBEZ=WFW_002&listeId=undefined&pageNumber=3&pagesize=10&feldRnr=1&ascDesc=ASC", body = '{"STEP":["1000"],"NRBR":["NR"],"GP":["AKT"],"R_WF":["FR"],"R_PBW":["WK"],"M":["M"],"W":["W"]}')

content(mydata)$rows %>% do.call(rbind, .) %>% View

# (mydata %>% read_html %>% html_text2 %>% fromJSON)$rows %>% data.frame


################
# YOUR TURN
################

# Let's have a look at Exercise 08 and go through questions you may have.

