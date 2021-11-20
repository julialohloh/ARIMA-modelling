# ARIMA-modelling
Predicting dengue cases with ARIMA

Perform exploratory data analysis on dengue incidence data in Singapore.

Data preparation
Dengue incidence data is available on a weekly basis from data.gov.sg. The data in this dataset is from January 2014 to December 2018. The weekly data is provided for each epidemiological week (E-week) which is a 7-day period from Sunday 0000hrs to Saturday 2359hrs, according to the National Environment Agency. In each year from 2014 to 2018, there are a total of 53 epidemiological weeks.

Assuming NEA uses CDC MMWR epidemiological weeks,  the package “MMWRweek” is used to convert to months
https://wwwn.cdc.gov/nndss/downloads.html and https://www.cmmcp.org/mosquito-surveillance-data/pages/epi-week-calendars-2008-2021.

Exploratory data analysis include:
1) seasonal plot of dengue incidence across the years (to identify if there is a trend in dengue incidence)
2) seasonal subseries plot to corroborate (1)
3) Identify if there is correlation between dengue incidence and total rainfell through qplot and Spearman correlation

ARIMA prediction
As ARIMA requires (a) Periods to lag, (2) amount of differencing required to transform a time series into stationary, and (3) lag of the error component, where error component is a part of the time series not explained by trend or seasonality, a series of plots are tests are done to determine these variables.
1) Plot ACF to check how the given time series is correlated with itself
2) Ljung box test to test whether any of a group of autocorrelations of a time series are different from zero
3) Seasonal decomposition by time series by Loess to separate a time series into seasonal, trend and irregular components
4) Test for seasonlity using (a) isSeasonal, (b) Kruskal Wallis and (c) Friedman rank test
5) Augment Dickey-Fuller test to test is data is stationary

Although data is shown to be not stationary, we use auto arima (where optimal p, d, and q values suitable for the data set will be generated) for forecasting. The results show:
1) ARIMA(1,0,2)(0,0,1)[12] with non-zero mean was used for the data
2) The ACF and PACF plots show that there are lack of correlation in residuals, which mean forecast is optimal
3) Check residuals tests (Ljung box test) which is use to determine forecast accuracy shows that p-values are all greater than 0.05 and none of the correlations for the autocorrelation function of the residuals are significant. Model meets the assumption that the residuals are independent/ white noise
4) Coefficient test shows that the autoregressive terms (p, q values) has a p-value that is less than the significance level of 0.05, showing that the coefficient for the autoregressive term is statistically significant and the term should be kept in the model.
5) Root means squared error (RMSE) values are quite high which means that the model may not predict the data accurately.
