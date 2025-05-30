library(tidyverse)

title <- 'kiadványtípusok'
title_en <- 'publication types'
hypothetic <- read_csv("data_raw/hypothetic-by-genre.csv")
hypothetic
df <- tribble(
  ~method,~value,~empirical,~richness,~min,~max,
  "chao1","alkalmi",862,1586.78,1494.33,1682.40,
  "ichao1","alkalmi",862,1760.20,1655.83,1857.26,
  "ace","alkalmi",862,1800.75,1653.81,1952.81,
  "jackknife","alkalmi",862,2320.00,1926.85,2713.15,
  "egghe_proot","alkalmi",862,1729.86,1562.89,1883.58,
  "chao1","egyházi-vallási",1415,1887.88,1769.35,1968.69,
  "ichao1","egyházi-vallási",1415,1992.89,1914.11,2093.35,
  "ace","egyházi-vallási",1415,1789.01,1749.62,1835.48,
  "jackknife","egyházi-vallási",1415,2240.00,2076.56,2403.44,
  "egghe_proot","egyházi-vallási",1415,2294.25,2133.51,2409.84,
  "chao1","iskolai",567,762.31,711.36,815.92,
  "ichao1","iskolai",567,810.02,782.48,858.80,
  "ace","iskolai",567,754.80,719.12,790.37,
  "jackknife","iskolai",567,876.00,806.10,945.90,
  "egghe_proot","iskolai",567,854.96,783.26,891.04,
  "chao1","nem besorolt",2,2.50,1.60,3.10,
  "ichao1","nem besorolt",2,2.50,1.30,2.80,
  "ace","nem besorolt",2,NA,NA,NA,
  "jackknife","nem besorolt",2,2.00,2.00,2.00,
  "egghe_proot","nem besorolt",2,3.16,3.16,3.16,
  "chao1","szórakoztató",285,467.16,431.73,538.31,
  "ichao1","szórakoztató",285,512.05,472.12,571.54,
  "ace","szórakoztató",285,554.77,496.43,631.13,
  "jackknife","szórakoztató",285,584.00,489.96,678.04,
  "egghe_proot","szórakoztató",285,498.70,443.92,590.80,
  "chao1","tudományos",81,103.19,89.87,124.99,
  "ichao1","tudományos",81,108.73,93.37,128.69,
  "ace","tudományos",81,93.06,88.51,101.16,
  "jackknife","tudományos",81,112.00,90.53,133.47,
  "egghe_proot","tudományos",81,136.19,96.10,193.67,
  "chao1","állami működéshez kapcsolódó",267,316.10,304.39,330.63,
  "ichao1","állami működéshez kapcsolódó",267,328.05,302.16,360.44,
  "ace","állami működéshez kapcsolódó",267,311.84,302.93,321.07,
  "jackknife","állami működéshez kapcsolódó",267,354.00,315.29,392.71,
  "egghe_proot","állami működéshez kapcsolódó",267,363.52,291.12,419.59
)

genres <- tribble(
  ~hungarian, ~english,
  "egyházi-vallási", "ecclesiastical",
  "alkalmi",         "occasional",
  "iskolai",         "educational",
  "szórakoztató",    "entertainment",
  "állami működéshez kapcsolódó", "governmental",
  "tudományos",      "scientific",
  "nem besorolt",    "other"
)

df <- df %>% 
  left_join(genres, join_by(value == hungarian)) %>% 
  select(-value) %>% 
  rename(value = english)

hypothetic <- hypothetic %>% 
  left_join(genres, join_by(value == hungarian)) %>% 
  select(-value) %>% 
  rename(value = english)

df
hypothetic
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

df %>% 
  left_join(genres, join_by(value == hungarian))

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
ggsave('img/abundance/richness-genre.png', 
       dpi=300, width = width, height = width * .7, units = "cm")

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
ggsave('img/abundance/richness-genre.en.png', 
       dpi=300, width = width, height = width * .7, units = "cm")
