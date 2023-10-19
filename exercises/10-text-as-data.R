# 10-text-as-data

install.packages("devtools")
# devtools::install_github("quanteda/quanteda.corpora")
library(quanteda.corpora)


library(tidyverse)
library(quanteda)
library(quanteda.textmodels)
library(seededlda)
library(ggplot2)
library(quanteda.corpora)


  
###########################
# From the slides:
###########################

# Simple dictionaries
text1 <- "Labour pledges to boost employment and grow the economy"
text2 <- "They protest the “hostile environment” being created for LGBT+ people"
texts <- c(text1, text2) # A "corpus"

str_detect(texts, "tax|taxes|interest|economy")
str_detect(texts, "climate|emissions|environment")

# Document-frequency matrix
dfm(texts)
mydfm <- dfm(texts)

# List of stopwords
stopwords()

# Stopwords in other languages
stopwords("de")

# Remove stopwords using dfm_remove()
mydfm <- dfm_remove(mydfm, stopwords())
mydfm

# Stem words
mydfm <- dfm_wordstem(mydfm)
mydfm

###########################
# Loading text into R
###########################

# To work with text, we need a vector of texts (and additional variables).
# read.csv(), readLines(), openxlsx::read.xlsx(), fromJSON()
# If we have text in several files, we can load them via a for loop.

# Let's read in a dataframe that was saved using saveRDS()
labour <- readRDS("labour.RDS")
View(labour) 
# A dataframe with two columns:
# The text of press releases from Labour
# A vector indicating whether the press release is about the environment
# Another topic, or NA.

# Let's store the press releases without a topic label in a different object
labour_nolabel <- filter(labour, is.na(label))

# And only work with the labeled texts
labour <- filter(labour, !is.na(label))
table(labour$label, useNA = "always")

# Let's explore the data a little
table(labour$label, useNA = "always")

str_length(labour$text) %>% hist

str_count(labour$text, "\\w") %>% hist

str_count(labour$text[labour$label == "environment"], "\\w") %>% hist
str_count(labour$text[labour$label == "economy"], "\\w") %>% hist
str_count(labour$text[labour$label == "other"], "\\w") %>% hist

(p <- ggplot(labour) + geom_freqpoly(aes(x = date, color = label)))

(p <- ggplot(filter(labour, label != "other")) + geom_freqpoly(aes(x = date, color = label)))

(p <- p + geom_freqpoly(data = labour_nolabel, aes(x = date)))

# Does our dictionary work?
labour$dictionary_econ <- str_detect(labour$text, "tax|taxes|interest|economy")

table(labour$dictionary_econ)
table(labour$dictionary_econ, labour$label)

labour$dictionary_env <- str_detect(labour$text, "climate|emissions|environment")

table(labour$dictionary_env)
table(labour$dictionary_env, labour$label)

# Why did our dictionary assign them to the environment?
filter(labour, dictionary_env & label == "economy")$text[2] %>% 
   str_view("climate|emissions|environment")
 
filter(labour, dictionary_env & label == "economy")$text[2] %>% 
   str_view("tax|taxes|interest|economy")


###########################
# Quanteda
###########################

# We can use the tokens() function from quanteda
tokens(labour$text)
?tokens

# It has arguments to automatically remove punctuation, numbers, etc.
# 
labour_tokens <- tokens(labour$text,
                        remove_punct = TRUE,
                        remove_symbols = TRUE,
                        remove_numbers = TRUE,
                        remove_url = TRUE,
                        remove_separators = TRUE)
labour_tokens

# Now we can make a DFM using dfm()
# Note that it converts all words to lowercase
labour_dfm <- dfm(labour_tokens)
labour_dfm

dim(labour_dfm)

View(as.matrix(labour_dfm[1:100, 1:100]))

# Stem
labour_dfm <- dfm_wordstem(labour_dfm)
labour_dfm

# Remove stopwords
labour_dfm <- dfm_remove(labour_dfm, stopwords())
labour_dfm

# Remove infrequent words
labour_dfm <- dfm_trim(labour_dfm, min_docfreq = 5)
labour_dfm


###########################
# Unsupervised LDA model (using seededlda)
###########################

# We just enter the DFM and the number of topics we want
tmod_lda <- textmodel_lda(labour_dfm, k = 15) # This can take a minute

# saveRDS(tmod_lda, "tmod_lda.RDS")
tmod_lda <- readRDS("tmod_lda.RDS")

