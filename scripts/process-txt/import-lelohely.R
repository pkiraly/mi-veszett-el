library(tidyverse)

df3 <- read_csv(
  'data/rmny-1-3.v2.2024-02-12.csv',
  col_types = cols(
    `Tárgyi hungarikum` = col_character(),
    `xTérkép-map` = col_character()
  )
)
df_with_id <- df3 %>% 
  mutate(
    id2 = ifelse(
      is.na(`01Sorszám_RMNY-S`),
      paste(id, `00Bibliográfia`, `01Sorszám_RMNY`, sep = '|'),
      paste(id, `00Bibliográfia`, `01Sorszám_RMNY`, `01Sorszám_RMNY-S`, sep = '|')
    )
  )

df_with_id %>% count(id2) %>% filter(n > 1)

cities <- read_csv('data/rmny-1-3.lelohely2cities.csv')
cities <- cities %>% 
  mutate(
    id2 = ifelse(
      is.na(`01Sorszám_RMNY-S`),
      paste(id, `00Bibliográfia`, `01Sorszám_RMNY`, sep = '|'),
      paste(id, `00Bibliográfia`, `01Sorszám_RMNY`, `01Sorszám_RMNY-S`, sep = '|')
    )
  ) %>% 
  select(id2, cities, olimCities)
cities %>% count(id2) %>% filter(n > 1)

joined <- df_with_id %>% 
  left_join(cities, join_by(id2)) %>% 
  select(-id2) %>% 
  relocate(cities, .before = `15Olim`) %>% 
  relocate(olimCities, .after = `15Olim_count`)
names(joined)

write_csv(joined, 'data/rmny-1-3.with-cities.csv', na = '')
