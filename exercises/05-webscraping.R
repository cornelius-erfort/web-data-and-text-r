# 05-webscraping


## Manipulating URLs
# We can use stringr to create a vector of URLs we want to download.

1:10

str_c("https:///website.com/page/", 1:10)

## Example: Press releases from Labour

"https://labour.org.uk/category/latest/press-release"

links <- str_c("https://labour.org.uk/category/latest/press-release/page/", 1:5, "/")
links


## How do we download multiple HTMLs?
# For loop

for (element in c("one", "two", "three")) {
  print(element)  
}

## Pause R
# Sys.sleep(seconds) pauses R for the specified time

for (element in c("one", "two", "three")) {
  print(element)
  Sys.sleep(2)
}


# Create a folder
dir.create("labour")

# Use a for loop to download several link

links

basename(links)

for (link in links) {
  print(link)
  filename <- str_c("labour/", basename(link), ".html")
  print(filename)
  myhtml <- read_html(link)
  write_html(myhtml, file = filename)
  Sys.sleep(1)
}


## Manage files
# list.files(folder, full.names = TRUE) returns a vector with all files (and folders in the folder)

# file.exists(file) returns TRUE when the file exists, otherwise FALSE

# dir.create(folder) creates the folder

## Manage files

for (link in links) {
  filename <- basename(link)
  if(!file.exists(filename)) next
  myhtml <- read_html(link)
  # ...
}


## Useful functions

# if(condition) expression, if condition: only runs expression if condition is TRUE

# ! Logical NOT operator`, inverts a logical (TRUE -> FALSE, FALSE -> TRUE)

# vector_1 %in% vector_2 operator to check whether the elements from vector_1 are in vector_2


## Collecting links from HTML

#  We can use rvest to extract links from HTMLs (href attribute)

myhtml <- read_html("labour/1.html") # Read html

myelements <- html_elements(myhtml, ".full-link") # Extract the elements with the links to the individual HTMLs

links <- html_attr(myelements, "href") # Extract the links

head(links)


# Get links from all downloaded pages

list.files("labour")

list.files("labour", full.names = T)

files <- list.files("labour", full.names = T)


links <- c()
for (file in files) {
  
  myhtml <- read_html(file) # Read html
  
  myelements <- html_elements(myhtml, ".full-link") # Extract the elements with the links to the individual HTMLs
  
  links <- c(links, html_attr(myelements, "href")) # Extract the links and add them to the links vector
  
}

length(links)

################
# YOUR TURN
################


# You were asked to gather the plenary protocols for the current 18th legislature of the state parliament of North Rhine-Westphalia. 
# Unfortunately, the IT department of the parliament is unable to provide you the documents directly.
# Instead they only sent you the following link to their online database:
# "https://www.landtag.nrw.de/home/dokumente/dokumentensuche/ubersichtsseite-reden--protoko-1/protokolle-18-wahlperiode-2022-2.html?ausschuss=Plenum&page=1"

# 1. Go to the website, how are the links to the plenary protocols organized?
# They links are spread on six pages. Links to the PDF files with plenary protocols are not only available for the more recent sessions.

# 2. Create a vector with links to all the pages with links to the plenary protocols.
links <- str_c("https://www.landtag.nrw.de/home/dokumente/dokumentensuche/ubersichtsseite-reden--protoko-1/protokolle-18-wahlperiode-2022-2.html?ausschuss=Plenum&page=", 1:6)
links

# 3. Create a folder where you will save the PDF files with the plenary protocols.
dir.create("nrw")

# 4. Read the first page into R, and save it in the created folder.
myhtml <- read_html(links[1])
write_html(myhtml, file = "nrw/1.html")

# 5. Build a for loop for the links to all pages. First define a filename that is different for each link.
# (hint: you can name the files "1.html", "2.html", etc. by extracting the page number from the link via regular expression).
# Read the html from the link, then write it to the filename.
# Make sure to pause R at the end of each iteration.
for (link in links) {
  filename <- str_c("nrw/", str_extract(link, ".$"), ".html")
  myhtml <- read_html(link)
  write_html(myhtml, file = filename)
  Sys.sleep(1)
}

# 5. Read the first html page (from the folder) and extract all links to the PDFs containing the plenary protocols on that page using a css path (hint: ".e-event-timeline__link:nth-child(3) a").
myhtml <- read_html("nrw/1.html")

myelements <- html_elements(myhtml, ".e-event-timeline__link:nth-child(3) a")

links <- html_attr(myelements, "href")

# 6. Create a vector with the (full) file path to each file in your folder. (hint: The path has to include the folder name.)
files <- list.files("nrw", full.names = T)

# 7. Build a for loop for all files in your folder. Extract the links and add them all to a vector.
links <- c()
for (file in files) {
  
  myhtml <- read_html(file)
  
  myelements <- html_elements(myhtml, ".e-event-timeline__link:nth-child(3) a")
  
  links <- c(links, html_attr(myelements, "href")) # Extract the links and add them to the links vector
  
}

links

# 8. The links are only relative URLs, i.e. they are missing the domain. Add the domain using a stringr function.
links <- str_c("https://www.landtag.nrw.de", links)

# Optional: 

# 9. Download the first three PDFs.  (hint: download.file(url, destfile)
for (link in links[1:3]) {
  download.file(link, destfile = str_c("nrw/", basename(link)))
}
