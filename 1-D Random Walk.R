library(tidyverse)

# 1-D Discrete Random Walk #####

q <- 0.5 
p <- 0.5
r <- 1 - (q + p)
max_t <- 1000

steps <- sample(
  x = c(-1, 0, 1), 
  size = max_t, 
  replace = TRUE, 
  prob = c(q, r, p)
)

# Positions = cumulative sum of steps
positions <- c(0, cumsum(steps))

# Combine into results
results <- tibble(
  t = 0:max_t,
  x = positions
)

# Plot the walk
ggplot(results, aes(x = t, y = x)) +
  geom_line() +
  geom_point(size = 0.5) +
  labs(title = "1D Random Walk", x = "Time", y = "Position")
