# a nyelvek és formátumok arányainak változása

library(tidyverse)
library(slider)
library(ggstream)
library(ggthemes)


df <- read_rds('data_raw/rmny-v03.rds')

languages <- c(#'biblikus cseh', 'cseh', 'görög', 'román', 'ó-egyházi-szláv',
  'latin', 'magyar', 'német', 'többnyelvű')
formats <- c(1, 2, 4, 8, 12)

df2 <- df %>% filter(bibliografiai_halmaz == 'RMNY' & x_teruleti_hungarikum == TRUE) %>% 
  filter(x_fazis_2024_esemeny == 'besorolás') %>% 
  select(year = x_nyomtatasi_ev, x_nyelvek, x_formatum) %>% 
  mutate(
    x_formatum = ifelse(is.na(x_formatum) | x_formatum %in% formats, x_formatum, '12+'),
    x_formatum = factor(x_formatum, levels = c(1, 2, 4, 8, 12, "12+")),
    x_nyelvek = ifelse(grepl('(; | - |, |, )', x_nyelvek), "többnyelvű", x_nyelvek),
    x_nyelvek = ifelse(x_nyelvek == 'ó-egyházi szláv', 'ó-egyházi-szláv', x_nyelvek),
    x_nyelvek = ifelse(x_nyelvek == 'cseh[?]', 'cseh', x_nyelvek),
    x_nyelvek = ifelse(x_nyelvek == 'magyar?', 'magyar', x_nyelvek),
    x_nyelvek = ifelse(x_nyelvek == 'többnyelvű (25)', 'többnyelvű', x_nyelvek),
    x_nyelvek = ifelse(is.na(x_nyelvek) | x_nyelvek %in% languages, x_nyelvek, 'egyéb'),
    x_nyelvek = factor(x_nyelvek, levels = c('magyar', 'latin', 'német', 'többnyelvű', 'egyéb')),
  )

df2

df_nyelv <- df2 %>% 
  count(year, x_nyelvek) %>% 
  pivot_wider(names_from = x_nyelvek, values_from = n, values_fill = 0) %>% 
  pivot_longer(!year, names_to = "type", values_to = "n") %>% 
  filter(year > 1530)

df3
ggplot(df_nyelv, 
       aes(x = year, y = n, fill = type)) +
  geom_stream(
    type = "proportional", # ridge, mirror
    bw = 0.1, 
    n_grid = 1000,
    true_range = "both"
  ) +
  labs(
    title = 'A kiadványtípusok arányainak változása',
    caption = 'forrás: RMNYStat, 2025',
    x = 'kiadás éve',
    y = 'százalékos arány',
    fill = "nyelv",
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

df_formatum <- df2 %>% 
  count(year, x_formatum) %>% 
  pivot_wider(names_from = x_formatum, values_from = n, values_fill = 0) %>% 
  pivot_longer(!year, names_to = "type", values_to = "n") %>% 
  filter(year > 1530)

ggplot(df_formatum, 
       aes(x = year, y = n, fill = type)) +
  geom_stream(
    type = "proportional", # ridge, mirror
    bw = 0.1, 
    n_grid = 1000,
    true_range = "both"
  ) +
  labs(
    title = 'A formátumok arányainak változása',
    caption = 'forrás: RMNYStat, 2025',
    x = 'kiadás éve',
    y = 'százalékos arány',
    fill = "formátum",
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

df3 <- df2 %>% 
  filter(year >= 1530) %>% 
  count(year, x_formatum, x_nyelvek) %>% 
  pivot_wider(names_from = x_formatum, values_from = n, values_fill = 0) %>% 
  pivot_longer(cols = !c(year, x_nyelvek), names_to = "format", values_to = "n") %>% 
  pivot_wider(names_from = x_nyelvek, values_from = n, values_fill = 0) %>% 
  pivot_longer(cols = !c(year, format), names_to = "language", values_to = "n")

nyelvek <- df2 %>% count(x_nyelvek) %>% pull(x_nyelvek)

df3$format <- factor(df3$format, levels = c(1, 2, 4, 8, 12, "12+", NA))
df3$language <- factor(df3$language, levels = nyelvek)
df3$language

volume_separator <- "grey"
df3 %>%
  filter(!is.na(language) & format != '1') %>% 
  ggplot(aes(x = year, y = n, fill = format)) +
  annotate("text", x = 1530, label = 'I.', y = 11, color = volume_separator, hjust = 0, size = 1.5) +
  annotate("text", x = 1601, label = 'II.', y = 11, color = volume_separator, hjust = 0, size = 1.5) +
  annotate("text", x = 1636, label = 'III.', y = 11, color = volume_separator, hjust = 0, size = 1.5) +
  annotate("text", x = 1656, label = 'IV.', y = 11, color = volume_separator, hjust = 0, size = 1.5) +
  annotate("text", x = 1671, label = 'V.', y = 11, color = volume_separator, hjust = 0, size = 1.5) +
  geom_stream(
    type = "mirror", # proportional, ridge, mirror
    bw = 0.65, # the average of a time window
    # n_grid = 1000,
    true_range = "both"
  ) +
  geom_vline(xintercept = 1601, color = volume_separator, alpha = 0.3, linewidth = 0.2) +
  geom_vline(xintercept = 1636, color = volume_separator, alpha = 0.3, linewidth = 0.2) +
  geom_vline(xintercept = 1656, color = volume_separator, alpha = 0.3, linewidth = 0.2) +
  geom_vline(xintercept = 1671, color = volume_separator, alpha = 0.3, linewidth = 0.2) +
  facet_wrap(~ language) +
  labs(
    title = 'A területi hungarikumok formátum-arányainak változása nyelvenként',
    subtitle = 'A római számok és függőleges vonalak az RMNY kötetek időhatárát jelölik',
    caption = 'forrás: RMNYStat, 2025',
    x = 'kiadás éve',
    y = 'kiadványok száma (többéves átlag)',
    # y = 'százalékos arány',
    fill = "formátum",
  ) +
  ylim(c(-11, 11)) +
  # theme_minimal() + 
  theme_economist() +
  # scale_color_economist() +
  
  theme(
    plot.background = element_rect(fill = 'white', color = 'white'),
    panel.background = element_rect(fill = 'white', color = 'white'),
    strip.text = element_text(margin = margin(b = 1), hjust = 0, size = 5),
    panel.grid.major = element_line(size = 0.05, color = 'grey'),
    panel.grid.minor = element_blank(),
    text = element_text(size = 6),
    legend.title = element_text(size = 5),
    legend.text = element_text(size = 5),
    # plot.title = element_text(size = 8),
    axis.text = element_text(colour = "#666666", size = 4),
    axis.text.x = element_text(angle = 45, hjust = 0.5, vjust = 1, margin = margin(5, 0, 0, 0)),
    axis.ticks = element_line(color = 'grey', linewidth = 0.2),
    axis.line = element_line(color = 'grey', linewidth = 0.2),
    axis.title.y = element_text(vjust = 1, margin = margin(r = 5)),
    axis.text.y = element_text(hjust = 1),
  ) +
  scale_x_continuous(
    # limits = c(0, 1.0),
    breaks = seq(1500, 1700, 20),
  )

# scale_y_continuous(
    # limits = c(0, 1.0),
  #  breaks = seq(0, 1, .1),
   # labels = seq(0, 100, 10),
#  ) +

ggsave('img/general/formatum-per-nyelv-stream.png', 
         dpi = 300, width = 6, height = 4)

