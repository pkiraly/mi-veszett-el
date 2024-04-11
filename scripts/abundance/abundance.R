library(tidyverse)

df <- read_rds('data_raw/rmny-1-5.rds')
names(df)
df$x_teruleti_hungarikum

df %>% 
  filter(x_teruleti_hungarikum == TRUE) %>% 
  mutate(x = x_letezo_peldanyok_szama > 0) %>% 
  count(x)

df %>% 
  filter(x_teruleti_hungarikum == TRUE) %>% 
  filter(x_letezo_peldanyok_szama > 0) %>%
  select(x_letezo_peldanyok_szama) %>% 
  rename(count = x_letezo_peldanyok_szama) %>% 
  write_csv("data_raw/abundance.csv")

df %>% 
  filter(x_teruleti_hungarikum == TRUE) %>% 
  filter(x_letezo_peldanyok_szama > 0) %>%
  filter(x_nyelvek %in% c('magyar', 'latin', 'német')) %>% 
  select(x_nyelvek, x_letezo_peldanyok_szama) %>% 
  rename(
    nyelv = x_nyelvek,
    count = x_letezo_peldanyok_szama
  ) %>% 
  write_csv("data_raw/abundance-by-language.csv")

df %>% 
  filter(x_teruleti_hungarikum == TRUE) %>% 
  filter(x_letezo_peldanyok_szama > 0) %>%
  select(x_kiadvanytipus, x_letezo_peldanyok_szama) %>% 
  rename(
    genre = x_kiadvanytipus,
    count = x_letezo_peldanyok_szama
  ) %>% 
  write_csv("data_raw/abundance-by-genre.csv")

df %>% 
  filter(x_teruleti_hungarikum == TRUE) %>% 
  filter(x_letezo_peldanyok_szama > 0) %>%
  mutate(format = ifelse(x_formatum2 %in% c(1, 2, 4, 8),
                           paste0(as.character(x_formatum2), '°'),
                           'egyéb')) %>% 
  select(format, x_letezo_peldanyok_szama) %>% 
  rename(
    count = x_letezo_peldanyok_szama
  ) %>% 
  write_csv("data_raw/abundance-by-format.csv")
