library(tidyverse)

df <- read_csv('~/temp/rmny.csv')
df %>% select('13Lelöhely_count', '15Olim_count') %>%
  mutate(count = `13Lelöhely_count` + `15Olim_count`) %>% 
  filter(count < 50) %>% 
  ggplot(aes(x = count)) +
  geom_bar() +
  theme_bw() +
  labs(title = 'RMNY I-III. fennmaradt vagy adatolható egykori példányai') +
  ylab('nyomtatványok száma') +
  xlab('példányok száma')

ggsave('~/temp/rmny.png', width=10, height=6, 
       units = "in", dpi=300)
