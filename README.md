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
# seed for reproducibility
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

Note that for the non-parametric trend estimation, we require that $B > \frac{1}{alpha}$ to obtain the simultaneous confidence intervals. Generally, it is not advisable to construct simultaneous confidence intervals with such low number of bootstrap repetitions as they are likely not reliable.

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
# Main trend estimation
lin_results <- lin.trend(y, time, B, alpha, nterms = 3, trim.frac = 0.1, cores = 1)
# cores default is 1 (no parallelization). It can be set to max(1, detectCores()-1) to parallelize the bootstrap

# assign results
p.value <- lin_results[[1]]
critical.value <- lin_results[[2]]
S_T <- lin_results[[3]]
para <- lin_results[[4]]
fit.fourier <- lin_results[[5]]
breakdate <- lin_results[[6]]
CI.breakdate <- lin_results[[7]]
CI.para <- lin_results[[8]]

plot(time,
     y,
     xlab = "Year", 
     ylab = "Ethane total column (molec cm-2)",
     main = "Estimation of Breakdate and True Breakdate"
)

legend("bottomright",                              # Position (can be "topleft", "bottomright", etc.)
       legend = c("Estimated Break", "True Break"), # The text labels
       col = c("blue", "purple"),               # Match the colors of your ablines
       lty = c(2, 2),                           # Match the line types (2 = dashed)
       lwd = c(2, 2),                           # Match the line widths
       bty = "n")

# Drop a vertical blue line exactly where the break occurs
abline(v = breakdate, col = "blue", lty = 2, lwd = 2) # estimated break
abline(v = time[break_idx], col = "purple", lty = 2, lwd = 2) # real break
```

<img width="798" height="605" alt="0afab9dd-6bd9-45e0-abc6-cb6edb48ce76" src="https://github.com/user-attachments/assets/332db7ee-51a0-48bd-a856-12745b453014" />


```{r}
lin.low <- min(y)
lin.up <- max(y)
lin.ylab <- "Ethane total column (molec cm-2)"
lin.xlab <- "time"
lin.title <- "Linear Trend Estimation Results"

plot.results.linear(y,time,fit.fourier,breakdate,CI.breakdate,lin.low,lin.up,lin.xlab,lin.ylab, main = lin.title)
abline(v = breakdate, col = "purple", lty = 2, lwd = 2)

legend("bottomright",                              # Position (can be "topleft", "bottomright", etc.)
       legend = c("Estimated Break", "Break Confidence Intervals", "Seasonality Estimate", "Trend Estimate"), # The text labels
       col = c("purple", "black", "blue", "black"),               # Match the colors of your ablines
       lty = c(2, 3, 1, 1),                           # Match the line types (2 = dashed)
       lwd = c(2, 2, 2, 2),                           # Match the line widths
       bty = "n")

```

<img width="798" height="605" alt="a1467810-4cdd-410d-bede-ffa74bb62188" src="https://github.com/user-attachments/assets/34c07342-f26a-45b2-9c26-59772a023920" />


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

