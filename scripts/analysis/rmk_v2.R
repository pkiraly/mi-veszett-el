library(tidyverse)

df <- read_tsv('data_raw/v04/RMK_v02.tsv')
names(df) <- c("id", "bibliografiai_halmaz", "sorszam", "x_letezo_peldanyok", "olim", "x_teruleti_hungarikum", "x_nyelvi_hungarikum", "f8", "f9", "f10", "f11", "f12")

# df$f12[!is.na(df$f12)]

df2 <- df %>% 
  select(-c(f8, f9, f10, f11, f12)) %>% 
  mutate(
    x_teruleti_hungarikum = ifelse(is.na(x_teruleti_hungarikum), FALSE, ifelse(x_teruleti_hungarikum == "x", TRUE, FALSE)),
    x_nyelvi_hungarikum = ifelse(is.na(x_nyelvi_hungarikum), FALSE, ifelse(x_nyelvi_hungarikum == "x", TRUE, FALSE)),
  ) %>% 
  filter(x_teruleti_hungarikum == TRUE)

summary(df2)

counts <- df2 %>% 
  select(count = `x_letezo_peldanyok`) %>% 
  filter(!is.na(count) & count > 0)

df2 %>% 
  count(van_peldany = !is.na(x_letezo_peldanyok) & x_letezo_peldanyok > 0)

# van_peldany     n
# <lgl>       <int>
# FALSE         122
# TRUE          520
counts

df2 %>% 
  select(count = `x_letezo_peldanyok`) %>% 
  count(count == 0)

dirName <- 'data_raw/v04/abundance/'
counts %>% write_csv(sprintf('%s/%s_basis.csv', dirName, 'rmk'))
