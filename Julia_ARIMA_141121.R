library(pacman)
p_load(dplyr, tidyr, ggplot2, forecast,tseries, gridExtra, lubridate, zoo, xts, scales, 
vars, ggfortify,seastests, Metrics, rstatix, DescTools, pairwiseComparisons, exact2x2)

rm(list=ls())
data <- read.csv("data.csv")

#------------------------------------------------------------------------------------------------------------------------------------------------------
#plot using plot
class(data$month)
data$month <- as.yearmon(data$month)
class(data$month)
data$month <- as.Date(data$month, format = "%m/%d/%y")
View(data)

y <- ts(data$dengueCases, start=2012, frequency=12)

#seasonal plots
#https://otexts.com/fpp2/seasonal-plots.html
ggseasonplot(y, col = rainbow(12), season.labels = c("Jan","Feb","Mar","Apr","May","Jun","Jul", "Aug", "Sep", "Oct", "Nov","Dec")) +
  ylab("Dengue Incidence") +
  ggtitle("Seasonal plot: Dengue Incidence across the years")+ 
  theme(legend.position=c("bottom"))

#Seasonal subseries plot, across various years
#mean is indicated by blue horizontal line
ggsubseriesplot(y) +
  ylab("Dengue Incidence") +
  ggtitle("Seasonal subseries plot: Dengue Incidence")

data2 <- ts(data, start=c(2012, 1), end= c(2020, 12), frequency=12)

qplot(total_rainfall, dengueIncidence, data=as.data.frame(data2)) + 
  ylab("Dengue Incidence") + xlab("Total rainfall (mm)")

correlation <- cor.test(data$dengueCases, data$total_rainfall,
                        method = "spearman")
correlation
#p = 0.65, accept null, no significant association
#rho shows that little association

#ACF plot
gglagplot(y)
acf(y, plot = FALSE)
ggAcf(y)
pacf(y)


#Is there cyclicity? https://afit-r.github.io/ts_exploration
#or white noise? dotted blue lines represent the 95% threshold.
#If there are one or more large spikes outside these bounds, or if more than 5% of spikes are outside these bounds, then the series is probably not white noise.
#Some signals for forecasting
#Ljung-Box test, which tests whether any of a group of autocorrelations of a time series are different from zero
#When the Ljung Box test is applied to the residuals of an ARIMA model, the degrees of freedom h must be equal to m-p-q, where p and q are the number of parameters in the ARIMA(p,q) model
Box.test(y, lag = 24, fitdf = 0, type = "Lj")

plot(stl(y, s.window = "periodic"))

#test for seasonality
isSeasonal(y, test = "kw", freq = NA)
#seasonal
kw(y, freq = 12, diff = F, residuals = T, autoarima = F)
#null hypothesis is no stable seasonality. p<0.0 means reject null, take alternative - seasonal
fried(y, freq = NA, diff = T, residuals = F, autoarima = T)

#check whether stationary data or not
#This is import for ARIMA because it uses previous lags (time periods) of a series to model its behavior and modelling a series with consistent properties involves less uncertainty
adf.test(y, alternative = "stationary")
#data non-stationary

# ---------------------------------------------------------------------------------------------------------------------
#Auto arima (with stepwise differencing) to forecast even though data not stationary
# ---------------------------------------------------------------------------------------------------------------------
denguecases_arima <- auto.arima(y)
denguecases_arima
ggtsdisplay(residuals(denguecases_arima))
checkresiduals(denguecases_arima)

future_dengue <- forecast(denguecases_arima, 24)
plot(future_dengue, ylab = "Total dengue cases", xlab = "Time", main = "ARIMA Prediction of Dengue fever cases from Jan 2021 to Jan 2022")
future_dengue %>% forecast(xreg = xreg) %>% autoplot() %>% legend(x = "topleft",legend = c("train", "predicted"),lty = c(1, 1),col = c("black", 4),lwd = 2) 
coeftest(denguecases_arima)
confint(denguecases_arima)
summary(denguecases_arima)

#we can conclude that the residuals are not distinguishable from a white noise series.
#The mean of the residuals is close to zero and there is no significant correlation in the residuals series. The time plot of the residuals shows that the variation of the residuals stays much the same across the historical data, apart from the one outlier, and therefore the residual variance can be treated as constant. This can also be seen on the histogram of the residuals. The histogram suggests that the residuals may not be normal - the right tail seems a little too long, even when we ignore the outlier. Consequently, forecasts from this method will probably be quite good, but prediction intervals that are computed assuming a normal distribution may be inaccurate.

