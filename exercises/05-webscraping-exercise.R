# 05-webscraping-exercise

# For a project on responsiveness of elected politicians, you were asked to 
# create a dataset of the the responses of Members of the Berlin State 
# Parliament to citizen questions on abgeordnetenwatch.de.
# You can find the questions here: "https://www.abgeordnetenwatch.de/berlin/fragen-antworten"

# 1. Go to the website, how are the links to the full questions/responses organized?

# 2. Create a vector with links to all the pages with links to the questions/responses.

# 3. Create a folder where you will save the HTML files with the full questions/responses.

# 4. Read the first page into R, and save it in the created folder.

# 5. Build a for loop for the links to the first three pages. First define a filename that is different for each link.
# (hint: you can name the files "0.html", "1.html", etc. by extracting the page number from the link via regular expression).
# Read the html from the link, then write it to the filename.
# Make sure to pause R at the end of each iteration.

# 6. Read the first html page (from the folder) and extract all links to the page for the full question/response on that page using a css path (hint: ".tile__question__teaser a").

# 7. Create a vector with the (full) file path to each file in your folder. (hint: The path has to include the folder name.)

# 8. Build a for loop for all files in your folder. Extract the links and add them all to a vector.

# 9. The links are only relative URLs, i.e. they are missing the domain. Add the domain using a stringr function.

# 10. Download the first three HTMLs with the full questions/responses. (hint: download.file(url, destfile)