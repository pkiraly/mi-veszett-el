library(tidyverse)

df <- read_rds('data_raw/rmny-1-5.rds')
limit <- 50
df2 <- df %>% 
  filter(x_teruleti_hungarikum == TRUE) %>% 
  filter(!is.na(ivszam)) %>% 
  filter(ivszam > 0) %>% 
  mutate(peldanyszam = x_letezo_peldanyok_szama)

df2 %>% 
  mutate(ivszam = ceiling(ivszam)) %>% 
  mutate(ivszam = 
        ifelse(ivszam <= 5, '1-5',
        ifelse(ivszam > 5 & ivszam <= 10, '6-10',
        ifelse(ivszam > 10 & ivszam <= 15, '11-15', 
        ifelse(ivszam > 15 & ivszam <= 20, '16-20', 
        ifelse(ivszam > 20 & ivszam <= 25, '21-25', 
        ifelse(ivszam > 25 & ivszam <= 30, '26-30', 
        ifelse(ivszam > 30 & ivszam <= 35, '31-35', 
                      'egyéb')
           ))))))
         ) %>% 
  mutate(ivszam = factor(
    ivszam,
    levels = c('1-5', '6-10', '11-15', '16-20', '21-25', '26-30',
               '31-35', 'egyéb'))) %>% 
  select(ivszam, peldanyszam) %>% 
  mutate(peldanyszam = ifelse(peldanyszam > limit, limit, peldanyszam)) %>% 
  ggplot(aes(x = peldanyszam)) +
  geom_histogram(bins = limit + 1, fill = 'cornflowerblue') +
  facet_wrap(vars(ivszam), ncol = 1) +
  theme_bw() +
  labs(
    title = 'Fennmaradt példányok ívméret szerint',
    x = 'fennmaradt példányok száma',
    y = 'kötetszám'
  ) +
  scale_y_log10()

