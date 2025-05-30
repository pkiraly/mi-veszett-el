library(tidyverse)

df <- read_rds('data_raw/rmny-1-5.rds')
limit <- 50
df2 <- df %>% 
  filter(x_teruleti_hungarikum == TRUE) %>% 
  filter(!is.na(x_kiadvanytipus)) %>% 
  mutate(
    mufaj = x_kiadvanytipus,
    peldanyszam = x_letezo_peldanyok_szama
  )

mufajok <- df2 %>% 
  select(mufaj, peldanyszam) %>%
  group_by(mufaj) %>% 
  summarise(n = sum(peldanyszam)) %>% 
  arrange(desc(n)) %>% 
  pull(mufaj)

df2 %>% 
  mutate(mufaj = factor(mufaj, levels = mufajok)) %>% 
  select(mufaj, peldanyszam) %>% 
  mutate(peldanyszam = ifelse(peldanyszam > limit, limit, peldanyszam)) %>% 
  ggplot(aes(x = peldanyszam)) +
  geom_histogram(bins = limit + 1, fill = 'cornflowerblue') +
  facet_wrap(vars(mufaj), ncol = 1) +
  theme_bw() +
  labs(
    title = 'Fennmaradt példányok kiadványtípusonként',
    x = 'fennmaradt példányok száma',
    y = 'kötetszám'
  ) +
  scale_y_log10()
