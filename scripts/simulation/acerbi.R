#' Acerbi
#' https://acerbialberto.com/IBM-cultevo/unbiased-transmission.html#plotting-the-model-results

N <- 100
t_max <- 200

library(tidyverse)
population <- tibble(
  trait = sample(c("A", "B"), N, replace = TRUE)
)
population %>% count(trait)

output <- tibble(generation = 1:t_max, p = rep(NA, t_max))
output
output$p[1] <- sum(population$trait == "A") / N

for (t in 2:t_max) {
  previous_population <- population
  population <- tibble(
    trait = sample(previous_population$trait, N, replace = TRUE)
  )
  output$p[t] <- sum(population$trait == "A") / N
}
output

ggplot(data = output, aes(y = p, x = generation)) +
  geom_line() +
  ylim(c(0, 1)) +
  theme_bw() +
  labs(y = "p (proportion of individual with trait A)")

#' 1.4 Write a function to wrap the model code
unbiased_transmission_1 <- function(N, t_max) {
  population <- tibble(trait = sample(c("A", "B"), N, replace = TRUE))
  output <- tibble(generation = 1:t_max, p = rep(NA, t_max))
  output$p[1] <- sum(population$trait == "A") / N
  for (t in 2:t_max) {
    # Copy individuals to previous_population tibble
    previous_population <- population 
    
    # Randomly copy from previous generation
    population <- tibble(trait = sample(previous_population$trait, N, replace = TRUE))
    
    # Get p and put it into output slot for this generation t
    output$p[t] <- sum(population$trait == "A") / N 
  }
  # Export data from function
  output
}

data_model <- unbiased_transmission_1(N = 100, t_max = 200)

plot_single_run <- function(data_model) {
  ggplot(data = data_model, aes(y = p, x = generation)) +
    geom_line() +
    ylim(c(0, 1)) +
    theme_bw() +
    labs(y = "p (proportion of individuals with trait A)")
}

plot_single_run(data_model)

data_model <- unbiased_transmission_1(N = 10000, t_max = 200)
plot_single_run(data_model)

#' 1.5 Run several independent simulations and plot their results
#' 

unbiased_transmission_2 <- function(N, t_max, r_max) {
  output <- tibble(
    generation = rep(1:t_max, r_max), 
    p          = as.numeric(rep(NA, t_max * r_max)), 
    run        = as.factor(rep(1:r_max, each = t_max))
  )
  # For each run
  for (r in 1:r_max) { 
    # Create first generation
    population <- tibble(trait = sample(c("A", "B"), N, replace = TRUE))
    
    # Add first generation's p for run r
    output[output$generation == 1 & output$run == r, ]$p <-
      sum(population$trait == "A") / N 
    
    # For each generation
    for (t in 2:t_max) {
      # Copy individuals to previous_population tibble
      previous_population <- population 
      
      # Randomly copy from previous generation
      population <- tibble(trait = sample(previous_population$trait, N, replace = TRUE))
      
      # Get p and put it into output slot for this generation t and run r
      output[output$generation == t & output$run == r, ]$p <- 
        sum(population$trait == "A") / N 
    }
  }
  # Export data from function
  output 
}

plot_multiple_runs <- function(data_model) {
  ggplot(data = data_model, aes(y = p, x = generation)) +
    geom_line(aes(colour = run)) +
    stat_summary(fun = mean, geom = "line", size = 1) +
    ylim(c(0, 1)) +
    theme_bw() +
    labs(y = "p (proportion of individuals with trait A)")
}

data_model <- unbiased_transmission_2(N = 100, t_max = 200, r_max = 5)
plot_multiple_runs(data_model)

data_model

data_model <- unbiased_transmission_2(N = 10000, t_max = 200, r_max = 5)
plot_multiple_runs(data_model)

#' 1.6 Varying initial conditions
#' 
unbiased_transmission_3 <- function(N, p_0, t_max, r_max) {
  output <- tibble(generation = rep(1:t_max, r_max), 
                   p = as.numeric(rep(NA, t_max * r_max)), 
                   run = as.factor(rep(1:r_max, each = t_max)))
  # For each run
  for (r in 1:r_max) {
    # Create first generation
    population <- tibble(trait = sample(c("A", "B"), N, replace = TRUE, 
                                        prob = c(p_0, 1 - p_0)))
    
    # Add first generation's p for run r
    output[output$generation == 1 & output$run == r, ]$p <- 
      sum(population$trait == "A") / N 
    for (t in 2:t_max) {
      # Copy individuals to previous_population tibble
      previous_population <- population 
      
      # Randomly copy from previous generation
      population <- tibble(trait = sample(previous_population$trait, N, replace = TRUE))
      
      # Get p and put it into output slot for this generation t and run r
      output[output$generation == t & output$run == r, ]$p <- 
        sum(population$trait == "A") / N  
    }
  }
  # Export data from function
  output 
}

data_model <- unbiased_transmission_3(N = 10000, p_0 = 0.2, t_max = 200, r_max = 5)
plot_multiple_runs(data_model)