terms(tmod_lda) # Which topic is environment/economy?



###########################
# Your turn
###########################

# 1. Load the data_corpus_sotu from the package quanteda.corpora.
data_corpus_sotu

# 2. What is the corpus about?
# US State of the Union addresses from 1790 to present	

# 3. What other information do we have about each document? You can use the docvars() function.
docvars(data_corpus_sotu)

# 4. What could be hypotheses for the texts?

# 5. Tokenize the texts, removing numbers, punctuation, symbols, and separators.
mytokens <- tokens(data_corpus_sotu,
                   remove_punct = TRUE,
                   remove_symbols = TRUE,
                   remove_numbers = TRUE,
                   remove_separators = TRUE)

# 6. Build a dfm from the tokens, stem it, remove stopwords, and words occurring in less than 5 documents. 
# Remove words occurring in more than 20 texts.
mydfm <- dfm(mytokens) %>% 
  dfm_wordstem() %>% 
  dfm_remove(stopwords()) %>% 
  dfm_trim(min_docfreq = 5) %>% 
  dfm_trim(max_docfreq = 20)
mydfm

# 7. Use textmodel_lda() to extract the number of topics of your choice.
tmod_lda <- textmodel_lda(mydfm, k = 20) # This can take a minute

# 8. Look at the topics. Do they make sense?
terms(tmod_lda)



# If we still have time, other wise next week:

###########################
# Supervised (using a Naive Bayes text model)
###########################

# textmodel_nb() only requires the DFM and a vector for each text/row with a label
labour$label
mymodel <- textmodel_nb(labour_dfm, labour$label) # This is really fast

# Now let's use our model to predict this new text
newtext <- 'In this dark hour our thoughts, our solidarity, and our resolve are with the Ukrainian people. Invading troops march through their streets.'

# We need to do the same preprocessing as with the training DFM above
newtext_dfm <- newtext %>% 
  tokens() %>%  # Tokenize (removing punctuation, stopwords is not necessary here)
  dfm() %>% # Make a DFM
  dfm_wordstem() %>% # Stem words
  dfm_match(featnames(labour_dfm)) # Only allow features that are also in labour_dfm (the model doesn't know other words!)

featnames(labour_dfm)

# Predict the new text using mymodel
predict(mymodel, newtext_dfm)

newtext <- 'This text is about the environment.'

# The same with another text:
newtext_dfm <- newtext %>% 
  tokens() %>%  
  dfm %>% 
  dfm_wordstem %>%  
  dfm_match(featnames(labour_dfm))

# Predict
predict(mymodel, newtext_dfm)

# Now let's get back to the texts where we didn't have a label:
labour_nolabel_dfm <- labour_nolabel$text %>% tokens() %>%  
  dfm %>% 
  dfm_wordstem %>%  
  dfm_match(featnames(labour_dfm))

labour_nolabel$predict <- predict(mymodel, labour_nolabel_dfm)

table(labour_nolabel$predict)


###########################
# Let's visualize this
###########################

# Only the few hand labeled texts
(p <- ggplot(filter(labour, label != "other")) + 
    geom_freqpoly(aes(x = date, color = label)))

# All texts
(p <- ggplot(filter(labour_nolabel, predict != "other")) + 
    geom_freqpoly(aes(x = date, color = predict)))

###########################
# Validate
###########################

table(labour$label, predict(mymodel, labour_dfm)) # This is not proper validation, why?





###########################
# Train and test split
###########################

# Let's take 100 texts as a test sample
nrow(labour_dfm)
mysample <- sample(1:nrow(labour_dfm), 300)
labour_dfm$label <- labour$label # Add docvar
labour_dfm_test <- labour_dfm[mysample, ]
  
# And the rest as training data
labour_dfm_train <- labour_dfm[!(1:nrow(labour_dfm) %in% mysample), ]

mymodel <- textmodel_nb(labour_dfm_train, labour_dfm_train$label) 

table(predict(mymodel, labour_dfm_test), labour_dfm_test$label)


labour_dfm_train_tf <- dfm_tfidf(labour_dfm_train)
labour_dfm_test_tf <- dfm_tfidf(labour_dfm_test)

mymodel <- textmodel_nb(labour_dfm_train_tf, labour_dfm_train$label) 
table(predict(mymodel, labour_dfm_test_tf), labour_dfm_test$label)

# What can we do to improve the model?
