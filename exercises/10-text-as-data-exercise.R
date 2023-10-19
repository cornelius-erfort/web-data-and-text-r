# 11-text-models-exercise

# 1. Choose a corpus from the quanteda corporas, or use one of your own. Load the texts into R as a vector (or inside a dataframe).
# https://github.com/quanteda/quanteda.corpora

# 2. What is the corpus about?

# 3. Do you have a variable to classify for?

# 4. What could be a hypothesis for your text analysis?

# 5. Tokenize the texts, removing numbers, punctuation, symbols, and separators.

# 6. Build a dfm from the tokens, stem it, remove stopwords, and words occurring in less than 5 documents. 
# Remove words occurring in more than 20 texts.

# 7. Use a textmodel. Use an unsupervised OR supervised model.
# If you don't have a variable to classify for, use an unsupervised textmodel. You can use textmodel_lda(). (If your model takes too long, reduce the number of features by changing the limits for infrequent/frequent words.)
# If you have a variable to classify for, use a supervised model. The fastest and easiest ist textmodel_nb().
# install.packages("quanteda.textmodels")
# library(quanteda.textmodels)

# install.packages("seededlda") # This package needs RTools installed.
# library(seededlda)

# 8. For the unsupervised model: Look at the topics. Do they make sense?
# For the supervised model: How many of your texts were correctly classified?

# 9. Change something in your text preprocessing (e.g. without stemming, different min_docfreq/max_docfreq, without removing stopwords...)
# How do your results change?