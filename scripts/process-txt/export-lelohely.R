library(tidyverse)

df3 <- read_csv('data/rmny-1-3.v2.2024-02-12.csv', 
                col_types = cols(
                  `Tárgyi hungarikum` = col_character(),
                  `xTérkép-map` = col_character()
                )
        )
names(df3)
df3 %>% 
  select(id, `00Bibliográfia`, `01Sorszám_RMNY`, `01Sorszám_RMNY-S`, `13Lelöhely`, `13Lelöhely_count`, `15Olim`, `15Olim_count`) %>% 
  write_csv('data/rmny-1-3.lelohely.csv', na = '')
