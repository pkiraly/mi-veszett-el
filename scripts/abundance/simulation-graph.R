library(tidyverse)

df <- read_csv('scripts/abundance/outputs/estimation.csv')
names(df)
overview <- read_csv('scripts/abundance/outputs/overview.csv')
full_nr <- overview[overview$set == 'full', 'S'] %>% pull()
full_nr
simulated_nr <- overview[overview$set == 'brewer', 'S'] %>% pull()
simulated_nr

df2 <- df %>% 
  mutate(
    set = factor(
      set, 
      levels = c('full', 'phase1', 'random', 'latin', 'brewer', 'brewer2')),
    method = factor(
      method, 
      levels = c('chao1', 'ichao1', 'ace', 'jackknife', 'egghe_proot')),
  ) %>% 
  arrange(method, set) %>% 
  mutate(
    key = paste(method, set),
    key = factor(key, levels = key)
  )

df2$key

df2 %>% 
  ggplot(aes(x = key, y = estimation, color = method)) + 
  geom_point() +
  geom_text(aes(label = round(estimation),
                y = max), angle = 60, 
            nudge_y = 200) +
  geom_hline(yintercept = full_nr, color = 'grey') +
  annotate(
    "text", x = 1, color = 'grey', hjust = 0,
    y = full_nr - 100, 
    label = sprintf("fennmaradt kiadványok száma (%d)", full_nr), 
  ) +
  geom_hline(yintercept = simulated_nr, color = 'cornflowerblue') +
  annotate(
    "text", x = 1, color = 'cornflowerblue', hjust = 0,
    y = simulated_nr + 100, 
    label = sprintf("szimulált kiadványok száma (%d)", simulated_nr)
  ) +
  geom_segment(aes(x = key, y = min, xend = key, yend = max, color = method)) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 60, vjust = 1, hjust=1)
  ) +
  labs(
    x = 'szimuláció',
    y = 'becsült kiadványszám',
    color = 'becslési\nmódszer',
    title = 'Becsült kiadványszámok szimulált RMNY tételek alapján',
    subtitle = 'full: becslés a fennmaradt példányok alapján (2024),
full: becslés a fennmaradt példányok alapján (1971),
random: véletlenszerű szimuláció
latin: szimuláció a latin nyelvű könyvek eloszlása alapján
brewer: szimuláció a Brewer nyomda kiadványainak eloszlása alapján
brewer2: példányszimuláció a Brewer nyomda kiadványainak eloszlása alapján'
  ) +
  scale_x_discrete(labels = df2$set)

ggsave("img/abundance/v02/szimulacio3.png", dpi = 300,
       width = 8, height = 6)

x <- c(21928, 22046, 22063)
x - 21557

overview %>% 
  select(-c(S, n)) %>% 
  pivot_longer(cols = f1:f4) %>% 
  mutate(
    name = as.integer(gsub('f', '', name)),
    .color = ifelse(set == 'brewer2', 'brewer2', 'egyéb'),
    .alpha = ifelse(set == 'brewer2', 1, 0.7)
  ) %>% 
  ggplot(aes(x = name, y = value, color = .color)) +
  geom_line(aes(group = set, alpha = .alpha)) +
  geom_point() +
  labs(
    title = 'fennmaradt példányok eloszlása',
    subtitle = 'Brewer-nyomda ismert kiadványainak 100 új példánya felbukkanásával',
    x = 'fennmaradt példányok száma',
    y = 'nyomtatványok száma',
    color = '') +
  theme_bw() +
  scale_y_continuous(transform = 'pseudo_log') +
  scale_alpha_continuous(guide="none")

ggsave("img/abundance/v02/overview3.png", dpi = 300,
       width = 8, height = 6)
