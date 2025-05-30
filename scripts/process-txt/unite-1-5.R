# data/rmny-1-3.with-cities.csv --> data/rmny-1-3.with-cities.with-ivszam.csv
# data/rmny4.csv                --> data/rmny4.with-ivszam.csv
# data/rmny5.csv                --> data/rmny5.with-ivszam.csv
library(tidyverse)

df3 <- read_csv('data/rmny-1-3.with-cities.with-ivszam.csv',
                col_types = cols(
                  `Tárgyi hungarikum` = col_character(),
                  `xTérkép-map` = col_character()
                ),
                show_col_types = FALSE
)
df4 <- read_csv('data/rmny4.with-ivszam.csv',
                col_types = cols(
                  `01xIdö` = col_character(),
                  `14Facsimile` = col_character()))
df5 <- read_csv('data/rmny5.with-ivszam.csv',
                col_types = cols(
                  `01xIdö` = col_character(),
                  `14Facsimile` = col_character()))

bind_rows(df3, df4, df5) %>% 
  write_csv('data/rmny-1-5.csv', na = '')
