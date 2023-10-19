# 04-regex

# Load pacakges
library(tidyverse)
library(rvest)
library(xml2)

# Load the page into R.
html <- read_html("https://www.aph.gov.au/Senators_and_Members/Parliamentarian_Search_Results?q=&mem=1&par=-1&gen=0&ps=96&st=1")

# Use the rvest package and the css path from above to extract all elements, and store them in an object.
elements <- html_elements(html, css = ".title a")

# Create a data.frame with two columns, the link/href from above and the the name/text from above. Store the data.frame in an object.
members <- data.frame(link = html_attr(elements, "href"), name = html_text2(elements))

# Try finding a CSS path for the party of the members on the page.
html_elements(html, css = ".title a")

# How would you add the party of members to your dataset?

# Extract the entire info section for each Member
mp_info <- html_elements(html, ".dl--inline__result")

# Get the text for each element
mp_info <- html_text2(mp_info)

# Extract the Party name and add to the dataframe
members$party <- str_extract(mp_info, "(?<=Party)\\s{3}.*")
table(members$party)

members$party <- str_trim(members$party, side = "both")
table(members$party)

# Add gender
members$gender <- NA
members$gender[str_detect(members$name, "^Mr ")] <- "male"
members$gender[str_detect(members$name, "^(Mrs)|(Ms) ")] <- "female"

table(members$party, members$gender)


# Alternative way: 

# css: ".dl--inline__result", "dd, dt", which


# <html>
#   <body>
#   
#   <div class="row border-bottom padding-top">
#   
#       <div class="medium-push-2 medium-7 large-8  columns">
#           <h4 class="title"><a href="/Senators_and_Members/Parliamentarian?MPID=282237">Mrs Bridget Archer MP</a></h4>
#           <dl class="dl--inline__result text-small">
#   
#             <dt>For</dt>
#             <dd>Bass, Tasmania</dd>
#           
#             <dt>Positions</dt>
#             <dd>Deputy Chair of Standing Committee on Communications and the Arts</dd>
#           
#             <dt>Party</dt>
#             <dd>Liberal Party of Australia</dd>
#   
#             <dt class="snm-hide-links-content">Connect</dt>
#             <dd class="snm-hide-links-content"><!--- ----></i></a></dd>
#   
#           </dl>
#   
#       </div>
#   
#   </body>
# </html>






















