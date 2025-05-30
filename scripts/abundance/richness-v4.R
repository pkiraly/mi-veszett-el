library(tidyverse)

overview <- read_csv('scripts/abundance/outputs4/abundance_full/overview.csv')
estimation <- read_csv('scripts/abundance/outputs4/abundance_full/estimation.csv')

overview
estimation$estimation

# 
existing <- overview$S[1]
hypothetic <- 735
total <- existing + hypothetic
color <- 'black'

as.integer(factor(estimation$estimation, levels = c("chao1", "ichao1", "ace", "jackknife", "egghe_proot")))

z <- round(estimation$richness)
z[order(z)]

y <- round(estimation$richness) - total
y[order(y)]

x <- sprintf('%.2f', (estimation$richness - total) * 100 / total)
x[order(x)]

estimation %>% 
  mutate(
    estimation = factor(estimation, levels = c("chao1", "ichao1", "ace", "jackknife", "egghe_proot")),
    order = as.integer(estimation)
  ) %>% 
  ggplot(aes(x = estimation)) +
  geom_text(aes(x = estimation, y = max + 250, label = round(richness))) +
  geom_point(aes(y = richness), color = color) +
  geom_segment(aes(x = estimation, y = min, xend = estimation, yend = max), color = color) +
  geom_segment(aes(x = order - .05, y = min, xend = order + .05, yend = min), color = color) +
  geom_segment(aes(x = order - .05, y = max, xend = order + .05, yend = max), color = color) +
  geom_hline(yintercept = existing) +
  annotate("text", x = 3, y = existing * 0.95,
           label = sprintf("fennmaradt kötetek (%d)", existing)) +
  geom_hline(yintercept = total, color = '#666666') +
  annotate("text", x = 3, y = total * 0.95,
           label = sprintf("fennmaradt és feltételezett kötetek (%d)", total),
           color = '#666666') +
  theme_bw() +
  labs(
    # title = 'A területi hungarikumok becsült minimális teljessége',
    x = 'becslési módszer',
    y = 'nyomtatványok száma'
  ) +
  # scale_x_continuous(labels = estimation$estimation) +
  scale_y_continuous(limits = c(0,max(estimation$max) * 1.1))

ggsave('img/abundance/v04/richness.png', dpi=300, width = 6, height = 3)

