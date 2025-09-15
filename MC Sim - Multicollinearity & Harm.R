# Monte Carlo Simulation: Multicollinearity & Harm

library(tidyverse)
library(MASS)
library(ggplot2)

cor2cov <- function(cor_matrix, sd_vector) {
  D <- diag(sd_vector)
  D %*% cor_matrix %*% D
}

results = expand.grid(
  rho = seq(0, 0.95, 0.05),
  rep = 1:1000
) %>%
  mutate(
    sim = map(rho, function(p) {
      set.seed(runif(1, 1, 10000) %>% ceiling)
      
      R = matrix(c(1, p, p, 1), nrow = 2, ncol = 2, byrow = TRUE)
      Sigma = cor2cov(R, c(1, 1))
      
      data = MASS::mvrnorm(n = 30, mu = c(0, 0), Sigma = Sigma) %>%
        as_tibble %>%
        mutate(Y = 1 + 0.5 * V1 + 0.5 * V2 + rnorm(30))
      
      model = lm(Y ~ V1 + V2, data = data)
      
      summary(model)$coefficients %>% 
        as_tibble(rownames = "term")
    })
  )

# Estimated coefficient means 
avg_estimates <- results %>%
  unnest(sim) %>%
  group_by(rho, term) %>%
  summarise(mean_estimate = mean(Estimate), .groups = "drop")

ggplot(avg_estimates, aes(x = rho, y = mean_estimate, color = term)) +
  geom_line(size = 1) +
  labs(
    title = "Average Estimated Coefficients vs Correlation (rho)",
    x = "Correlation between X1 and X2 (rho)",
    y = "Average Estimate",
    color = "Coefficient"
  ) +
  theme_minimal()

# Estimated coefficient standard errors
avg_standard_error <- results %>%
  unnest(sim) %>%
  group_by(rho, term) %>%
  summarise(mean_standard_error = mean(`Std. Error`), .groups = "drop")

ggplot(avg_standard_error, aes(x = rho, y = mean_standard_error, color = term)) +
  geom_line(size = 1) +
  labs(
    title = "Average Estimated Coefficients vs Correlation (rho)",
    x = "Correlation between X1 and X2 (rho)",
    y = "Average Estimate",
    color = "Coefficient"
  ) +
  theme_minimal()
