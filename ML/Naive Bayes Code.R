## Classification using Naive Bayes 

##--------------------------------------------------------
## Install necessary packages
##--------------------------------------------------------
# install.packages("tm")            # text prep
# install.packages("SnowballC")     # stemming
# install.packages("naivebayes")    # naive bayes modeling

##--------------------------------------------------------
## Load data
##--------------------------------------------------------

# read the sms data into the sms data frame
library(readr)
df <- read_csv("sms_spam.csv")

##--------------------------------------------------------
## Prepare data
##--------------------------------------------------------
# convert spam/ham to factor.
df$type <- factor(df$type)

# examine the type variable
prop.table(table(df$type))

# build a corpus using the text mining (tm) package
library(tm)
corp <- Corpus(VectorSource(df$text))


# clean up the corpus using tm_map()
corp <- tm_map(corp, tolower)
corp <- tm_map(corp, removeNumbers)
corp <- tm_map(corp, removeWords, stopwords())
corp <- tm_map(corp, removePunctuation)
corp <- tm_map(corp, stripWhitespace)

# stem word variants (e.g. learn, learned, learning)
library(SnowballC)
corp <- tm_map(corp, stemDocument)

# examine the clean corpus
df[1,]
inspect(corp[1])


# corpus_clean <- Corpus(VectorSource(corpus_clean))
dtm <- DocumentTermMatrix(corp)

# creating training and test datasets
library(caret)
set.seed(1234)
index <- createDataPartition(df$type,
                             p=.75,
                             list=FALSE)
train_x <- dtm[index, ]
test_x  <- dtm[-index, ]

train_y <- df$type[index]
test_y <-  df$type[-index]


# check that the proportion of spam is similar
prop.table(table(train_y))
prop.table(table(test_y))


# indicator features for frequent words (at least 5)
freq_words <- findFreqTerms(train_x, 5)
head(freq_words, 20)

train_x <- train_x[, freq_words]
test_x  <-  test_x[, freq_words]


# convert counts to a 0/1 factor
convert_counts <- function(x) {
  x <- ifelse(x > 0, 1, 0)
  x <- factor(x, levels = c(0, 1), labels = c("No", "Yes"))
}

# apply() convert_counts() to columns of train/test data
# this is the slowest part of the code
train_x <- apply(train_x, 2, convert_counts)
test_x  <- apply(test_x,  2, convert_counts)


##--------------------------------------------------------
## Model data using naive bayes method in naivebayes package
##--------------------------------------------------------
library(caret)
set.seed(1234)
model.nb <- train(y=train_y, 
                  x=train_x,
                  method="naive_bayes",
                  metric="Accuracy",
                  tuneGrid=data.frame(laplace=1,
                                      usekernel=FALSE,
                                      adjust=0),
                  trControl=trainControl(method="none"))

##--------------------------------------------------------
## Evaluate performance on test data
##--------------------------------------------------------
test_pred <- predict(model.nb$finalModel, test_x)
confusionMatrix(test_pred, test_y, positive="spam")


##--------------------------------------------------------
## Going further
##--------------------------------------------------------
# note: for conditional probabilities use
test_prob <- predict(model.nb$finalModel, 
                         test_x, 
                         type="prob")
round(head(test_prob), 6)

# show highest to lowest scoring messages
score <- test_prob[, 2]  # probability of spam
ord <- order(-score)

temp <- cbind(df[-index,], score)[ord, ]
