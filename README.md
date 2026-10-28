# Advanced Time Series: State-Space Models & Neural Forecasting

![R 4.4+](https://img.shields.io/badge/R-4.4+-276DC3?style=flat-square&logo=r&logoColor=white) ![Time Series](https://img.shields.io/badge/Time_Series-State_Space%20%7C%20Kalman_Filter-blue?style=flat-square) ![Machine Learning](https://img.shields.io/badge/Machine_Learning-Neural_Networks-success?style=flat-square) ![renv](https://img.shields.io/badge/renv-environment_manager-purple?style=flat-square)

📄 [Read the full Research Whitepaper (PDF)](docs/state_space_neural_whitepaper.pdf)

## 1. Abstract & Objective

This repository contains a production-ready data science pipeline focused on advanced time series forecasting. The objective is to move beyond standard linear regressions by implementing dynamic state-space models (filtering unobserved states from noisy data) and artificial neural networks (capturing non-linear predictive relationships). 

The research evaluates structural volatility in Alcoa stock, time-varying systemic risk (CAPM) for Pfizer, macroeconomic signal extraction from U.S. PPI inflation, and non-linear directional forecasting for GE.

## 2. System Architecture & Data Pipeline

The project is structured as a decoupled machine learning pipeline:

*   **`conf/config.yml`**: Centralized configuration for seed management, hyperparameters, and dynamic data routing.
*   **`R/01_data_prep.R` (ETL)**: Processes raw macroeconomic and financial data, applying necessary transformations (logarithmic scaling, first-differencing) and caching clean structures.
*   **`R/02_state_space.R` (Kalman Filters)**: Fits local trend models and time-varying linear regressions using Maximum Likelihood Estimation (MLE) to extract unobserved state variances.
*   **`R/03_ml_and_backtest.R` (Neural Nets & Simulation)**: Trains feed-forward neural networks (3-2-1 for magnitude, 6-5-1 for directional classification) and evaluates a recursive out-of-sample trading backtest on USD/EUR exchange rates.

## 3. Mathematical Highlights

*   **State-Space Volatility Filtering:** The underlying structural trend is extracted via observation and state equations:

    $$y_t = \mu_t + e_t, \quad e_t \sim N(0, \sigma_e^2)$$

    $$\mu_{t+1} = \mu_t + \eta_t, \quad \eta_t \sim N(0, \sigma_\eta^2)$$

*   **Time-Varying CAPM Specification:** 

    $$r_{p,t} = \alpha_t + \beta_t r_{M,t} + \epsilon_t$$

    $$\alpha_{t+1} = \alpha_t + \eta_{1,t}, \quad \beta_{t+1} = \beta_t + \eta_{2,t}$$

*   **Neural Network Non-Linearity:** Utilized a logistic activation function (classification) and linear output (regression) to capture asymmetric market sentiment responses.

## 4. Quick Start

This project uses `renv` for strict, reproducible environment management.

```bash
# Clone the repository
git clone https://github.com/Pavelpuff/state-space-neural-forecasting.git
cd state-space-neural-forecasting

# Open the R console and restore the exact package versions
Rscript -e 'renv::restore()'

# Execute the full end-to-end data pipeline
Rscript main.R
```