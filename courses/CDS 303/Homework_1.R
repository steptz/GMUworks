##Homework 1
##Zach Stept

#creation of dataframe
df<-as.data.frame(rbind(c(1,'1-2','m','u','l')
                        ,c(2,'2-7','m','r','h')
                        ,c(3,'>7','f','r','l')
                        ,c(4,'1-2','f','r','h')
                        ,c(5,'2-7','m','r','h')
                        ,c(6,'1-2','m','r','h')
                        ,c(7,'2-7','f','u','l')
                        ,c(8,'2-7','m','u','h')))
names(df)<-c('person','time','gender','area','risk')

#entropy function
entropy <- function(x, y) {
  total = x + y
  impurity = (-1 * (x/total)*log2((x/total))) - ((y/total)*log2((y/total)))
  if(is.nan(impurity)){
    return(0)
  }
  return(impurity)
}

#entropy of risk
entropy_risk <- entropy(5, 3)

#gains - step 1
gain_time1 <- entropy_risk - ((3/8)*entropy(1, 2) + (4/8)*entropy(1, 3) + (1/8)*entropy(1, 0))
gain_area1 <- entropy_risk - ((3/8)*entropy(2, 1) + (5/8)*entropy(1, 4))
gain_gender1 <- entropy_risk - ((5/8)*entropy(1, 4) + (3/8)*entropy(2, 1))

#gains - step 2 for time 1 to 2
gain_area2_1_2 <- entropy_risk - ((1/3)*entropy(1, 0) + (2/3)*entropy(0, 2))
gain_gender2_1_2 <- entropy_risk - ((2/3)*entropy(1, 1) + (1/3)*entropy(0, 1))

#gains - step 2 for 2 to 7
gain_area2_2_7 <- entropy_risk - ((2/4)*entropy(1, 1) + (2/4)*entropy(0, 2))
gain_gender2_2_7 <- entropy_risk - ((3/4)*entropy(0, 3) + (1/4)*entropy(1, 0))

#gains - step 2 for over 7
gain_area2_7 <- entropy_risk - ((0/1)*entropy(0, 0) + (1/1)*entropy(1, 0))
gain_gender2_7 <- entropy_risk - ((0/1)*entropy(0, 0) + (1/1)*entropy(1, 0))

