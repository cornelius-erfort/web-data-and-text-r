# 10-text-models

install.packages("devtools")
# devtools::install_github("quanteda/quanteda.corpora")
# devtools::install_github("quanteda/quanteda.classifiers")

library(quanteda.corpora)
library(quanteda.textmodels)
library(quanteda.textstats)
library(quanteda.textplots)
library(quanteda.classifiers)

library(tidyverse)
library(quanteda)
library(seededlda)
library(ggplot2)


  
###########################
# From the slides:
###########################

# Specify the training data: A text vector AND a label vector
train <- data.frame(
  text = c("A very good proposal", "We support", "We strongly oppose", "We agree", "We oppose the president's plan", "We are pleased with the good work"),
  label = c("pos", "pos", "neg", "pos", "neg", "pos"))

train

# Specify the test data: A text vector AND a label vector
test <- data.frame(
  text = c("We show support", "We condemn the president's actions", "We withdraw our support"),
  label = c("pos", "neg", "neg"), prediction = c("?", "?", "?"))

test

# Create a DFM for the training data
train_dfm <- train$text %>% tokens() %>% dfm()
train_dfm

# Create a DFM for the test data
test_dfm <- test$text %>% tokens() %>% dfm()
test_dfm

# Use the columns from the training data for the test data
# (The model doesn't know other words)
test_dfm <- dfm_match(test_dfm, featnames(train_dfm))
test_dfm

# Fit the model
mymodel <- textmodel_nb(x = train_dfm, y = train$label)

# Use the model to predict the labels for the test data
predict(mymodel, test_dfm)

test$prediction <- predict(mymodel, test_dfm)
test

# Show the feature weights
mymodel$param %>% t()



###########################
# Quanteda textmodels
###########################

# Classification
textmodel_lr()
textmodel_svm()
textmodel_nb()

# Scaling
textmodel_wordscores()
textmodel_wordfish()

###########################
# Quanteda textstats
###########################

textstat_keyness()
textstat_lexdiv()
textstat_readability()


###########################
# Loading text into R
###########################

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


###########################
# Wordcloud
###########################

# Let's do a wordcloud plot
textplot_wordcloud(labour$text %>% dfm)

textplot_wordcloud(labour$text %>% dfm %>% dfm_remove(stopwords()))


###########################
# Preprocess text
###########################

# We can use the tokens() function from quanteda
tokens(labour$text)

# It has arguments to automatically remove punctuation, numbers, etc.
labour_tokens <- tokens(labour$text,
                        remove_punct = TRUE,
                        remove_symbols = TRUE,
                        remove_numbers = TRUE,
                        remove_url = TRUE,
                        remove_separators = TRUE)
labour_tokens

# Document frequency matrix
labour_dfm <- dfm(labour_tokens)
labour_dfm

# Stem
labour_dfm <- dfm_wordstem(labour_dfm)
labour_dfm

# Remove stopwords
labour_dfm <- dfm_remove(labour_dfm, stopwords())
labour_dfm

# Remove infrequent words
labour_dfm <- dfm_trim(labour_dfm, min_docfreq = 5)
labour_dfm

# Wordcloud again
textplot_wordcloud(labour_dfm)

# Word cloud by group
labour_dfm %>% 
  dfm_group(labour$label) %>% 
  textplot_wordcloud(comparison = TRUE)


###########################
# Fit the model
###########################

# textmodel_nb() only requires the DFM and a vector for each text/row with a label
mymodel <- textmodel_nb(labour_dfm, labour$label) # This is really fast

# Now let's use our model to predict this new text
newtext <- 'In this dark hour our thoughts, our solidarity, and our resolve are with the Ukrainian people.'

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

View(labour_nolabel[sample(1:nrow(labour_nolabel), 10), ])


###########################
# Let's visualize this
###########################

# Only the few hand labeled texts
(p <- ggplot(filter(labour, label != "other")) + 
   geom_freqpoly(aes(x = date, color = label)))

# All texts
(p <- ggplot(filter(labour_nolabel, predict != "other")) + 
    geom_freqpoly(aes(x = date, color = predict)))


labour_keyness <- textstat_keyness(labour_nolabel_dfm, which(labour_nolabel$predict == "environment"))

textplot_keyness(labour_keyness)



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


# What can we do to improve the model?

?textmodel_evaluate

textmodel_evaluate(labour_dfm, labour_dfm$label, seed = 18576)

# textmodel_evaluate()
my_eval <- textmodel_evaluate(labour_dfm, labour_dfm$label, seed = 18576,
                              model = "textmodel_nb", fun = c("accuracy", "precision", "recall", "f1_score"),
                              parameters = list(prior = c("uniform", "docfreq", "termfreq")), by_class = F)
my_eval

my_eval_mean <- aggregate(cbind(accuracy, precision, recall, f1_score) ~  prior, my_eval, function (x) round(mean(x, na.rm = T)*100,2))

my_eval_mean


# my_eval <- textmodel_evaluate(labour_dfm, labour_dfm$label, seed = 18576,
                              # model = "textmodel_nb", fun = c("accuracy", "precision", "recall", "f1_score"),
                              # parameters = list(prior = c("termfreq"), distribution = c("multinomial", "Bernoulli"), smooth = c(1, 2, 3)), by_class = T)
# my_eval



###########################
# Supervised (using a Naive Bayes text model)
###########################

# textmodel_nb() only requires the DFM and a vector for each text/row with a label
labour$label
mymodel <- textmodel_nb(labour_dfm, labour$label) # This is really fast

# Now let's use our model to predict this new text
newtext <- 'In this dark hour our thoughts, our solidarity, and our resolve are with the Ukrainian people.'

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

# 7. Make a wordcloud. Make a second wordcloud, grouping the words by a docvar.
dfm_group(mydfm, party) %>% textplot_wordcloud(comparison = TRUE)

# 8. Use textmodel_lda() OR textmodel_nb(), which ever you did NOT use in the assignment for today.
# With textmodel_lda(), extract the number of topics of your choice.
tmod_lda <- textmodel_lda(mydfm, k = 20) # This can take a minute

# With textmodel_nb() classify either by "delivery" or by "party".
tmod_nb1 <- textmodel_nb(mydfm, data_corpus_sotu$delivery)

tmod_nb2 <- textmodel_nb(mydfm, data_corpus_sotu$party)

# 9. textmodel_lda(): Look at the topics. Do they make sense?
terms(tmod_lda)

# textmodel_nb(): Look at the feature weights, order them by size. Do they make sense? (hint: text_model$param %>% t %>% View)
tmod_nb1$param %>% t %>% View
tmod_nb2$param %>% t %>% View

# textmodel_nb(): Use the textmodel_evaluate() function to validate your model.
my_eval <- textmodel_evaluate(mydfm, data_corpus_sotu$delivery, seed = 18576,
                              model = "textmodel_nb", fun = c("accuracy", "precision", "recall", "f1_score"),
                              parameters = list(prior = c("uniform")), by_class = F)
my_eval

my_eval_mean <- aggregate(cbind(accuracy, precision, recall, f1_score) ~  prior, my_eval, function (x) round(mean(x, na.rm = T)*100,2))

my_eval_mean %>% View


