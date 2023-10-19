# 04-regex

# Load pacakges
library(tidyverse)
library(rvest)
library(xml2)

## Basic regex patterns
  
# Normal characters only match exactly

fruit # fruit is an object from the package "stringr"

# str_view() shows how the string matches the pattern
str_view(fruit, pattern = "berry", match = NA)

str_view("automated web data collection", pattern = "data")

# str_detect() checks for each element of the vector whether the pattern is there
str_detect(fruit, pattern = "berry")

is_berry <- str_detect(fruit, pattern = "berry")

table(is_berry)


## Punctuation
  
# ., +, *, [, ], and ? have special meanings. 
# E.g. . matches any character

words[1:10] # words is also part of stringr
head(words, 10)
tail(words, 10)

str_view(words[1:10], ".c..", match = NA)

parties <- c("Party: CDU", "Party: SPD", "Party: CSU", "Party: ABC", "Party: SPD", "Party: CCC")

parties

str_view(parties, "Party: C..", match = NA)


## Quantifiers
  
# Quantifiers control how many times a pattern can match:
# ? makes a pattern optional (i.e. it matches 0 or 1 times)
# + lets a pattern repeat (i.e. it matches at least once)
# * lets a pattern be optional or repeat (i.e. it matches any number of times, including 0).


letters <- c("aaaab", "bbbbccd", "bbaa")

str_extract(letters, pattern = "a+")

str_extract(letters, pattern = "a?")

str_extract(letters, pattern = "a*")

str_extract(letters, ".*")



## Character classes

# ... are defined by [] and let you match a set of characters
# [abc], or [a-z], or [A-Z]
# Use ^ to exclude these characters: [^abc] 

str_view(c("abcdef123", "abc23", "cdefghik345abc"), "[abc]", match = NA)

str_view(c("abcdef123", "abc23", "cdefghik345abc"), "[^0-9]", match = NA)



## Anchors

# Help you match only patterns at the start or end of a string
# ^ for the start, $ for the end

str_view(c("mr charlie smith", "ms charlie palmr"), "mr", match = NA)

str_view(c("mr charlie smith", "ms charlie palmr"), "^mr", match = NA)

parties <- c("party: abc", "party: abc", "the party was good", "party: abc", "a large political party")

parties

str_view(parties, "^party.*", match = NA)

## More quantifiers

 # We can specify, how often something has to appear using {}
 # {n} matches exactly n times.
 # {n,} matches at least n times.
 # {n,m} matches between n and m times.

str_view(c("aaaa", "aaaaaaa", "aaaaaaaa"), "a{5}", match = NA)

str_view(parties, "^party.{3}")

## Lookaheads/lookbehinds

# We can specify a pattern, by saying what pattern comes before/after
# Positive lookahead: (=>pattern)
# Positive lookbehind: (?<=pattern)

str_view(parties, "(?<=party: ).{3}", match = NA)

mytexts <- c("I don't want this text." ,"I only want this text. Contact: Twitter @something")

mytexts

str_view(mytexts, ".*(?=Contact:)", match = NA)

myurls <- c("This is not a URL.", "URL: www.ineedthisurl.com")

myurls

str_view(myurls, "(?<=URL: ).*", match = NA)


# Other helpful functions

str_remove("This is not a sentence.", pattern = " not")

str_extract_all("word word word", pattern = "word", simplify = TRUE)

str_extract("word word word", pattern = "word")

str_replace("word word word", pattern = "word$", "apple")

str_to_lower("This Could Be a Headline")

paragraph <- str_c(sentences[1:3], collapse = " ")
paragraph

str_split(paragraph, pattern = "\\. ")

words[1:10]
str_length(words[1:10])


##############
# YOUR TURN
##############

# Find a regular expression that matches: 

# 1. only the first two elements (you can use str_detect() or str_extract() or str_view() to check.)
c("abc", "cde", "def", "efg")

str_view(c("abc", "cde", "def", "efg"), "c", match = NA)

# 2. all fruits that end in fruit
fruit

str_view(fruit, "fruit")

# 3. all fruits that end in e
fruit

str_view(fruit, "e$")

# 4. all fruits and the entire string
fruit

str_view(fruit, ".*")

# 5. for each sentence, the word following "with"
sentences

str_view(sentences, "(?<=with )[a-z]*")

# 6. the first letter of each word
words

str_view(words, "^.")

table(str_extract(words, "^."))
