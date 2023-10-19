# 06-apis-json-exercise
# For a research project about the role of the media, you need some data about
# news articles. Fortunately, the NY Times provides several APIs to provide the data
# you need.

# 1. Create a developer account at the NYT: "https://developer.nytimes.com/get-started"

# 2. Sign in, and go to "Apps". (This is in the top right corner.)

# 3. Create a new app, give it a name, and enable the "Article Search API".

# 4. Copy the API Key (don't share it with others ;).

# 5. Read the documentation for the Article Search API.

# 6. Replicate the example call with you API key.

# 7. Send the call to the API, and store it in an object.

# 8. Inspect the results. What types of data did the API give? How are they ordered?

# 9. Instead of "election", search for articles with "humboldt".

# 10. The API only returned data about ten articles. How many results are there in total? 
# Make a call to the API that gets you the data for results 11-20.
# (hint: This is explained in the documentation for the API.)

# 11. Force the results into a dataframe, using the function data.frame().

# 12. Extract only the variable for the publication date.

# 13. Use the function substr() to only get the year from this variable. 
# (hint: ?substr() shows you how to use the function)

# 14. Using the call from step 10, build a for loop for the first 3 pages of the results.
# Force the results into a dataframe, and bind the results for each call together to one
# dataframe. You can use the bind_rows() function from the dplyr package.
# MAKE SURE TO RESPECT THE RATE LIMIT of the API (hint: Sys.sleep()). You find info
# about that in the API documentation.

# Optional: Use this package to replicate the assignment: "https://github.com/mkearney/nytimes". 
# (hint: you can also provide the API key to the function using the argument "apikey = YOUR_API_KEY")
# How do your results differ?

