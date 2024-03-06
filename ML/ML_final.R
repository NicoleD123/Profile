ped <- read.csv("/Volumes/GoogleDrive/Shared drives/QAC machine learning/ped_crashes.csv")

## EDA
library(qacBase)
contents(ped)
df_plot(ped)
cor_plot(ped)

## exclude observations with missing values
ped <- subset(ped, Weather.Conditions..2016..!="Uncoded & errors")
# weather uncoded before 2016
ped <- subset(ped, Person.Gender != "Uncoded & errors")
ped <- subset(ped, Person.Age != "DOB invalid")
ped <- na.omit(ped)

## drop and rename variables, remove uncoded values, mutate variable types
library(dplyr)
ped <- ped %>% 
  select(-c("Crash.Day","City.or.Township","Party.Type")) %>% #party type only one value
  rename(year = Crash.Year,
         month = Crash.Month,
         time = Time.of.Day,
         weekday = Day.of.Week,
         intersection = Crash..Intersection,
         hit_run = Crash..Hit.and.Run,
         light = Lighting.Conditions,
         weather = Weather.Conditions..2016..,
         speedLimit = Speed.Limit.at.Crash.Site,
         worstInjury = Worst.Injury.in.Crash,
         age = Person.Age,
         gender = Person.Gender) %>% 
  filter(weather != "Uncoded & errors",
         gender != "Uncoded & errors",
         age != "DOB invalid",
         age != "Less than 1 year old",
         light != "Unknown",
         weather != "Unknown",
         speedLimit != "Uncoded & errors") %>% 
  mutate(speedLimit = as.numeric(speedLimit),
         age = as.numeric(age))

## recode time as categorical variable
morning <- c("6:00 AM - 7:00 AM" ,"7:00 AM - 8:00 AM","8:00 AM - 9:00 AM",
             "9:00 AM - 10:00 AM","10:00 AM - 11:00 AM","11:00 AM - 12:00 noon")
afternoon <- c("12:00 noon - 1:00 PM","1:00 PM - 2:00 PM","2:00 PM - 3:00 PM",
               "3:00 PM - 4:00 PM","4:00 PM - 5:00 PM","5:00 PM - 6:00 PM")
night <- c("6:00 PM - 7:00 PM","7:00 PM - 8:00 PM","8:00 PM - 9:00 PM",
           "9:00 PM - 10:00 PM","10:00 PM - 11:00 PM","11:00 PM - 12:00 midnight")
lateNight <- c("12:00 midnight - 1:00 AM","1:00 AM - 2:00 AM","2:00 AM - 3:00 AM",
               "3:00 AM - 4:00 AM","4:00 AM - 5:00 AM","5:00 AM - 6:00 AM")

ped$time <- ifelse(ped$time %in% morning, "morning",
                   ifelse(ped$time %in% afternoon, "afternoon",
                          ifelse(ped$time %in% night, "night", "midnight")))

df_plot(ped)
cor_plot(ped)

# code worstinjury
ped$worstInjury <- recode(ped$worstInjury, 
                          "Suspected serious injury (A)" = "4", 
                          "Suspected minor injury (B)" = "3",
                          "Possible injury (C)" = "2",
                          "No injury (O)"  = "1", 
                          "Fatal injury (K)" = "5")

#recode intersection
ped$intersection <- recode(ped$intersection, 
                           "Not intersection crash" = "0", 
                           "Intersection crash" = "1")

#recode hit_run
ped$hit_run <- factor(ifelse(ped$hit_run == "Hit-and-run","yes","no"))

#recode year
ped$year <- as.factor(ped$year)

#descriptive
contents(ped)
df_plot(ped)
histograms(ped)

barcharts(ped)

#train and test data set
library(caret)
set.seed(1234)
index <- createDataPartition(ped$hit_run, p=0.8, list=FALSE)
train <- ped[index,]
test <- ped[-index,]

#set up training method
trControl <- trainControl(method = "cv", 
                          number = 10,
                          summaryFunction = twoClassSummary,
                          classProbs = TRUE,
                          sampling = "smote"
)
                         

#---------Basic logistic regression model-------
set.seed(1234)
model.lr <- train(hit_run ~ ., 
                  data = train,
                  trControl = trControl,
                  method = "glm",
                  family = "binomial",
                  metric = "ROC")

summary(model.lr)
round(exp(coef(model.lr$finalModel)), 3)

# variable importance
varImp(model.lr)
plot(varImp(model.lr))

# examine performance in test data (assumes cutoff of .5)
test$pred <- as.factor(predict(model.lr, test))
confusionMatrix(as.factor(test$pred), as.factor(test$hit_run), positive="yes")

# ROC curve 
train$prob <- predict(model.lr, train, type = "prob")[[2]]

library(plotROC)
ggplot(train, aes(d=hit_run, m=prob)) +
  geom_roc(labelround=2, n.cuts=15, labelsize=3) + 
  style_roc(major.breaks=seq(0, 1, .1),
            minor.breaks=seq(0, 1, .05),
            theme=theme_grey) +
  labs(title="ROC Plot")

#------logistic regression with lasso------
lambda <- 10^seq(-3, 3, length=100)

set.seed(123)
model.lasso <- train(
  hit_run ~., 
  data = train, 
  method = "glmnet",
  metric = "ROC", 
  family = "binomial",
  trControl = trControl,
  tuneGrid = data.frame(alpha = 1, lambda = lambda)
)
model.lasso

summary(model.lasso$finalModel)

# examine performance in test data (assumes cutoff of .5)
test$pred <- as.factor(predict(model.lasso, test))
confusionMatrix(as.factor(test$pred), as.factor(test$hit_run), positive="yes")

#-----backward selection with AIC------
set.seed(1234)
model.stepAIC <- train(hit_run ~ ., data=train,
                       method="glmStepAIC",
                       trControl = trControl,
                       metric="ROC")
model.stepAIC
summary(model.stepAIC$finalModel)

# examine performance in train data (assumes cutoff of .5)
test$pred <- as.factor(predict(model.stepAIC, test))
confusionMatrix(as.factor(test$pred), as.factor(test$hit_run), positive="yes")




#compare model
results <- resamples(list(
                          lasso = model.lasso,
                          logistic = model.lr,
                          stepAIC = model.stepAIC
))
summary(results)
bwplot(results)






############### stochastic gradient boost ##############
set.seed(1234)
model.gbm <- train(hit_run ~.,
                   data = train,
                   method = "gbm",
                   tuneLength = 10,
                   trControl = trControl,
                   metric = "ROC",
                   verbose = FALSE)

################### Random Forest ###################
library(randomForest)

set.seed(1234)
model.rf<-train(hit_run~., 
                data=train,
                method='rf',
                metric='ROC',
                tuneLength=8,
                ntree=100,
                trControl=trControl,
                importance=TRUE)

##################### ANN ######################
library(neuralnet)
set.seed(1234)
model.ann <- train(hit_run ~ ., 
                   data=train,
                   method="nnet",
                   tuneLength=5,  
                   metric="ROC",
                   trControl=trControl,
                   preProcess=c("range"),
                   verbose=FALSE)


################### model comparison ##########
results <- resamples(list(gbm = model.gbm,
                          ann = model.ann,
                          rf = model.rf,
                          lasso = model.lasso,
                          logistic = model.lr,
                          stepAIC = model.stepAIC
))
summary(results)
bwplot(results)










