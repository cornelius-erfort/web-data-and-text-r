# 06-apis-json

# Twitter API and rtweet package
# install.packages("rtweet")

# Load rtweet
library(rtweet)

# Enter authentication token
auth <- rtweet_app()

# Search for tweets
tweets <- search_tweets("election", token = auth)
tweets

tweets <- search_tweets("election AND -filter:retweets AND lang:en", token = auth)
tweets

tweets$text

# Search for users
users <- search_users("cornelius_mer", token = auth)
users

# Get all tweets from a user
mytweets <- get_timeline(user = "1851925615", token = auth)

# Plot tweets over time
library(ggplot)

mytweets %>% 
  ggplot() + geom_freqpoly(aes(created_at))


# Text analysis

# install.packages("quanteda")
# install.packages("quanteda.textplots")

library(quanteda.textplots)

mytweets$full_text %>% # Take the full text of my tweets
  tokens() %>% # Make it a tokens object
  tokens_select(min_nchar = 4) %>% # Remove words with <4 letters
  tokens_remove(c(stopwords("english"), stopwords("german"))) %>% # Remove stopwords 
  dfm() %>% # Make it a DFM object
  textplot_wordcloud() # Create word cloud
