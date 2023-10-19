# 03-html - exercise

# 1. Go to the website of the Parliament of Australia.

# 2. Go to the list of all current members.

# 3. Set the results per page to the maximum.

# 4. Look at the source code.

# 5. Find a css path for the names (and links) to all members on the first page (use the Selector Gadget, if necessary).

# 6. Load the page into R.
html <- read_html("https://www.aph.gov.au/Senators_and_Members/Parliamentarian_Search_Results?q=&mem=1&par=-1&gen=0&ps=96&st=1")

# 7. Use the rvest package and the css path from above to extract all elements, and store them in an object.
elements <- html_elements(html, css = ".title a")

# 8. Get the href attribute for all elements.
html_attr(elements, "href")

# 9. Get the text for all elements.
html_text2(elements)

# 10. Create a data.frame with two columns, the link/href from above and the the name/text from above. Store the data.frame in an object.
members <- data.frame(link = html_attr(elements, "href"), name = html_text2(elements))

# 11. Try finding a CSS path for the party of the members on the page.
# Sorry for the confusion. There is no reasonable css path.

# 12. How would you add the party of members to your dataset?
# Using regular expressions. 