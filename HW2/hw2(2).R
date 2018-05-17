library(tidyverse)
library(lme4)
elp <- read_csv("https://raw.githubusercontent.com/agricolamz/2018-MAG_R_course/master/data/ELP.csv")

cor_vect = c(cor(elp$SUBTLWF, elp$Length, method="pearson"), cor(elp$SUBTLWF, elp$Mean_RT, method="pearson"), cor(elp$Length, elp$Mean_RT, method="pearson"))
cor_vect
max(cor_vect)
#highest Pearson’s correlaton between Length and Mean_RT


elp %>%
  group_by(POS) %>%
  ggplot(aes(x=SUBTLWF, y=Mean_RT, color = Length)) +
  scale_colour_gradient(low = "#bad8ef", high = "#fc0000")+
  geom_point()+
  scale_x_log10()+
  facet_wrap(~POS)

lm1 <- lm(Mean_RT  ~ log(SUBTLWF), data=elp)
print(lm1)
#Mean_RT = 769.11 - 38.21∗log(SUBTLWF)
summary (lm1)
#Adjusted R-squared:  0.3271

elp$model1 <- predict(lm1)

elp %>%
  ggplot(aes(x=log(SUBTLWF), y=Mean_RT)) +
  geom_point(aes(color = Length))+
  scale_colour_gradient(low = "#bad8ef", high = "#fc0000")+
  geom_line(aes(log(SUBTLWF), model1))



lm2 <- lmer(Mean_RT  ~ log(SUBTLWF) + (1|POS), data = elp)
print(lm2)
#Mean_RT =  767.71 -37.67∗log(SUBTLWF)
summary(lm2)
#  variance of intercept for POS variable = 414.4

elp$model2 <- predict(lm2)

elp %>%
  ggplot(aes(x=log(SUBTLWF), y=Mean_RT)) +
  geom_point(aes(color = POS))+
  geom_line(aes(log(SUBTLWF), model2), size= 1)+
  facet_wrap(~POS)+
  theme(legend.position="none")

