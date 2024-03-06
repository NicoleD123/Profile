## stepwise logistic regression with caret

library(caret)
library(mlbench)
data("PimaIndiansDiabetes")
df <- PimaIndiansDiabetes

# train and test datasets
set.seed(1234)
index <- createDataPartition(df$diabetes, p=.8,
                             list=FALSE)
train <- df[index,]
test <- df[-index, ]
table(train$diabetes)

# backward selection with AIC
train.control <- trainControl(method="cv", number=10)
set.seed(1234)
model.stepAIC <- train(diabetes ~ ., data=train,
                       method="glmStepAIC",
                       trControl = trainControl(method="none"),
                       metric="Accuracy")
model.stepAIC
#step 1 all the variables
#step 2 drop xx and increase AIC

# summary for final model
summary(model.stepAIC$finalModel)

# coefficients for final model
coef(model.stepAIC$finalModel)
exp(coef(model.stepAIC$finalModel))

# variable importance
plot(varImp(model.stepAIC))

# examine performance in train data (assumes cutoff of .5)
train$pred <- as.factor(predict(model.stepAIC, train))
confusionMatrix(train$pred, 
                train$diabetes, 
                positive="pos")


# ROC curve 
train$prob <- predict(model.stepAIC, train, type = "prob")[[2]] #we just need the second col

library(plotROC)
ggplot(train, aes(d=diabetes, m=prob)) +
  geom_roc(labelround=2, n.cuts=15, labelsize=3) + 
  style_roc(major.breaks=seq(0, 1, .1),
            minor.breaks=seq(0, 1, .05),
            theme=theme_grey) +
  labs(title="ROC Plot")

#area under the curve
library(pROC)
auc(train$diabetes, train$prob)

#try a cut off of 0.33
# Try a different cutoff value
# chosen from ROC plot to increase sensitivity
train$pred.3 <- factor(train$prob > 0.33,
                       levels = c(FALSE, TRUE),
                       labels=c("neg", "pos"))
confusionMatrix(train$pred.3, 
                train$diabetes, 
                positive="pos")

# evaluate on test data
test$prob <- predict(model.stepAIC, test, type = "prob")[[2]]
test$pred.3 <- factor(test$prob > 0.3,
                      levels = c(FALSE, TRUE),
                      labels=c("neg", "pos"))
confusionMatrix(test$pred.3, 
                test$diabetes, 
                positive="pos")

