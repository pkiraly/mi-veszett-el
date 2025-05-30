library(tidyverse)

df <- read_rds('data_raw/rmny-1-5.rds')
limit <- 50
helyek <- c('Kolozsvár', 'Lőcse', 'Debrecen', 'Nagyszombat', 'Pozsony', 'Várad', 'Kassa')
df2 <- df %>% 
  filter(x_teruleti_hungarikum == TRUE) %>% 
  filter(!is.na(x_nyomtatasi_hely)) %>% 
  mutate(hely = x_nyomtatasi_hely,
         peldanyszam = x_letezo_peldanyok_szama
  )

df2 %>% 
  select(hely, peldanyszam) %>%
  group_by(hely) %>% 
  summarise(n = sum(peldanyszam)) %>% 
  arrange(desc(n)) %>% 
  print(n = 20)

df2 %>% 
  filter(hely %in% helyek) %>% 
  mutate(hely = factor(hely, levels = helyek)) %>% 
  select(hely, peldanyszam) %>% 
  mutate(peldanyszam = ifelse(peldanyszam > limit, limit, peldanyszam)) %>% 
  ggplot(aes(x = peldanyszam)) +
  geom_histogram(bins = limit + 1, fill = 'cornflowerblue') +
  facet_wrap(vars(hely), ncol = 1) +
  theme_bw() +
  labs(
    title = 'Fennmaradt példányok nyomtatási helyenként',
    x = 'fennmaradt példányok száma',
    y = 'kötetszám'
  ) +
  scale_y_log10()

