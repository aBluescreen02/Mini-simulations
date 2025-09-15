library(tidyverse)

# Probability of coin 1 and 2 being heads
p_1 <- 0.7
p_2 <- 0.3

max_t <- 250
n_sims <- 20

run_sim <- function(sim_id, max_t, p_1, p_2) {
  results <- data.frame(
    t = 1,
    prev_result = rbinom(1, 1, p_1)
  )
  
  # Iterative step
  for (i in 2:max_t) {
    new_result <- data.frame(
      t = i,
      prev_result = ifelse(tail(results$prev_result, 1) == 1, rbinom(1, 1, p_2), rbinom(1, 1, p_1)) # 1 = Heads, 0 = Tails
    )
    
    results <- rbind(results, new_result)
  }
  
  # Calculate probability of landing on heads at each step
  results <- results %>%
    mutate(p_heads = cumsum(prev_result) / t,
           sim_id = sim_id)
}

# Run simulations
all_results <- map_dfr(1:n_sims, ~ run_sim(.x, max_t, p_1, p_2))

# Plot the probability over time
ggplot(all_results, aes(x = t, y = p_heads, group = sim_id, color = factor(sim_id))) +
  geom_line(alpha = 0.7) +
  labs(title = "2-Weighted Coin Markov Chain", x = "Time", y = "Proportion of Heads", color = "Simulation") + 
  theme(legend.position = "none")
