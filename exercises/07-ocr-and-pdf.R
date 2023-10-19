# 07-ocr-and-pdf

install.packages("pdftools")

# We can install packages from other sources (not CRAN) using the remotes packages:
remotes::install_github(c("ropensci/tabulizerjars", "ropensci/tabulizer"), INSTALL_opts = "--no-multiarch")

install.packages("tesseract")
install.packages("magick")


library(pdftools)
library(tidyverse)
library(tabulizer)
library(tesseract)
library(magick)



##### OCR


##################
## Non text images
##################

# Let's look at this image
img_url <- "https://marketplace.canva.com/EAE9CES_S7A/1/0/1131w/canva-blue-and-red-modern-political-election-campaign-womens-rights-flyer-hdzs1rQukZs.jpg"


# Download and read into R
input <- image_read(img_url)

# Let's have a look
plot(input)

# OCR
img_txt <- ocr(input, engine = tesseract("eng"))
cat(img_txt)

# Let's preprocess it
processed <- input %>%
  image_resize("2000x") %>%
  image_convert(type = 'Grayscale') %>%
  image_trim(fuzz = 40) %>%
  image_write(format = 'png', density = '300x300')

plot(processed)


text <- processed %>%
  tesseract::ocr() 


cat(text)

##################
## Scanned text
##################

# Create a folder called manifesto
dir.create("manifesto")

# Make a vector of filenames for all PDF files
filenames <- str_c("manifesto/page_", 1:pdf_info("https://library.fes.de/pdf-files/bibliothek/retro-scans/fa-57721.pdf")$pages, ".png")

# Convert pages 1-5 to images/png
manifesto <- pdf_convert("https://library.fes.de/pdf-files/bibliothek/retro-scans/fa-57721.pdf", filenames = filenames[1:5], dpi = 300, pages = 1:5)

# Run OCR
manifesto_page <- ocr(filenames[5]) 

cat(manifesto_page)

# Create folder called tesseract
dir.create("tesseract")

# Download German support into the folder
tesseract_download("deu", datapath = "tesseract")

# Run OCR again, but with German engine
manifesto_page <- ocr(filenames[5], eng = tesseract("deu", datapath =  "tesseract")) 

cat(manifesto_page)

# Clean text
manifesto_page <- str_remove_all(manifesto_page, "(?<=[:lower:])-\\n(?=[:lower:])")

cat(manifesto_page)

# Read image into R
input <- image_read(filenames[5])

# Let's plot this and have a look
plot(input)


# Let's try to preprocess and run OCR again
processed <-  input %>%
  image_resize("2000x") %>%
  image_convert(type = 'Grayscale') %>%
  image_trim(fuzz = 40) %>%
  image_write(format = 'png', density = '300x300')

plot(processed)

text <- ocr(processed, eng = tesseract("deu", datapath =  "tesseract")) 

cat(text)

text <- str_remove_all(text, "(?<=[:lower:])-\\n(?=[:lower:])")

cat(text)


# Documents from Berlin state parliament
"https://www.parlament-berlin.de/dokumente/open-data"


# Remember the plenary protocols from Week 05?

# Get a list of files in the folder "nrw"
pdfs <- list.files("nrw", full.names = T)



# Only keep those files in the list that end in ".pdf"
pdfs <- str_subset(pdfs, "\\.pdf$")

pdfs


# Use the extract_text() function from the tabulizer package to read the text (pdftools::pdf_text() runs into problems)

# First page
extract_text(pdfs[1], pages = 1)

cat(extract_text(pdfs[1], pages = 1))


# The actual proceedings are on pages 5-19

# Page 5
cat(extract_text(pdfs[1], pages = 5))

# Page 19
cat(extract_text(pdfs[1], pages = 19))

# Pages 5-19
mypdf_text <- extract_text(pdfs[1], pages = 5:19)
mypdf_text



# Alternative way:
# Or extract all text and extract afterwards:
mypdf_text <- extract_text(pdfs[1])

mypdf_text <- str_extract(mypdf_text, "Beginn: \\d{1,2}[\\.:]\\d{2}(\n|.)*Schluss: \\d{1,2}[\\.:]\\d{2}")
cat(mypdf_text)


# Clean the text


# There is some text on the start of each page:
text <- "Landtag   01.06.2022 \nNordrhein-Westfalen 5 Plenarprotokoll 18/1 \n \n"

str_remove(text, "Landtag.*\n.*Plenarprotokoll 18/1.*")

mypdf_text <- str_remove_all(mypdf_text, "Landtag.*\n.*Plenarprotokoll 18/1.*")

cat(mypdf_text)


# Remove page breaks
mypdf_text <- str_replace_all(mypdf_text, "\n\n \n", "\n")

cat(mypdf_text)


# Remove line breaks
mypdf_text <- str_remove_all(mypdf_text, "(?<=[:lower:])-\\n(?=[:lower:])")

cat(mypdf_text)


# Get the sections in the document
str_extract_all(mypdf_text, "((Ich rufe auf)|(Wir kommen zu)|(kommen wir zu)): \n.*", simplify = T)


# Better way:
str_extract_all(mypdf_text, "(?<=: \n)\\d{1,2}.*")


# Get the start of these matches
str_locate_all(mypdf_text, "(?<=: \n)\\d{1,2}.*")





################
# YOUR TURN
################

# 1. Inspect the text from the plenary protocol above, is there anything that needs to be cleaned further? (You don't need to actually clean it.)
cat(mypdf_text)

# 2. Get all the mentions of documents ("Drucksache"). How often is each Drucksache mentioned?
documents <- str_extract_all(mypdf_text, "Drucksache 18/\\d{1,2}")
table(documents)

# 3. Get the information about reactions from the audience, that is written between paragraphs in parantheses.
str_extract_all(mypdf_text, "(?<=\n\\()[^\\(\\)]{6,}?(?=\\))")

# 4. Get the names of speakers.
speakers <- str_extract_all(mypdf_text, "(?<=(^|\n))[^\\(].{1,30}:")[[1]]

speakers[sapply(speakers, function (x) str_count(x, "[:upper:]")) > 1]

# 5. Which other things could be extracted from the text?

# 6. Create a vector where each sentence is one line. Where does your splitting fail, i.e. a sentences is in two elements, or two sentences are in one element?
sentences <- str_split(mypdf_text, "(?<=[^\\d]\\.)( |\n)(?=[^\\d])")
sentences

lapply(sentences, function (x)  str_remove_all(x, "\n"))

# 7. What things could we measure about each sentence? What could they tell us about the behavior of the speakers?
