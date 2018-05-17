library(tidyverse)
library(lme4)

shva <- read.delim("D:/R home task/duryagin_ReductionRussian.txt", header=TRUE, sep="\t")

shva %>%
  ggplot(aes(x=f2, y=f1, color = vowel)) +
  geom_point()+
  scale_x_reverse()+
  scale_y_reverse()+
  ylab("f1")+
  xlab("f2")+
  labs(title = "f2 and f1 of the reduced and stressed vowels")+ 
  theme(legend.position="none")

shva %>%
  ggplot(aes(vowel, f1, fill = vowel)) +
  geom_boxplot()+
  ylab("f1")+
  xlab("")+
  coord_flip()+
  labs(title = "f1 distribution in each vowel")+
  theme(legend.position="none")

shva %>%
  ggplot(aes(vowel, f2, fill = vowel)) +
  geom_boxplot()+
  ylab("f2")+
  xlab("")+
  coord_flip()+
  labs(title = "f2 distribution in each vowel")+
  theme(legend.position="none")


is_outlier <- function(x) {
  return(x < quantile(x, 0.25) - 1.5 * IQR(x) | x > quantile(x, 0.75) + 1.5 * IQR(x))
}
shva %>%
  group_by(vowel) %>%
  mutate(outlier = ifelse(is_outlier(f1), f1, as.numeric(NA))) %>%
  ggplot(., aes(vowel, f1)) +
  geom_boxplot() +
  geom_text(aes(label = outlier))
#f1 outliers in a vowel = {679, 686, 826}


cor(shva$f1, shva$f2, use="complete.obs", method="pearson")

cor(shva$f1[shva$vowel == "A"], shva$f2[shva$vowel == "A"], use="complete.obs", method="pearson")
cor(shva$f1[shva$vowel == "a"], shva$f2[shva$vowel == "a"], use="complete.obs", method="pearson")
cor(shva$f1[shva$vowel == "y"], shva$f2[shva$vowel == "y"], use="complete.obs", method="pearson")

linearMod <- lm(f1 ~ f2, data=shva)
print(linearMod)
#f1 = 1678.9408 - 0.7839???f2
summary (linearMod)
#Adjusted R-squared:  0.3319 

shva$model1 <- predict(linearMod)

shva %>%
  ggplot(aes(x=f2, y=f1)) +
  geom_point(aes(color = vowel))+
  scale_x_reverse()+
  scale_y_reverse()+
  geom_line(aes(f2, model1))+
  ylab("f1")+
  xlab("f2")+
  labs(title = "f2 and f1 of the reduced and stressed vowels")+ 
  theme(legend.position="none")

linearMod2 <- lmer(f1 ~ f2 + (1|vowel), data = shva)
print(linearMod2)
#f1 = 489.32283 + 0.06269???f2
summary(linearMod2)
#  variance of intercept for vowel variable = 16741

shva$model2 <- predict(linearMod2)

shva %>%
  ggplot(aes(x=f2, y=f1, color = vowel)) +
  geom_point()+
  scale_x_reverse()+
  scale_y_reverse()+
  geom_line(aes(f2, model2, color = vowel))+
  ylab("f1")+
  xlab("f2")+
  labs(title = "f2 and f1 of the reduced and stressed vowels")+ 
  theme(legend.position="none")
