library(tidyverse)

df <- read_csv('data/rmk_v01.csv')
counts <- df %>% 
  select(count = `Létező példányok`) %>% 
  filter(!is.na(count) & count > 0)

df %>% 
  select(count = `Létező példányok`) %>% 
  count(count == 0)

dirName <- 'data_raw/v03/abundance/'
counts %>% write_csv(sprintf('%s/%s_basis.csv', dirName, 'rmk'))
