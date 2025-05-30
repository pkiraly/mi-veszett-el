library(tidyverse)
library(zoo)

df <- read_csv('data/rmny-1-5.csv',
               col_types = cols(
                 `Tárgyi hungarikum` = col_character(),
                 `xTérkép-map` = col_character()
               ))
names(df)
df_clean <- df %>% 
  select(`01xIdö`, `16Nyelv`) %>% 
  mutate(
    year = `01xIdö`,
    lang = str_remove_all(`16Nyelv`, ' #'),
    lang = str_replace_all(lang, ' - ', '; '),
    lang = str_replace_all(lang, '\\[\\?\\]', ''),
    lang = str_replace_all(lang, '\\?', ''),
  ) %>% 
  filter(!is.na(year) & !is.na(lang)) %>% 
  filter(!str_detect(lang, '; ')) %>% 
  filter(!str_detect(lang, 'többnyelvű')) %>% 
  filter(!str_detect(lang, 'egyéb')) %>% 
  filter(str_detect(year, '^\\d+$')) %>%
  mutate(year = as.numeric(year)) %>% 
  select(year, lang)

years <- df_clean %>% 
  count(year)
    
top_langs <- df_clean %>%
  count(lang) %>% 
  filter(n > 10) %>% 
  arrange(desc(n)) %>% 
  pull(lang) %>% 
  head(6)

top_langs

df2 <- df_clean %>%
  filter(lang %in% top_langs) %>% 
  filter(year > 1525) %>% 
  group_by(year, lang) %>% 
  summarise(lang_n = n()) %>% 
  left_join(years, join_by(year)) %>% 
  mutate(perc = lang_n / n) %>% 
  ungroup() %>% 
  group_by(lang) %>% 
  mutate(
    roll = rollapply(
      perc, 
      width=3, mean, align='right', fill=0))

df2 %>% 
  ggplot(aes(x = year, y = roll, color = lang)) +
  geom_line() +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1))
  )
  
