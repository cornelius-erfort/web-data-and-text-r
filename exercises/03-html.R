# 03-html

# Install packages
install.packages("rvest")
install.packages("xml2")

# Load packages
library(rvest)
library(xml2)
library(tidyverse)


# Download Wikipedia page
myhtml <- read_html("https://en.wikipedia.org/wiki/List_of_political_scientists")

View(myhtml)

# Select the relevant elements (Get the CSS path using Selector Gadget)
myelements <- html_elements(myhtml, css = "h2+ ul li > a:nth-child(1)")

myelements

# Get the href attribute for each element
html_attr(myelements, name = "href")

# Get the text for each element
html_text2(myelements)

# Make a dataframe
scientists <- data.frame(link = html_attr(myelements, name = "href"),
                         name = html_text2(myelements))

View(scientists)


##############
# YOUR TURN
##############

# Go to the Wikipedia page "List of protests in the 21st century"

# Read the page/html into R
html <- read_html("https://en.wikipedia.org/wiki/List_of_protests_in_the_21st_century")

# Use Selector Gadget to find a CSS path for all protests.

# Get a list of these elements using the CSS path
revolutions <- html_elements(html, css = ".tright+ ul a , .div-col a , h3+ ul a")
revolutions

# Get the link (href attribute) for each element
html_attr(revolutions, "href")

# Get the text for each element
html_text(revolutions)

# Make a dataframe with these vectors: link and name
protests <- data.frame(link = html_attr(revolutions, "href"),
                       name = html_text(revolutions))

View(protests)


