# Main execution script for the State-Space and Neural Forecasting pipeline

cat("Starting Advanced Time Series & Machine Learning Pipeline...\n")

cat("\n--- Step 1: Data Extraction & Preparation (ETL) ---\n")
source("R/01_data_prep.R")

cat("\n--- Step 2: State-Space Modeling (Kalman Filters) ---\n")
source("R/02_state_space.R")

cat("\n--- Step 3: Neural Networks & Recursive Backtesting ---\n")
source("R/03_ml_and_backtest.R")

cat("\n====================================================\n")
cat("Pipeline execution finished successfully.\n")