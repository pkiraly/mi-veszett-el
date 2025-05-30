library(tidyverse)

df <- read_rds('data_raw/rmny-1-5.rds')
limit <- 50
df2 <- df %>% 
  filter(x_teruleti_hungarikum == TRUE) %>% 
  filter(!is.na(x_formatum2)) %>% 
  mutate(formatum = ifelse(x_formatum2 %in% c(1, 2, 4, 8),
                           paste0(as.character(x_formatum2), '°'),
                           'egyéb')) %>% 
  mutate(formatum = factor(formatum, levels = c('1°', '2°', '4°', '8°', 'egyéb')),
         peldanyszam = x_letezo_peldanyok_szama)

df2 %>% 
  select(formatum, peldanyszam) %>%
  group_by(formatum) %>% 
  summarise(n = sum(peldanyszam)) %>% 
  arrange(desc(n)) %>% 
  print(n = 20)

df2 %>% 
  select(formatum, peldanyszam) %>% 
  mutate(peldanyszam = ifelse(peldanyszam > limit, limit, peldanyszam)) %>% 
  ggplot(aes(x = peldanyszam)) +
  geom_histogram(bins = limit + 1, fill = 'cornflowerblue') +
  facet_wrap(vars(formatum), ncol = 1) +
  theme_bw() +
  labs(
    title = 'Fennmaradt példányok formátumokként',
    x = 'fennmaradt példányok száma',
    y = 'kötetszám'
  ) +
  scale_y_log10()

