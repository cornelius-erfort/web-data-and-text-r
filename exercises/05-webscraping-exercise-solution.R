# 05-webscraping-exercise

# For a project on responsiveness of elected politicians, you were asked to 
# create a dataset of the the responses of Members of the Berlin State 
# Parliament to citizen questions on abgeordnetenwatch.de.
# You can find the questions here: "https://www.abgeordnetenwatch.de/berlin/fragen-antworten"

# 1. Go to the website, how are the links to the full questions/responses organized?
# They are organized in 67 pages. (Page 1 is referred to as page=0 and page 67 as page=66.)

# 2. Create a vector with links to all the pages with links to the questions/responses.
links <- str_c("https://www.abgeordnetenwatch.de/berlin/fragen-antworten?page=", 0:66)
links

# 3. Create a folder where you will save the HTML files with the full questions/responses.
dir.create("berlin")

# 4. Read the first page into R, and save it in the created folder.
myhtml <- read_html(links[1])
write_html(myhtml, file = "berlin/0.html")

# 5. Build a for loop for the links to the first three pages. First define a filename that is different for each link.
# (hint: you can name the files "0.html", "1.html", etc. by extracting the page number from the link via regular expression).
# Read the html from the link, then write it to the filename.
# Make sure to pause R at the end of each iteration.
library(rvest)
library(xml2)

for (link in links[1:3]) {  
  
  filename <- str_c("berlin/", str_extract(link, ".$"), ".html")
  
  if(file.exists(filename)) next
  
  myhtml <- read_html(link)
  
  write_html(myhtml, file = filename)
  
  Sys.sleep(1)

}

# 6. Read the first html page (from the folder) and extract all links to the page for the full question/response on that page using a css path (hint: ".tile__question__teaser a").
myhtml <- read_html("berlin/0.html")

myelements <- html_elements(myhtml, ".tile__question__teaser a")

myelements

links <- html_attr(myelements, "href")

links

# 7. Create a vector with the (full) file path to each file in your folder. (hint: The path has to include the folder name.)
files <- list.files("berlin", full.names = T)

files

# 8. Build a for loop for all files in your folder. Extract the links and add them all to a vector.
links <- c()
for (file in files) {
  
  myhtml <- read_html(file)
  
  myelements <- html_elements(myhtml, ".tile__question__teaser a")
  
  links <- c(links, html_attr(myelements, "href")) # Extract the links and add them to the links vector
  
}

links

# 9. The links are only relative URLs, i.e. they are missing the domain. Add the domain using a stringr function.
links <- str_c("https://www.abgeordnetenwatch.de/", links)


# 10. Download the first three HTMLs with the full questions/responses. (hint: download.file(url, destfile)
for (link in links[1:3]) {
  download.file(link, destfile = str_c("berlin/", basename(link), ".html"))
}
