library(tidyverse)

title <- 'nyelvek'
title_en <- 'languages'

hypothetic <- read_csv("data_raw/hypothetic-by-language.csv")
hypothetic
df <- tribble(
  ~method,~value,~empirical,~richness,~min,~max,
  "chao1","latin",1105,1740.49,1684.09,1806.39,
  "ichao1","latin",1105,1879.67,1805.01,1969.31,
  "ace","latin",1105,1624.51,1551.53,1679.17,
  "jackknife","latin",1105,2282.00,2025.70,2538.30,
  "egghe_proot","latin",1105,2075.93,1904.26,2243.07,
  "chao1","magyar",1355,1789.57,1742.97,1889.85,
  "ichao1","magyar",1355,1894.90,1788.08,1982.08,
  "ace","magyar",1355,1745.14,1700.75,1775.89,
  "jackknife","magyar",1355,2138.00,1973.08,2302.92,
  "egghe_proot","magyar",1355,2094.57,1922.73,2324.64,
  "chao1","német",225,486.72,443.27,517.41,
  "ichao1","német",225,514.95,433.47,597.20,
  "ace","német",225,524.20,439.21,628.07,
  "jackknife","német",225,546.00,459.05,632.95,
  "egghe_proot","német",225,533.23,418.90,645.51
)

languages <- tribble(
  ~hungarian, ~english,
  "latin",    "Latin",
  "magyar",   "Hungarian",
  "német",    "German",
)

df <- df %>% 
  left_join(languages, join_by(value == hungarian)) %>% 
  select(-value) %>% 
  rename(value = english)

hypothetic <- hypothetic %>% 
  left_join(languages, join_by(value == hungarian)) %>% 
  select(-value) %>% 
  rename(value = english)

df <- df %>% 
  mutate(
    key = paste(method, value, sep = "-"),
    method = factor(df$method, levels = c('chao1', 'ichao1', 'ace', 'jackknife', 'egghe_proot'))
  )

keys <- df %>% 
  arrange(desc(empirical), method) %>% 
  pull(key)
df$key <- factor(df$key, levels = keys)

meth_length <- length(levels(df$method))
empirical <- df %>% 
  arrange(desc(empirical)) %>% 
  select(value, empirical) %>% 
  distinct() %>% 
  mutate(
    id = ((row_number() - 1) * meth_length) + 1
  )

empirical <- empirical %>% 
  left_join(hypothetic) %>% 
  mutate(total = empirical + hypothetic)

df$value <- factor(df$value, levels = empirical$value)
methods <- as.character(df$method)

df %>% 
  ggplot(aes(x = key)) +
  geom_point(aes(y = richness, color = value)) +
  # geom_hline(yintercept = empirical, color = value) +
  geom_segment(data=empirical, aes(x = id, y = empirical, xend = id + meth_length - 1, yend = empirical, color = value)) +
  geom_segment(data=empirical, aes(x = id, y = total, xend = id + meth_length - 1, yend = total), color = 'grey') +
  geom_text(data=empirical, aes(x = id + 2, y = empirical - 50, label = empirical, color = value)) +
  # geom_text(aes(x = method, y = richness - 50, label = as.integer(richness), color = value)) +
  geom_segment(aes(x = key, y = min, xend = key, yend = max, color = value)) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 60, vjust = 1, hjust=1)
  ) +
  labs(
    title = paste(title, 'becsült minimális teljessége'),
    subtitle = 'területi hungarikumok',
    'A területi hungarikumok becsült minimális teljessége',
    x = 'becslési módszer',
    y = 'nyomtatványok száma'
  ) +
  scale_x_discrete(labels = methods) +
  scale_y_continuous(limits = c(-50,max(df$max) * 1.1)) +
  scale_color_discrete(name = NULL)

width <- 20
ggsave('img/abundance/richness-language.png', 
       dpi=300, width = width, height = width * .7, units = "cm")

# English version

df %>% 
  ggplot(aes(x = key)) +
  geom_point(aes(y = richness, color = value)) +
  # geom_hline(yintercept = empirical, color = value) +
  geom_segment(data=empirical, aes(x = id, y = empirical, xend = id + meth_length - 1, yend = empirical, color = value)) +
  geom_segment(data=empirical, aes(x = id, y = total, xend = id + meth_length - 1, yend = total), color = 'grey') +
  geom_text(data=empirical, aes(x = id + 2, y = empirical - 50, label = empirical, color = value)) +
  # geom_text(aes(x = method, y = richness - 50, label = as.integer(richness), color = value)) +
  geom_segment(aes(x = key, y = min, xend = key, yend = max, color = value)) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 60, vjust = 1, hjust=1)
  ) +
  labs(
    title = paste('estimated minimal completeness of', title_en),
    subtitle = 'regional Hungarica',
    x = 'estimation method',
    y = 'number of editions'
  ) +
  scale_x_discrete(labels = methods) +
  scale_y_continuous(limits = c(-50,max(df$max) * 1.1)) +
  scale_color_discrete(name = NULL)

width <- 20
ggsave('img/abundance/richness-language.en.png', 
       dpi=300, width = width, height = width * .7, units = "cm")
