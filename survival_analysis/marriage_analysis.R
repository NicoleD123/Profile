library(survival)
library(ggplot2)
library(survminer)


#Intro: what we are interested in, what we have found, what we can talk about our findings 
#Introduction #####

marriage<-read.csv("https://raw.githubusercontent.com/nazzstat/SurvivalData/master/nesarc_marriage.csv")
#data management
# We set lived_bio, bio_divorce, father_behave, mother_behave as factors.
# We also set all the unknown data into N/A so that it would not influence our later analysis.
marriage$BIO_DIVORCE<-as.factor(marriage$BIO_DIVORCE)
marriage$LIVED_BIO<-as.factor(marriage$LIVED_BIO)
marriage$FATHER_BEHAV[marriage$FATHER_BEHAV==9]<-NA
marriage$FATHER_BEHAV<-as.factor(marriage$FATHER_BEHAV)
marriage$MOTHER_BEHAV[marriage$MOTHER_BEHAV==9]<-NA
marriage$MOTHER_BEHAV<-as.factor(marriage$MOTHER_BEHAV)

#KM curve and log rank test
#Based on the KM curves and log rank test, we found that people whose parents divorced during childhood get marriage later than people whose parents did not divorced.
#This is also significant according to the log rank test (X-sq=38.6, p<0.001). There is not significant difference in the time people get marriage between people who lived with their parents during childhood or not (X-sq=0, p-value=0.9). 
# Through the KM curve, we observed there is an interaction between bio_divorce and lived_bio. Namely, the effect of Bio_divorce is dependent on whether this person lived with their parents or not during childhood.

#KM curves for BIO_DIVORCE 
mod <- survfit(Surv(SYEARS, MARRIED)~BIO_DIVORCE, data=marriage)
ggsurvplot(mod)

survdiff(Surv(SYEARS,MARRIED)~BIO_DIVORCE, data=marriage, rho=0)
#According to log rank test, there is a significant difference between people whose 
#parents divorced during their childhood and those whose parents did not (X-sq(1)=38.6, p<0.001).

#KM curves for LIVED_BIO 
mod_1<- survfit(Surv(SYEARS, MARRIED)~LIVED_BIO, data=marriage)
ggsurvplot(mod_1)

survdiff(Surv(SYEARS,MARRIED)~LIVED_BIO, data=marriage, rho=0)

#According to the log-rank test, there is no significant difference between 
#people who lived with at least one of their parents during childhood 
#and those who did not. (X-sq (1)=0, p-value=0.9)


#KM curves for BIO_DIVORCE and LIVED_BIO
mod1 <- survfit(Surv(SYEARS, MARRIED)~BIO_DIVORCE+LIVED_BIO, data=marriage)
ggsurvplot(mod1)

#From the graph, it seems that there is an interaction between the variables 
#LIVED_BIO and BIO_DIVORCE. We will continue to test this in a Cox PH model


#KM curves for MOTHER_BEHAV and FATHER_BEHAV
mod2<- survfit(Surv(SYEARS, MARRIED)~MOTHER_BEHAV+FATHER_BEHAV, data=marriage)
ggsurvplot(mod2)
#Based on the graph, it seems that there is no interactions between MOTHER_BEHAV
#and FATHER_BEHAV. Therefore, we will not consider the interaction between them 
#in our Cox PH model. 

#Cox PH model 
mod3<- coxph(Surv(SYEARS, MARRIED)~BIO_DIVORCE+LIVED_BIO+BIO_DIVORCE*LIVED_BIO+
               MOTHER_BEHAV+FATHER_BEHAV, data=marriage)

#Assumption test 
#Graphical assessments indicate Bio_divorce violate the proportional hazards assumption since there increasing gap between two curves. Other variables did not violate the assumption.
#The goodness of fit test indicate there is a significant violation of PH for the mother_behave (X-sq (1) =10.43, p=0.0012), father_behave (X-sq (1) =22.12, p<.001), and bio_divorce (X-sq (1) =25.02, p<.001) violate the assumptions.
#In order to satisfied the PH assumption, we decided to further stratified the our data. 

#BIO_DIVORCED
fit<- survfit(Surv(SYEARS, MARRIED)~BIO_DIVORCE, data=marriage)
ggsurvplot(fit, fun="cloglog", data=marriage, palette="Set1")
#It seems that proportional hazards assumption is violated 
#since there is an increasing gap between the two curves of log(-log(S(t)))

#LIVED_BIO
fit1<- survfit(Surv(SYEARS, MARRIED)~LIVED_BIO, data=marriage)
ggsurvplot(fit1, fun="cloglog", data=marriage, palette="Set1")
#It seems that proportional hazards assumption is reasonable  
#since there is an approximate parallelism between the two curves of log(-log(S(t)))

#MOTHER_BEHAV
fit2<- survfit(Surv(SYEARS, MARRIED)~MOTHER_BEHAV, data=marriage)
ggsurvplot(fit2, fun="cloglog", data=marriage, palette="Set1")
#It seems that proportional hazards assumption is reasonable  
#since there is an approximate parallelism between the two curves of log(-log(S(t)))

