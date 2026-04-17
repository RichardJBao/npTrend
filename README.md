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
- Linear Trend with Breaks: Detect and test for structural breaks in linear trends using bootstrap inference.
- Nonparametric Trend: Estimate trends using kernel smoothing with automated bandwidth selection via Modified Cross-Validation (MCV).
- Robust Confidence Intervals: Generate both pointwise and simultaneous confidence bands that are robust to serial correlation.

# **Examples**:

The following is an entire simulation study, with a simulation of atmospheric ethane data featuring a trend break and seasonality.

1) Simulating data

```{r}
set.seed(42)
n <- 500
# Create a timeline in decimal years (e.g., 14 years of daily data)
time <- seq(1994, 2008, length.out = n) 

# 2. Base Linear Trend 
base_trend <- 10 - 0.5 * (time - 1994)

# 3. Continuous Trend Reversal
# Exactly halfway, the slope sharply reverses upward. No sudden vertical jump!
break_idx <- n / 2
slope_shift <- ifelse(1:n >= break_idx, 1.2 * (time - time[break_idx]), 0)

# 4. Seasonality and Noise
seasonality <- 3 * sin(2 * pi * time) + 1.5 * cos(2 * pi * time)
noise <- rnorm(n, mean = 0, sd = 2)

# 5. Final Target Variable
y <- base_trend + slope_shift + seasonality + noise


plot(time,
     y, 
     xlab = "Year", 
     ylab = "Measurement")

# Drop a vertical blue line exactly where the break occurs
abline(v = time[break_idx], col = "blue", lty = 2, lwd = 2)
```
<img width="798" height="605" alt="da65f3f8-d628-45dc-891a-a65d57197352" src="https://github.com/user-attachments/assets/5e01c048-43e0-4f10-a6bc-e034cd651b40" />

2) Setup

Note that for the non-parametric trend estimation, we require that $B > \frac{1}{alpha}$

```{r}
# Load package and dependencies 

library(npTrend)
library(parallel)
library(doParallel)
library(foreach)

# Set bootstrap and alpha
B <- 1000 # Change B as appropriate
alpha <- 0.05 # Change alpha as appropriate
```

2) Linear Trend with Break Detection

```{r}
# Load package and dependencies 

library(npTrend)
library(parallel)
library(doParallel)
library(foreach)

# Test for a structural break and estimate linear parameters
# Change B as appropriate
lin.results <- lin.trend(y, time, B = 1000, alpha = 0.05)

# Assign outputs
p.value <- lin.results[[1]]
critical.value <- lin.results[[2]]
S_T <- lin.results[[3]]
para <- lin.results[[4]]
fit.fourier <- lin.results[[5]]
breakdate <- lin.results[[6]]
CI.breakdate <- lin.results[[7]]
CI.para <- lin.results[[8]]

# Print output, using "low" and "up" for suitable y-axis bounds
# plots the estimated trend, cycle, and confidence interval of breakpoint
low <- 0
up <- 30e+15
ylab <- "Ethane total column (molec cm-2)"
xlab <- "time"
plot.results.linear(y,time,fit.fourier,breakdate,CI.breakdate,low,up,xlab,ylab)
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

Richard Bao (author)

Stephan Smeekes (contributor)

Eric Beutner (contributor)

## Citation

If you use `npTrend` in your research, please cite it as follows:

**Plain Text:**
Friedrich, Marina & Bao, Richard & Smeekes, Stephan & Beutner, Eric (2026). *npTrend: Non-parametric Trend Analysis*. R package version 1.0.0. https://github.com/yourusername/npTrend

**BibTeX:**

```bibtex
@Manual{nptrend2026,
  title = {npTrend: Non-parametric Trend Analysis},
  author = {Friedrich, Marina and Bao, Richard and Smeekes, Stephan and Beutner, Eric},
  year = {2026},
  note = {R package version 1.0.0},
  url = {[https://github.com/RichardJBao/npTrend](https://github.com/RichardJBao/npTrend)},
}
```

# **References**
Friedrich, M., Beutner, E., Reuvers, H. et al. A statistical analysis of time trends in atmospheric ethane. Climatic Change 162, 105–125 (2020). https://doi.org/10.1007/s10584-020-02806-2

