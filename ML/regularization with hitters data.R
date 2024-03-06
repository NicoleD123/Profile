# Regularization with caret

# load data
library(readr)
df <- read_csv("hitters.csv")
df <- na.omit(df)


# load packages
library(caret)
library(glmnet)
library(qacBase)

# review data
contents(df)
cor_plot(df)

# standard regression
model.lm <- train(
  Salary ~., data = df, 
  method = "lm",
  metric = "RMSE"
)

model.lm
summary(model.lm)



# Ridge Regression --------------------------------------------------

lambda <- 10^seq(-3, 3, length=100)

set.seed(123)
model.ridge <- train(
  Salary ~., data = df, 
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
  Salary ~., data = df, 
  method = "glmnet",
  metric = "RMSE",
  tuneGrid = data.frame(alpha = 1, lambda = lambda)
)

model.lasso
coef(model.lasso$finalModel, model.lasso$bestTune$lambda)

# Elastic Net
set.seed(123)
model.elastic <- train(
  Salary ~., data = df, 
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
