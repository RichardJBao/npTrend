# **npTrend**

npTrend is an R package for nonparametric and linear trend estimation in time series data, using Autoregressive Wild Bootstrap (AWB) to handle
error dynamics. This package implements the methodology described in Friedrich et al. (2020). 

# **Installation**

You can install the development version of npTrend from GitHub:

```{r}
# Install devtools if you haven't already

if (!require("devtools")) install.packages("devtools")

# Install the package

devtools::install_github("RichardJBao/npTrend")
```

Core Features
- Nonparametric Trend: Estimate trends using kernel smoothing with automated bandwidth selection via Modified Cross-Validation (MCV).
- Linear Trend with Breaks: Detect and test for structural breaks in linear trends using bootstrap inference.
- Robust Confidence Intervals: Generate both pointwise and simultaneous confidence bands that are robust to serial correlation.

# **Examples**:

1) Linear Trend with Break Detection

```{r}
# Load package

library(npTrend)

# Test for a structural break and estimate linear parameters

lin_results <- lin.trend(y, time, B = 500, alpha = 0.05)

# Plot the linear fit and the identified break point

plot(lin_results, xlabel = "Year", ylabel = "Measurement")
```

2) Nonparametric Trend Estimation

```{r}
# Example: Estimate trend with 95% confidence bands

# y = observations, time = decimal dates

results <- nonpara.trend(y, time, B = 500, alpha = 0.05)

# Plot the results using the built-in S3 method

plot(results, time = time, xlabel = "Year", ylabel = "Measurement")
```

# **Authors** 

Marina Friedrich (author, maintainer)

...

Richard Bao (developer)