#FATHER_BEHAV
fit3<- survfit(Surv(SYEARS, MARRIED)~FATHER_BEHAV, data=marriage)
ggsurvplot(fit3, fun="cloglog", data=marriage, palette="Set1")
#It seems that proportional hazards assumption is reasonable  
#since there is an approximate parallelism between the two curves of log(-log(S(t)))


#Goodness of Fit test 
cox.zph(mod3, transform="rank")

#stratified cox model
# So we stratified our cox model based on BIO_DIVORCED in order to satisfied the PH assumption. We first examined the subset of data with people whose parents divorced during their childhood. According to the goodness of fit test, we still have statistically significant violation of the assumption of out model (X-sq (3) =8.62, p= 0.035).
# We then examined the subset of data for people whose parents did not divorced during their childhood. According to the goodness of fit test, only father_behave significantly violated the PH assumption (X-sq (1) =9.36, p= 0.0022). Therefore, it seems like the subset of data with BIO_DIVORCED that is No is more reasonable and suitable for further analysis.
#Now then we stratified further by Father_behave. This leaves us with additional 2 models to run.
# Our first model is for people whose parents did not divorce during their childhood and have a father with personality disorder. The goodness of fit test indicates we no longer have models that suffer from a severe violation of the Cox PH assumption (X-sq (2) =0.1265, p= 0.94).
# It is the same case for our second model.Our second model is for people whose parents did not divorce during their childhood and have a father without personality disorder. The goodness of fit test indicates we no longer have model that suffer from a severe violation of the Cox PH assumption (X-sq (2) =8.62, p= 0.035).

#stratified cox model for BIO_DIVORCED 
#stratified: divorce_yes
divorce_yes<-marriage[marriage$BIO_DIVORCE==1,]
mod_divorce_yes<-coxph(Surv(SYEARS,MARRIED)~LIVED_BIO+MOTHER_BEHAV+
                         FATHER_BEHAV+BIO_DIVORCE*LIVED_BIO,
                       data=divorce_yes)
cox.zph(mod_divorce_yes, transform="rank")
#For this sub group, according to the goodness of fit test,
#both FATEHR_BEHAV and MOTHER_BEHAV violate the proportional hazard assumption
#(p-value=0.021; p-value=0.029)


#stratified: divorce_no
divorce_no<-marriage[marriage$BIO_DIVORCE==2,]
mod_divorce_no<-coxph(Surv(SYEARS,MARRIED)~LIVED_BIO+MOTHER_BEHAV+
                         FATHER_BEHAV+BIO_DIVORCE*LIVED_BIO,
                       data=divorce_no)
cox.zph(mod_divorce_no, transform="rank")
#For this sub group, according to the goodness of fit test,
#only the FATEHR_BEHAV violates the proportional hazard assumption(p-value=0.002). And we will continue to stratify 
#the data set for FATHER_BEHAV within the divorce_no subgroup.

#Stratified: FATHER_BEHAV-Yes
divorce_no_father_yes <- divorce_no[divorce_no$FATHER_BEHAV==1,]
mod_divorce_no_father_yes<-coxph(Surv(SYEARS,MARRIED)~LIVED_BIO+MOTHER_BEHAV,
                      data=divorce_no_father_yes)
cox.zph(mod_divorce_no_father_yes, transform="rank")
#According to the goodness of fit test, there are no variables violating the proportional hazard assumption. 
summary(mod_divorce_no_father_yes)
#This subgroup contains people whose parents did not divorce during their childhood and their biological fathers had a personality disorder.
#Based on cox ph model, when holding MOTHER_BEHAV fixed, the hazards of people who did not live with at least one biological 
#parent in childhood are expected to be 2.03376 times as that of those who lived with their parents during childhood. However, this variable is not significant. (z=1.227, p-value=0.22)
#Based on cox ph model, when holding LIVED_BIO fixed, the hazards of people whose mother did not have personality disorder 
#are expected to be 1.08 times of that of people whose mother had. However, this variable is not significant either. (z=-1.005, p-value=0.315)


#stratified: FATHER_BEHAV-no
divorce_no_father_no <- divorce_no[divorce_no$FATHER_BEHAV==2,]
mod_divorce_no_father_no<-coxph(Surv(SYEARS,MARRIED)~LIVED_BIO+MOTHER_BEHAV,
                                 data=divorce_no_father_no)
cox.zph(mod_divorce_no_father_no, transform="rank")
#According to the goodness of fit test, there are no variables violating the proportional hazard assumption.
summary(mod_divorce_no_father_no)
#This subgroup contains people whose parents did not divorce during their childhood and their biological fathers had a personality disorder.
#Based on the cox ph model, when holding MOTHER_BEHAV fixed, the hazard of marriage for people who lived with their parents during childhood is expected to increase by a factor of 1.0859 than those who did not. 
#However, this variable is not significant(z=-0.669, p-value=0.504), 
#and when holding LIVED_BIO fixed, the hazards of marriage for people whose mother did not have personality disorder are expected to be 1.053 times as that of people whose mother did. 
#However, this variable is not significant (z=0.602, p-value=0.547).








