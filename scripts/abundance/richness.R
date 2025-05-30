library(tidyverse)

df <- tribble(
  ~id,~method,~richness,~min,~max,
  1,'chao1',5068.90,4944.46,5218.50,
  2,'iChao1',5438.71,5275.09,5658.18,
  3,'ace',4919.33,4839.53,5005.11,
  4,'jackknife',6506.00,6053.63,6958.37,
  5,'Egghe-Proot',5920.96,5738.02,6167.45,
)

# 
existing <- 3479
hypothetic <- 882
total <- existing + hypothetic
color <- 'black'

df %>% 
  ggplot(aes(x = id)) +
  geom_text(aes(x = id, y = max + 150, label = richness)) +
  geom_point(aes(y = richness), color = color) +
  geom_segment(aes(x = id, y = min, xend = id, yend = max), color = color) +
  geom_segment(aes(x = id - .05, y = min, xend = id + .05, yend = min), color = color) +
  geom_segment(aes(x = id - .05, y = max, xend = id + .05, yend = max), color = color) +
  geom_hline(yintercept = existing, color = 'cornflowerblue') +
  annotate("text", x = 3, y = existing * 0.95,
           label = sprintf("fennmaradt kötetek (%d)", existing),
           color = 'cornflowerblue') +
  geom_hline(yintercept = total, color = 'grey') +
  annotate("text", x = 3, y = total * 0.95,
           label = sprintf("fennmaradt és feltételezett kötetek (%d)", total),
           color = 'grey') +
  theme_bw() +
  labs(
    title = 'A területi hungarikumok becsült minimális teljessége',
    x = 'becslési módszer',
    y = 'nyomtatványok száma'
  ) +
  scale_x_continuous(labels = df$method) +
  scale_y_continuous(limits = c(0,max(df$max) * 1.1))

ggsave('img/abundance/richness.png', dpi=300, width = 12, height = 10)

df %>% 
  ggplot(aes(x = id)) +
  geom_text(aes(x = id, y = max + 150, label = richness)) +
  geom_point(aes(y = richness), color = color) +
  geom_segment(aes(x = id, y = min, xend = id, yend = max), color = color) +
  geom_segment(aes(x = id - .05, y = min, xend = id + .05, yend = min), color = color) +
  geom_segment(aes(x = id - .05, y = max, xend = id + .05, yend = max), color = color) +
  geom_hline(yintercept = existing, color = 'cornflowerblue') +
  annotate("text", x = 3, y = existing * 0.95,
           label = sprintf("survived editions (%d)", existing),
           color = 'cornflowerblue') +
  geom_hline(yintercept = total, color = 'grey') +
  annotate("text", x = 3, y = total * 0.95,
           label = sprintf("survived and hypothetical editions (%d)", total),
           color = 'grey') +
  theme_bw() +
  labs(
    title = 'Estimated minimal completeness of regional Hungarica',
    x = 'estimation method',
    y = 'number of editions'
  ) +
  scale_x_continuous(labels = df$method) +
  scale_y_continuous(limits = c(0,max(df$max) * 1.1))

ggsave('img/abundance/richness.en.png', dpi=300, width = 12, height = 10)
