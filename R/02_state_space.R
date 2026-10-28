library(forecast)
library(dlm)
library(yaml)

config <- yaml.load_file("conf/config.yml")
data <- readRDS(config$output_paths$clean_data)

# 1. Alcoa: Local Trend State Space
build_local_trend <- function(theta) { dlmModPoly(order = 1, dV = exp(theta[1]), dW = exp(theta[2])) }
fit_dlm <- dlmMLE(data$log_vol, parm = c(0, 0), build = build_local_trend)
mod_dlm <- build_local_trend(fit_dlm$par)

# 2. Pfizer: Time-Varying CAPM
build_capm <- function(theta) {
  dlmModReg(data$r_m, dV = exp(theta[1]), dW = c(exp(theta[2]), exp(theta[3])))
}
fit_capm <- dlmMLE(data$r_p, parm = c(0, 0, 0), build = build_capm)
mod_capm <- build_capm(fit_capm$par)

# 3. PPI: AR(3) with Measurement Errors
ar3_model <- arima(data$y_t, order=c(3,0,0), include.mean=FALSE)
build_ar3_ss <- function(theta) {
  mod <- dlmModARMA(ar = ar3_model$coef[1:3], sigma2 = exp(theta[1]))
  mod$V <- exp(theta[2])
  return(mod)
}
fit_ar3_ss <- dlmMLE(data$y_t, parm = c(0, 0), build = build_ar3_ss)
mod_ar3_ss <- build_ar3_ss(fit_ar3_ss$par)

saveRDS(list(alcoa=mod_dlm, pfizer=mod_capm, ppi=mod_ar3_ss),
        file = config$output_paths$models)
cat("State-Space Modeling Complete.\n")