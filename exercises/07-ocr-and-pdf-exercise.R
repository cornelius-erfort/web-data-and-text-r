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
# Not how we get a list, for each page, we get the matches separately.
