library(tidyverse)

title <- 'formátumok'
title_en <- 'formats'
hypothetic <- read_csv("data_raw/hypothetic-by-format.csv")
hypothetic
df <- tribble(
  ~method,~value,~empirical,~richness,~min,~max,
  "chao1","1°",59,537.64,289.03,918.63,
  "ichao1","1°",59,563.14,399.20,1015.66,
  # "ace","1°",59,1807.22,-6530.94,14968.51,
  "ace","1°",59,1807.22,NA,NA,
  "jackknife","1°",59,164.00,128.72,199.28,
  "egghe_proot","1°",59,557.71,301.57,1453.54,
  "chao1","2°",331,538.02,505.15,570.28,
  "ichao1","2°",331,566.27,498.78,635.40,
  "ace","2°",331,456.46,430.37,502.38,
  "jackknife","2°",331,629.00,542.81,715.19,
  "egghe_proot","2°",331,688.94,618.41,813.44,
  "chao1","4°",1420,1988.53,1894.16,2070.92,
  "ichao1","4°",1420,2129.47,2013.56,2214.28,
  "ace","4°",1420,1983.03,1937.82,2031.45,
  "jackknife","4°",1420,2424.00,2243.30,2604.70,
  "egghe_proot","4°",1420,2286.08,2076.83,2404.15,
  "chao1","8°",895,1274.93,1236.63,1325.45,
  "ichao1","8°",895,1360.86,1290.72,1441.80,
  "ace","8°",895,1215.04,1190.58,1245.90,
  "jackknife","8°",895,1536.00,1395.16,1676.84,
  "egghe_proot","8°",895,1507.48,1384.37,1628.95,
  "chao1","egyéb",774,1114.85,1054.38,1199.57,
  "ichao1","egyéb",774,1197.82,1139.38,1294.91,
  "ace","egyéb",774,1127.08,1064.51,1192.47,
  "jackknife","egyéb",774,1360.00,1222.16,1497.84,
  "egghe_proot","egyéb",774,1261.55,1163.26,1384.91
)

translated <- tribble(
  ~hungarian, ~english,
  "1°",       "1°",
  "2°",       "2°",
  "4°",       "4°",
  "8°",       "8°",
  "egyéb",    "other"
)

df <- df %>% 
  left_join(translated, join_by(value == hungarian)) %>% 
  select(-value) %>% 
  rename(value = english)

hypothetic <- hypothetic %>% 
  left_join(translated, join_by(value == hungarian)) %>% 
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
empirical
df$value <- factor(df$value, levels = empirical$value)
methods <- as.character(df$method)

max(df$max)

df

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
  scale_y_continuous(limits = c(min(df$min),max(df$max) * 1.1)) +
  scale_color_discrete(name = NULL)

width <- 20
ggsave('img/abundance/richness-format.png', 
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
  scale_y_continuous(limits = c(min(df$min),max(df$max) * 1.1)) +
  scale_color_discrete(name = NULL)

width <- 20
ggsave('img/abundance/richness-format.en.png', 
       dpi=300, width = width, height = width * .7, units = "cm")

