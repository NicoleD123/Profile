# Regularization with caret

# load packages
library(caret)
library(glmnet)
library(qacBase)

# load data
data(mtcars)
cor_plot(mtcars)

# standard regression
set.seed(1234)
model.lm <- train(
  mpg ~., data = mtcars, 
  method = "lm",
  metric = "RMSE"
)

model.lm # we can tell this is not a good model
summary(model.lm)



# Ridge Regression --------------------------------------------------

lambda <- 10^seq(-3, 3, length=100) # try 100 lambda

set.seed(123)
model.ridge <- train(
  mpg ~., data = mtcars, 
  method = "glmnet",
  metric = "RMSE",
  tuneGrid = data.frame(alpha = 0, lambda = lambda)
)

model.ridge
coef(model.ridge$finalModel, model.ridge$bestTune$lambda)


# Lasso Regression --------------------------------------
# Build the model
set.seed(123)
model.lasso <- train(
  mpg ~., data = mtcars, 
  method = "glmnet",
  metric = "RMSE",
  tuneGrid = data.frame(alpha = 1, lambda = lambda) # alpha =1 is the only change
)

model.lasso
coef(model.lasso$finalModel, model.lasso$bestTune$lambda)

# Elastic Net
set.seed(123)
model.elastic <- train(
  mpg ~., data = mtcars, 
  method = "glmnet",
  metric = "RMSE",
  tuneLength = 10
)
# Best tuning parameter
model.elastic$bestTune

model.elastic
coef(model.elastic$finalModel, model.elastic$bestTune$lambda)


# compare models
library(dplyr)
models <- list(reg = model.lm,
               ridge=model.ridge, 
               lasso=model.lasso,
               elastic=model.elastic)
resamples(models) %>% summary(metric="RMSE")
resamples(models) %>% summary(metric="Rsquared")
resamples(models) %>% bwplot(metric="Rsquared")
resamples(models) %>% bwplot(metric="RMSE")

