# 07-ocr-and-pdf-exercise

# Up until 2021, there was no register for lobby organizations at the federal level in Germany.
# Instead, there was a "public list": "https://www.bundestag.de/parlament/lobbyliste"
# One main criticism: being on the list was voluntary.

# Also, unlike the new register, this list was only published as a PDF.
# You can find the list from 2021 here: 
pdfurl <- "https://www.bundestag.de/resource/blob/189456/c9f95e162866fe23c3f3a3b7f2aaf739/lobbylisteamtlich-data.pdf"

download.file(pdfurl, "lobbylist.pdf")

library(tabulizer)

# Read in page 3
pdftext <- extract_text("lobbylist.pdf", pages = 3)

cat(pdftext)

# This pattern seems to always precede the line of text with the name:
str_extract_all(pdftext, "(?<=N am e u n d S i t z , 1 . A d r e s s e\n).*")

# Now the same for pages 3-5
pdftext <- extract_text("lobbylist.pdf", pages = 3:5)

str_extract_all(pdftext, "(?<=N am e u n d S i t z , 1 . A d r e s s e\n).*")
# Not how we get a list, for each page, we get the matches separately.


# Does it also work for the full document? (# Yes, but it takes a bit longer)
pdftext <- extract_text("lobbylist.pdf")
str_extract_all(pdftext, "(?<=N am e u n d S i t z , 1 . A d r e s s e\n).*")
# Note how we get a list, for each page, we get the matches separately.


##################################

# Further ideas:

#########################
# 1
#########################

# Let's say, you also extracted the amount of members (Mitgliederzahl) for pages 3:5, but for the 11th organization, this info is on page 5!
pdftext <- extract_text("lobbylist.pdf", pages = 3:5)

org_names <- str_extract_all(pdftext, "(?<=N am e u n d S i t z , 1 . A d r e s s e\n).*")
org_names <- unlist(org_names)
length(org_names) # 11 elements

org_members <- str_extract_all(pdftext,"(?<=M i t g l i e d e r z a h l\n).*(?=\n)" )
org_members <- unlist(org_members)
length(org_members) # 10 elements

# Then using data.frame() gives an error, because it expects vectors of equal length.
data.frame(org_names, org_members)

# Now you have two options (assuming you don't want to manually add that number):
# (a) Truncate the longer vectors to the shortest. In this case, remove the 11th element from org_names.
org_names[-length(org_names)]

# (b) Pad the shorter vectors with NAs. In this case, add one NA to org_members.
c(org_members, NA)

#########################
# 2
#########################

# We talked about splitting the text into different elements. 

# For example, by rows:

my_rows <- str_split(plane_text, "\n")[[1]] 
# I'm using [[1]] because str_split() creates a list. 
# If plane_text would have more than one element, each element of the list 
# would contain the rows from the corresponding element of plane_text.
print(my_rows)

# This could help us, find the information we want. Look at element 19 "M i t g l i e d e r z a h l" and 20. 
# Element 20 has the information we need. But how do we find all elements with "M i t g l i e d e r z a h l",
# or more importantly, the one following.

my_rows == "M i t g l i e d e r z a h l" # Gives us a vector with the same length as my_rows
# It is FALSE, unless the corresponding element in my_rows is exactly "M i t g l i e d e r z a h l" (e.g. element 19)

# Now the which() function takes vectors with TRUE/FALSE (logicals)
# and gives back the numbers of the elements that are TRUE:
which(my_rows == "M i t g l i e d e r z a h l")
# These are the elements equalling "M i t g l i e d e r z a h l".

# To always get the following one, we add 1:
which(my_rows == "M i t g l i e d e r z a h l") + 1

# Let's store these numbers
extract_rows <- which(my_rows == "M i t g l i e d e r z a h l") + 1

# And use them to get the elements from my_rows:
my_rows[extract_rows]

# And convert them to a numeric vector:
as.numeric(my_rows[extract_rows]) #  Notice how the hyphen was replaced by an NA

# Now we can also do more things with the vector:
org_members <- as.numeric(my_rows[extract_rows])
mean(org_members, na.rm = T) # Here, we have to use na.rm = T, because mean() doesn't like that there is an NA in the vector
sum(org_members, na.rm = T)
median(org_members, na.rm = T)
var(org_members, na.rm = T)

####################
# Now another way:

# First, let's load pages 3-6 now:
pdftext <- extract_text("lobbylist.pdf", pages = 3:6)

# Splitting by entries/organizations:
entries <- str_split(pdftext, "(?=[^^][:digit:]\nN am e u n d S i t z , 1 . A d r e s s e\n)") # [^^] means that my pattern cannot be at the beginning of my string.
entries # Note how str_split() gives us a list with one element per page. These elements contain vectors with the entries.
# This is problematic, because there is an entry that spans from page 5 to page 6.

# So let's combine all elements of pdftext, and make one large element.
pdftext <- str_c(pdftext, collapse = "\n")

# And split again:
entries <- str_split(pdftext, "(?=[^^][:digit:]\nN am e u n d S i t z , 1 . A d r e s s e\n)")

# Unlist makes a normal vector out of the list.
entries <- unlist(entries)
?unlist

print(entries)

# This can help us to keep apart the values we are extracting, for example when there is more than one webpage per organization.

str_extract_all(entries[1], "(?<=Internet: ).*")

webpages <- list() # Create an empty list
for (entry in entries) { # For loop going through all entries
  webpages <- append(webpages, str_extract_all(entry, "(?<=Internet: ).*")) # Appending/adding to the list, what we extract in each entry
}
webpages # Note that there is more than one URL in some list elements