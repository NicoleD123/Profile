# Attrition Dataset
# Logistic Regression

# import data
library(readr)
df <- read_csv("Employee-Attrition.csv")
df <- as.data.frame(df)

# review data
library(qacBase)
contents(df)
df_plot(df)
histograms(df)
barcharts(df)

# data management
df$Attrition <- factor(df$Attrition)
contrasts(df$Attrition)

row.names(df) <- df$EmployeeNumber

df$EmployeeCount <- NULL
df$Over18 <- NULL
df$StandardHours <- NULL
df$EmployeeNumber <- NULL




# create training and test data sets
library(caret)
set.seed(1234)
index <- createDataPartition(df$Attrition, 
                             p=0.8, list=FALSE)
train <- df[index,]
test <- df[-index,]


# fit logistic regression model to train data set
# use AUC for criterion
model.lr <- train(Attrition ~ ., 
                      data = train,
                      trControl = trainControl(method="none", classProbs=TRUE),
                      method = "glm",
                      family = "binomial",
                      metric = "ROC")

summary(model.lr)

round(exp(coef(model.lr$finalModel)), 3)

# variable importance
varImp(model.lr)
plot(varImp(model.lr))

# examine performance in train data (assumes cutoff of .5)
train$pred <- as.factor(predict(model.lr, train))
confusionMatrix(train$pred, 
                train$Attrition, 
                positive="Yes")


# ROC curve 
train$prob <- predict(model.lr, train, type = "prob")[[2]]

library(plotROC)
ggplot(train, aes(d=Attrition, m=prob)) +
  geom_roc(labelround=2, n.cuts=15, labelsize=3) + 
  style_roc(major.breaks=seq(0, 1, .1),
            minor.breaks=seq(0, 1, .05),
            theme=theme_grey) +
  labs(title="ROC Plot")

library(pROC)
auc(train$Attrition, train$prob)

# Try a different cutoff value
# chosen from ROC plot to increase sensitivity
train$pred.13 <- factor(train$prob > 0.13,
                       levels = c(FALSE, TRUE),
                       labels=c("No", "Yes"))
confusionMatrix(train$pred.13, 
                train$Attrition, 
                positive="Yes")

# evaluate on test data
test$prob <- predict(model.lr, test, type = "prob")[[2]]
test$pred.13 <- factor(test$prob > 0.13,
                        levels = c(FALSE, TRUE),
                        labels=c("No", "Yes"))
confusionMatrix(test$pred.13, 
                test$Attrition, 
                positive="Yes")

# top 10 employees predicted to leave
test <- test[order(-test$prob),]
head(test["prob"], 10)


# examine marginal impact of Overtime on probabilities
# holding the other variables constant
# install.packages("ggeffects")
library(ggeffects)
plotdata <- ggpredict(model.lr$finalModel, 
                      terms="OverTimeYes")
ggplot(plotdata, aes(as.factor(x), predicted)) + 
  geom_bar(stat="identity") +
  labs(x="OverTimeYes", 
       y="Prob(Attrition)")


# examine marginal impact of Number of companies worked on 
# probabilities holding the other variables constant
plotdata <- ggpredict(model.lr$finalModel, 
                      terms="NumCompaniesWorked")
ggplot(plotdata, aes(x, predicted)) + geom_point() +
  geom_line() + 
  labs(x="Number of Companies Worked", 
       y="Prob(Attrition)")





