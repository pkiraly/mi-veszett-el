library(tidyverse)

df <- read_tsv('data_raw/rmny-1-5.tsv')

foreign_cities <- c('Velence', 'Amszterdam', 'Frankfurt am Main', 'Bázel', 'Lyon')

top12 <- df %>% 
  select(x_nyomtatasi_hely, ivszam) %>% 
  filter(!is.na(x_nyomtatasi_hely)) %>% 
  filter(!(x_nyomtatasi_hely %in% foreign_cities)) %>% 
  group_by(x_nyomtatasi_hely) %>% 
  summarise(
    db = n(),
    iv = sum(ivszam, na.rm = TRUE)
  ) %>% 
  arrange(desc(iv)) %>% 
  head(n = 12) %>% 
  select(x_nyomtatasi_hely)

hely <- factor(top12$x_nyomtatasi_hely, levels = top12$x_nyomtatasi_hely)

df %>% 
  filter(ivszam <= 2) %>% 
  right_join(top12, join_by(x_nyomtatasi_hely)) %>%
  mutate(hely = factor(x_nyomtatasi_hely, levels = hely)) %>% 
  ggplot(aes(x = ivszam)) +
  geom_histogram(bin = 30, color = 'cornflowerblue') +
  facet_wrap(~hely) +
  # scale_x_sqrt() +
  # scale_y_sqrt() +
  theme_bw() +
  labs(
    title = 'kisebb nyomtatványok',
    subtitle = '1472-1685 (RMNY 1-5.)',
    x = 'ívszám',
    y = 'nyomtatványszám'
  )

df

df %>% 
  filter(ivszam > 100) %>% 
  right_join(top12, join_by(x_nyomtatasi_hely)) %>%
  mutate(
    ido = as.numeric(x_nyomtatasi_ev),
    hely = factor(x_nyomtatasi_hely, levels = hely)
  ) %>% 
  group_by(hely, ido) %>% 
  summarise(
    ivszam = sum(ivszam, na.rm = TRUE),
    .groups = 'drop'
  ) %>% 
  ggplot(aes(y = ivszam, x = ido)) +
  geom_point(color = 'cornflowerblue', alpha = 0.8) +
  # geom_histogram(bin = 30, color = 'cornflowerblue') +
  facet_wrap(~hely)

