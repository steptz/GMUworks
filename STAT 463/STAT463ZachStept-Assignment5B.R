library(micromapST)

covid <- read.csv("Hw5.csv")

paneldesc <- data.frame(
  type=c("map","id","dot","dot"),
  lab1=c(NA,NA,"Cases per Capita","Deaths per Capita"),
  col1=c(NA,NA,"Cases.per.Population","Deaths.per.Population")
)

pdf(file="STAT463ZachStept-Assignment5B.pdf",width=7.5,height=10)

micromapST(covid, paneldesc,
           rowNamesCol = 'State',
           rowNames = 'ab',
           plotNames = 'full',
           sortVar = 'Population',
           ascend = FALSE,
           title =c("COVID Deaths and Cases per State Capita from January 22, 2020 to April 8, 2021",
                    "States Sorted by Population (Greatest to Least)"),
           ignoreNoMatches = TRUE)
)

dev.off()
