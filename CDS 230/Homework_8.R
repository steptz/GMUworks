################################################
## Name: Zachary Stept
## Assignment: 8
################################################

#Setup


#reads csv file and assigns it to variable
mydata <- read.csv("total-covid-deaths-per-million-2.csv")

#searches through mydata for World Entity
mydata <- mydata[which(mydata$Entity == "World"),]

#reformats date
mydata$Date <- format(as.Date(mydata$Date, "%b %d, %Y"), "%Y-%m-%d")


#Time Series (accounts for leap year)


#calculates total number of days for the data
endDate <- as.numeric(as.Date("2020-3-28") - as.Date("2019-12-31")) + 1

#assigns mydata to time series
mydatats <- ts(mydata$Total.confirmed.deaths.due.to.COVID.19.per.million.people..deaths.per.million., start = c(2019, 366), end=c(2020, endDate), frequency = 366)

#plots time series
plot(mydatats, main = "Time Series of Total COVID Deaths per Million")


#10 Monte Carlo Simulations


log_returns <- log(1+mydatats/stats::lag(mydatats,-1) - 1)
log_returns <- log_returns[12:88] #removes all NA from dataset

plot(log_returns)

var(log_returns)
mean(log_returns)
sd(log_returns)

drift <- mean(log_returns) - (0.5 * var(log_returns))

t_intervals <- 200 #generates predictions for the next 20 days
iterations <- 10

daily_returns <- exp(as.numeric(drift) + sd(log_returns) * qnorm(matrix(runif(t_intervals), iterations)))
S0 <- tail(mydata,1)
S0<- S0$Total.confirmed.deaths.due.to.COVID.19.per.million.people..deaths.per.million.
mydata_list <- matrix(0, ncol = t_intervals/iterations, nrow = iterations)
mydata_list[,1] <- S0

for (i in 2:(t_intervals/iterations)){
  mydata_list[,i] <- mydata_list[,i-1] * daily_returns[,i]
}  

plot(mydata_list[1,], col = sample(1:iterations, replace = F), type = "l", xlab = "Simulation time", ylab = "Simulations", ylim = c(min(mydata_list), max(mydata_list)))

for(j in 2:iterations){
  points(mydata_list[j,], type = "l", col=sample(2:iterations, replace = F))
}

#generates the statistics for the monte carlo simulations
summary(mydata_list)
mean(mydata_list)
sd(mydata_list)
var(mydata_list)