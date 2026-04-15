library(tidyverse)

df <- read_rds('data_raw/rmny-v04.rds')
names(df)
df$x_teruleti_hungarikum

df_s1 <- df %>% 
  filter(
    bibliografiai_halmaz == 'RMNY'
    & x_teruleti_hungarikum == TRUE
    & x_fazis_01_esemeny == 'besorolás'
  ) %>% 
  rename(count = x_s2_letezo_peldanyok_szama) %>% 
  mutate(hypothetic = (is.na(count) | count == 0))
nrow(df2)
df_s1 %>% count(hypothetic) # 867
df_s1 %>% count(count == 0)
df_s1 %>% 
  filter(count > 0) %>% 
  select(count) %>% 
  write_csv("data_raw/v04/abundance/abundance-s1.csv")

df_s1 %>% 
  filter(count > 0) %>% 
  select(count) %>% 
  table() %>% as_tibble() %>% 
  write_csv("data_raw/v04/abundance/frequency-s1.csv")

df2 <- df %>% 
  filter(bibliografiai_halmaz == 'RMNY'
         & x_teruleti_hungarikum == TRUE
         & x_fazis_2024_esemeny == 'besorolás'
#         & x_s2_letezo_peldanyok_szama > 0
  ) %>% 
  rename(count = x_s2_letezo_peldanyok_szama) %>% 
  mutate(hypothetic = (is.na(count) | count == 0))
nrow(df2)

df2 %>% count(hypothetic) # 884
df2 %>% count(count == 0)

df2 %>% 
  filter(count > 0) %>% 
  select(count) %>% 
  write_csv("data_raw/v04/abundance/iti/abundance.csv")

df2 %>% 
  filter(count > 0) %>% 
  select(count) %>% 
  write_csv("data_raw/v04/abundance/abundance-s2.csv")

df2 %>% 
  filter(count > 0) %>% 
  select(count) %>% 
  table() %>% as_tibble() %>% 
  write_csv("data_raw/v04/abundance/frequency-s2.csv")

df2 %>% 
  filter(count > 0) %>% 
  filter(x_nyelvek %in% c('magyar', 'latin', 'német')) %>% 
  select(x_nyelvek, count) %>% 
  rename(nyelv = x_nyelvek) %>% 
  write_csv("data_raw/v04/abundance/iti/abundance-by-language.csv")

lang_stat <- df2 %>% 
  filter(x_nyelvek %in% c('magyar', 'latin', 'német')) %>% 
  select(is_hipothetical = hypothetic, x_nyelvek, count) %>% 
  count(x_nyelvek, is_hipothetical)
lang_stat
lang_stat %>%
  write_csv("data_raw/v04/abundance/iti/lang_stat.csv")
  
for (nyelv in c('magyar', 'latin', 'német')) {
  print(nyelv)
  df2 %>% 
    filter(x_nyelvek == nyelv) %>% 
    select(x_nyelvek, count) %>% 
    rename(nyelv = x_nyelvek) %>% 
    write_csv(sprintf("data_raw/v04/abundance/iti/lang_%s.csv", nyelv))
}

df2 %>% 
  select(x_kiadvanytipus, count) %>% 
  rename(genre = x_kiadvanytipus) %>% 
  mutate(genre = gsub(' kiadvány', '', genre)) %>% 
  write_csv("data_raw/v04/abundance/iti/abundance-by-genre.csv")

genres <- df2 %>% 
  select(x_kiadvanytipus, count) %>% 
  rename(genre = x_kiadvanytipus) %>% 
  mutate(genre = gsub(' kiadvány', '', genre)) %>%
  count(genre) %>%
  select(genre) %>% 
  unlist(use.names = FALSE)

genres

df2 %>% count(x_formatum, hypothetic)
df2 %>% count(x_formatum2, hypothetic)

df2 %>% filter(!is.na(x_formatum2)) %>% 
  filter(x_formatum != x_formatum2) %>% 
  select(id, formatum, x_formatum, x_formatum2) %>% 
  print(n = Inf)

df2 %>% 
  mutate(format = ifelse(x_formatum2 %in% c(1, 2, 4, 8),
                           paste0(as.character(x_formatum2), '°'),
                           'egyéb')) %>% 
  select(format, count) %>% 
  write_csv("data_raw/v04/abundance/iti/abundance-by-format.csv")

df2 %>% count(hypothetic)
df2 %>% count(count == 0)

format_stat <- df2 %>% 
  mutate(
    x_formatum2 = ifelse(is.na(x_formatum2), x_formatum, x_formatum2),
    format = ifelse(x_formatum2 %in% c(1, 2, 4, 8),
                         as.character(x_formatum2),
                         'egyéb')) %>%
  select(is_hipothetical = hypothetic, format) %>% 
  count(format, is_hipothetical) %>% 
  pivot_wider(names_from = format, values_from = n, values_fill = 0) %>% 
  pivot_longer(!is_hipothetical, names_to = 'format') %>% 
  arrange(format) %>% 
  select(format, is_hipothetical, n = value)

format_stat
format_stat %>% write_csv("data_raw/v04/abundance/iti/format_stat.csv")

for (format_name in c('1', '2', '4', '8', 'egyéb')) {
  df2 %>% 
    mutate(
      x_formatum2 = ifelse(is.na(x_formatum2), x_formatum, x_formatum2),
      format = ifelse(x_formatum2 %in% c(1, 2, 4, 8),
                           as.character(x_formatum2),
                           'egyéb')) %>% 
    filter(format == format_name) %>% 
    select(format, count) %>% 
    write_csv(
      sprintf("data_raw/v04/abundance/iti/format_%s.csv", format_name))
}

