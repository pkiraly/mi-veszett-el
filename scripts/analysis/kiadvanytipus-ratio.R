# a kiadványtípus arányainak változása

library(tidyverse)
library(slider)

df <- read_rds('data_raw/rmny-v03.rds')
names(df)

df2 <- df %>% 
  filter(bibliografiai_halmaz == 'RMNY' & x_teruleti_hungarikum == TRUE) %>% # 3520
  filter(x_fazis_2024_esemeny == 'besorolás') %>%  # 3504
  filter(!is.na(x_kiadvanytipus)) %>% 
  select(year = x_nyomtatasi_ev, x_kiadvanytipus) %>% 
  mutate(
    type = gsub(' kiadvány', '', x_kiadvanytipus),
    type = gsub(' működéshez kapcsolódó', '', type),
    #    x_nyomtatasi_ev = round(x_nyomtatasi_ev / year_window) * year_window,
  ) %>% 
  count(year, type)
df2

df3 <- df2 %>% 
  pivot_wider(names_from = type, values_from = n, values_fill = 0) %>% 
  pivot_longer(!year, names_to = "type", values_to = "n")

df3

year_window <- 4
statDF <- df3 %>% 
  group_by(year) %>% 
  mutate(
    yearly_total = sum(n),
    # perc = n / sum(n),
    # ss = slide_dbl(s, sum, .before = 1, .after = 1),
    # mova = slide_dbl(perc, mean, .before = 1, .after = 1),
  ) %>% 
  filter(year > 1500) %>% 
  ungroup() %>%
  arrange(type, year) %>% 
  group_by(type) %>% 
  reframe(
    year = year,
    yearly_total = yearly_total,
    n = n,
    cumulated_total = slide_dbl(
      yearly_total, sum,
      .before = year_window,
      .after = year_window
    ),
    cumulated_n = slide_dbl(
      n, sum,
      .before = year_window,
      .after = year_window
    ),
    p = cumulated_n * 100 / cumulated_total
  )
statDF
statDF %>% view()

statDF %>% 
  ggplot(aes(x = year,
             y = p,
             fill = type)) +
  geom_col() +
  labs(
    title = 'A kiadványtípusok arányainak változása',
    caption = 'forrás: RMNYStat, 2025',
    x = 'kiadás éve',
    y = 'százalékos arány',
    fill = "kiadványtípus",
  ) +
  theme_bw() + 
  theme(
#    panel.grid.major = element_blank(),
#    panel.grid.minor = element_blank(),
    text = element_text(size = 8),
    plot.title = element_text(size = 8),
    axis.text = element_text(colour = "#666666", size = 6),
    axis.text.x = element_text(
      angle = 45, hjust = 1, vjust = 1),
  )

ggsave('img/general/kiadvanytipus.png', 
       dpi = 300, width = 6, height = 3)


slide(1:5, ~.x)
slide(1:5, ~.x, .before = 1)

tibble(x = 1:5) %>% 
  mutate(
    y = slide_dbl(x, mean, .before = 2),
  )

# Library
library(ggstream)

blockbusters

ggplot(blockbusters, 
       aes(x = year, y = box_office, fill = genre)) +
  geom_stream(type = "proportional")

df4 <- df3 %>% 
  group_by(type) %>% 
  reframe(
    year = year,
    n = n,
    y = slide_dbl(
      n, mean,
      .before = year_window,
      .after = year_window
    ),
  ) %>% 
  filter(year > 1530)

# https://r-charts.com/evolution/ggstream/
ggplot(df4, 
       aes(x = year, y = y, fill = type)) +
  geom_stream(
    type = "proportional",
    bw = 0.001, 
    n_grid = 149,
    true_range = "both"
  ) +
  labs(
    title = 'A kiadványtípusok arányainak változása',
    caption = 'forrás: RMNYStat, 2025',
    x = 'kiadás éve',
    y = 'százalékos arány',
    fill = "kiadványtípus",
  ) +
  theme_bw() + 
  theme(
    #    panel.grid.major = element_blank(),
    #    panel.grid.minor = element_blank(),
    text = element_text(size = 8),
    plot.title = element_text(size = 8),
    axis.text = element_text(colour = "#666666", size = 6),
    axis.text.x = element_text(
      angle = 45, hjust = 1, vjust = 1),
  ) +
  scale_y_continuous(labels = seq(0, 100, 25))

ggsave('img/general/kiadvanytipus-stream.png', 
       dpi = 300, width = 6, height = 3)
