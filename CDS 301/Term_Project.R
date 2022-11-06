##Zach Stept
##Term Project
##CDS301

##Packages
library(ggplot2)

##Dataset
shootings <- read.csv("shootings.csv")

##Plot
ggplot(shootings) +
  geom_bar(mapping = aes(x = race, fill = arms_category),
           position = "identity",
           alpha = .5) +
  facet_wrap(~ state) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  + 
  xlab("Race") + 
  ylab("Count") + 
  ggtitle("Shootings by State") +
  guides(fill = guide_legend(title = "Category of Victim's Weapon"))
