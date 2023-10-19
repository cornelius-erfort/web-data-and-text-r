# 04-regex - exercise

# We want a dataset for the 2022 General Election Results (Canvas, not Summary), the first entry here: 
"https://www.madisoncountyil.gov/departments/county_clerk/elections/past_election_results.php"

# Unfortunately, the data is only provided as a plain text within a html. 
# The results for each polling station are reported in separate rows.
# Some rows provide other information, that we don't want in our dataset.
# A typical row consists of: Polling station ID (e.g. 0202), Name (SALINE 02), Number of registered voters, ballots cast, blank ballots, and turnout.

# Check out the source code.

# 1. Load the required packages.
library(tidyverse)
library(rvest)

# 2. Load the html with the election results.
results <- read_html("https://cms4files.revize.com/madisoncountyilus/document_center/CountyClerk/2022%20Election/2022%20General%20Election%20Official%20Canvass.htm")

# 3. Extract all text in the html.
results <- html_text2(results)

# 4. Split the text into a vector, where each element is a row. (hint: rows are separated by "\r\n", it may be easier for the following tasks to use str_split_1())
results <- str_split_1(results, "\r\n")

# 5. Use a regular expression to select only those elements with election results. (i.e. rows with id, name, ballots cast...) (hint: results[str_detect(string, pattern)])
results <- results[str_detect(results, "^[0-9]")]

# 6. Keep only the first 191 elements. These are all results for one election.
results <- results[1:191]

# 7. Use regular expressions to extract id, and name. (hint: str_extract(string, pattern))
election_ids <- str_extract_all(results, "^\\d{4}", simplify = TRUE)
election_names <- str_extract(results, "(?<= )[[A-Z \\.] ]+\\d{2}")

# 8. Use a regular expression, to extract the election results for the first 191. (hint: str_extract_all(numbers, pattern, simplify = TRUE) gives you a matrix object instad of a list.)
numbers <- str_extract_all(results, "(?<=[^A-Z]{2} )\\d{1,4}(\\.\\d{1,2})?", simplify = TRUE) 

# 9. Make a dataframe using the extracted variables. (If you have two character vectors, and one matrix (not a list!), you can just give them all to the function data.frame() )
results <- data.frame(election_ids, election_names, numbers)

