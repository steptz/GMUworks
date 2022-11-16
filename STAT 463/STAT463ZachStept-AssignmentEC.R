library(micromapST)

covid <- read.csv("HW5.csv")

paneldesc <- data.frame(
  type=c("mapcum","id","dot","dot","dot","dot"),
  lab1=c(NA,NA,"Cases","Deaths","Deaths/Cases","Cases/Deaths"),
  lab2=c(NA,NA,NA,NA,"Ratio","Ratio"),
  col1=c(NA,NA,"Cases","Deaths","Deaths.to.Cases.Ratio","Cases.to.Deaths.Ratio")
)

pdf(file="STAT463ZachStept-AssignmentEC.pdf",width=7.5,height=10)

micromapST(covid, paneldesc,
           rowNamesCol = 'State',
           rowNames = 'ab',
           plotNames = 'full',
           sortVar = 'Cases.to.Deaths.Ratio',
           ascend = FALSE,
           title =c("COVID Cases and Deaths for All 50 US States and Capitol"),
           ignoreNoMatches = TRUE)
)

dev.off()
