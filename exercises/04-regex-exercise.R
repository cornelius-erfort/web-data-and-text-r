# 04-regex - exercise

# For a research project, we need the election results from Madison County, Illinois.
# We want a dataset for the 2022 Generel Election Results (Canvas, not Summary), the first entry here:  "https://www.madisoncountyil.gov/departments/county_clerk/elections/past_election_results.php"
# Check out the source code.

# Unfortunately, the data is only provided as a plain text within a html. 
# The results for each polling station are reported in separate rows.
# Some rows provide other information, that we don't want in our dataset.
# A typical row consists of: Polling station ID (e.g. 0202), Name (SALINE 02), Number of registered voters, ballots cast, blank ballots, and turnout.


# 1. Load the required packages.

# 2. Load the html with the election results.

# 3. Extract all text in the html.

# 4. Split the text into a vector, where each element is a row. (hint: rows are separated by "\r\n", it may be easier for the following tasks to use str_split_1())

# 5. Use a regular expression to select only those elements with election results. (i.e. rows with id, name, ballots cast...) (hint: results[str_detect(string, pattern)])

# 6. Keep only the first 191 elements. These are all results for one election.

# 7. Use regular expressions to extract id, and name. (hint: str_extract(string, pattern))

# 8. Use a regular expression, to extract the election results for the first 191. (hint: str_extract_all(numbers, pattern, simplify = TRUE) gives you a matrix object instad of a list.)

# 9. Make a dataframe using the extracted variables. (If you have two character vectors, and one matrix (not a list!), you can just give them all to the function data.frame() )
