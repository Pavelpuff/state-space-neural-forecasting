library(forecast)
library(nnet)
library(yaml)

config <- yaml.load_file("conf/config.yml")
data <- readRDS(config$output_paths$clean_data)

cat("\n=== NEURAL NETWORKS & BACKTESTING ===\n")

# 4. CRSP Calendar Anomalies
lm_week <- lm(ew ~ M + T + W + R + F - 1, data=data$returns_data)
ts_model_res <- auto.arima(residuals(lm_week))
cat("[1] CRSP Calendar Residuals ARIMA:", paste(ts_model_res$arma, collapse="-"), "\n")

# 5. GE Neural Networks
test_size <- config$params$nn_test_size
train_idx <- 1:(nrow(data$ge_dataset) - test_size)
train_data <- data$ge_dataset[train_idx, ]
test_data <- data$ge_dataset[-train_idx, ]

set.seed(config$params$nn_seed)
nn_321 <- nnet(rtn_t ~ rtn_t1 + rtn_t2 + rtn_t3, data=train_data, size=2, linout=TRUE, trace=FALSE)
preds_321 <- predict(nn_321, newdata=test_data)
mse_321 <- mean((test_data$rtn_t - preds_321)^2)

set.seed(config$params$nn_seed)
nn_651 <- nnet(drtn ~ rtn_t1 + rtn_t2 + rtn_t3 + sign_t1 + sign_t2 + sign_t3,
               data=train_data, size=5, linout=FALSE, trace=FALSE)
preds_651 <- predict(nn_651, newdata=test_data)
mse_651 <- mean((test_data$drtn - preds_651)^2)

cat("[2] GE Network MSE (Magnitude 3-2-1):", mse_321, "\n")
cat("[3] GE Network MSE (Direction 6-5-1):", mse_651, "\n")

# 6. FX Recursive Forecast
train_fx <- subset(data$fx_data, format(Date, "%Y") == config$params$fx_train_year)$Rate
test_fx <- subset(data$fx_data, format(Date, "%Y") == config$params$fx_test_year)$Rate

recursive_forecast <- function(p_train, p_test) {
  forecasts <- numeric(length(p_test))
  current_history <- p_train
  for(i in 1:length(p_test)) {
    returns_hist <- diff(log(current_history))
    fit <- arima(returns_hist, order=c(1,0,0), include.mean=FALSE)
    pred_return <- predict(fit, n.ahead=1)$pred[1]
    forecasts[i] <- tail(current_history, 1) * exp(pred_return + 0.5 * fit$sigma2)
    current_history <- c(current_history, p_test[i])
  }
  return(forecasts)
}

preds_fx <- recursive_forecast(train_fx, test_fx)
ssq_loss <- sum((test_fx - preds_fx)^2)
cat("[4] USD/EUR Recursive AR(1) SSQ Loss:", ssq_loss, "\n")