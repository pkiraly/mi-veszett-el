library(tidyverse)

df <- read_rds('data_raw/rmny-1-5.rds')
limit <- 50
df2 <- df %>% 
  filter(x_teruleti_hungarikum == TRUE) %>% 
  filter(!is.na(x_nyelvek)) %>%
  mutate(peldanyszam = x_letezo_peldanyok_szama) %>% 
  mutate(x_nyelvek = ifelse(x_nyelvek == 'magyar # - latin', 'latin; magyar', x_nyelvek)) %>% 
  mutate(x_nyelvek = ifelse(x_nyelvek == 'latin # - magyar', 'latin; magyar', x_nyelvek)) %>% 
  mutate(x_nyelvek = ifelse(x_nyelvek == 'latin # - német', 'latin; német', x_nyelvek)) %>% 
  mutate(x_nyelvek = ifelse(x_nyelvek == 'görög # - latin', 'görög; latin', x_nyelvek)) %>% 
  mutate(x_nyelvek = ifelse(x_nyelvek == 'latin # - görög', 'görög; latin', x_nyelvek))

df2 %>% 
  select(x_nyelvek, peldanyszam) %>%
  group_by(x_nyelvek) %>% 
  summarise(n = sum(peldanyszam)) %>% 
  arrange(desc(n)) %>% 
  print(n = 20)

df2 %>% 
  select(x_nyelvek, peldanyszam) %>% 
  filter(x_nyelvek %in% c('latin',
                          'magyar',
                          'latin; magyar',
                          'latin; német',
                          'német',
                          'román'
                          #, 'biblikus cseh', 'cseh', 'görög'
                          )) %>% 
  mutate(peldanyszam = ifelse(peldanyszam > limit, limit, peldanyszam)) %>% 
  ggplot(aes(x = peldanyszam)) +
  geom_histogram(bins = limit + 1, fill = 'cornflowerblue') +
  facet_wrap(vars(x_nyelvek), ncol = 1) +
  theme_bw() +
  labs(
    title = 'Fennmaradt példányok nyelvenként',
    x = 'fennmaradt példányok száma',
    y = 'kötetszám'
  ) +
  scale_y_log10()
