library(yaml)
config <- yaml.load_file("conf/config.yml")
dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)

# 1. Alcoa Volatility
alcoa_data <- read.table(config$data_paths$alcoa, header=FALSE)
log_vol <- log(alcoa_data$V1)

# 2. Pfizer CAPM
pfizer_sp <- read.table(config$data_paths$pfizer, header=TRUE)
r_p <- pfizer_sp[,1] * 100
r_m <- pfizer_sp[,2] * 100

# 3. U.S. PPI
ppi_data <- read.table(config$data_paths$ppi, header=TRUE)
Z_t <- ppi_data[,4]
z_t <- diff(log(Z_t))
y_t <- z_t - mean(z_t)

# 4. CRSP Calendar Effects
returns_data <- read.table(config$data_paths$crsp, header=TRUE)

# 5. GE Neural Nets (Lags & Signs)
ge_data <- read.table(config$data_paths$ge, header=TRUE)
rtn <- ge_data[,1]
n <- length(rtn)
ge_dataset <- data.frame(
  rtn_t = rtn[4:n], rtn_t1 = rtn[3:(n-1)],
  rtn_t2 = rtn[2:(n-2)], rtn_t3 = rtn[1:(n-3)]
)
ge_dataset$drtn <- ifelse(ge_dataset$rtn_t > 0, 1, 0)
ge_dataset$sign_t1 <- ifelse(ge_dataset$rtn_t1 > 0, 1, -1)
ge_dataset$sign_t2 <- ifelse(ge_dataset$rtn_t2 > 0, 1, -1)
ge_dataset$sign_t3 <- ifelse(ge_dataset$rtn_t3 > 0, 1, -1)

# 6. USD/EUR FX
fx_data <- read.csv(config$data_paths$fx)
fx_data$Date <- as.Date(fx_data$End.Date)
fx_data$Rate <- fx_data$USD.EUR
fx_data <- fx_data[order(fx_data$Date), ]

saveRDS(list(log_vol=log_vol, r_p=r_p, r_m=r_m, y_t=y_t,
             returns_data=returns_data, ge_dataset=ge_dataset, fx_data=fx_data),
        file = config$output_paths$clean_data)
cat("ETL Complete. Clean data saved.\n")