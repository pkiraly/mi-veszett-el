library(tidyverse)

base_dir <- 'scripts/abundance/outputs4'

overview1 <- NULL
estimation1 <- NULL
datasources <- c('s1', 's2')
for (datasource in datasources) {
  dir <- sprintf('%s/%s_basis', base_dir, datasource)
  file <- sprintf('%s/estimation.csv', dir)
  if (!file.exists(file)) {
    print(paste('file is not existing:', file))
  } else {
    df <- read_csv(file, col_types = "cccddd")
    if (is.null(estimation1)) {
      estimation1 <- df
    } else {
      estimation1 <- estimation1 %>% union_all(df)
    }
  }
  file <- sprintf('%s/overview.csv', dir)
  if (!file.exists(file)) {
    print(paste('file is not existing:', file))
  } else {
    df <- read_csv(file, col_types = 'ccddddd')
    if (is.null(overview1)) {
      overview1 <- df
    } else {
      overview1 <- overview1 %>% union_all(df)
    }
  }
}

overview1
row <- overview1 %>% filter(data == 's2')
overview2 <- overview1 %>% rbind(row) %>% rbind(row)
overview2$data <- c('s1', 's2', 'heltai', 'latin')
overview2

estimation1
row <- estimation1 %>% filter(data == 's2')
estimation2 <- estimation1 %>% rbind(row) %>% rbind(row)
estimation2$data <- rep(c('s1', 's2', 'heltai', 'latin'), each = 5)
estimation2

datasources <- c('s1', 's2', 'heltai', 'latin')
selection_methods <- c('plus', 'plus_minimal', 'unique', 'increased')
overview <- NULL
estimation <- NULL
for (datasource in datasources) {
  for (selection_method in selection_methods) {
    dir <- sprintf('%s/%s_%s', base_dir, datasource, selection_method)
    file <- sprintf('%s/estimation.csv', dir)
    if (!file.exists(file)) {
      print(paste('file is not existing:', file))
    } else {
      df <- read_csv(file, col_types = "cccddd")
      if (is.null(estimation)) {
        estimation <- df
      } else {
        estimation <- estimation %>% union_all(df)
      }
    }
    file <- sprintf('%s/overview.csv', dir)
    if (!file.exists(file)) {
      print(paste('file is not existing:', file))
    } else {
      df <- read_csv(file, col_types = 'ccddddd')
      if (is.null(overview)) {
        overview <- df
      } else {
        overview <- overview %>% union_all(df)
      }
    }
  }
}

estimation
overview
estimation2

estimation3 <- estimation %>% 
  mutate(
    data = ifelse(data == 'full', 's2', data),
  ) %>% 
  union_all(estimation2)
estimation3 %>% print(n = Inf)

richness <- estimation3 %>% filter(estimation == 'chao1') %>% 
  select(-c(estimation, min, max)) %>% 
  mutate(
    method = case_match(
      method,
      'basis' ~ 'bázis',
      'plus' ~ 'a',
      'plus_minimal' ~ 'b',
      'unique' ~ 'c',
      'increased' ~ 'd',
    ),
    method = factor(method, levels = c('bázis', 'a', 'b', 'c', 'd')),
    data = case_match(
      data,
      's1' ~ 'S1-random',
      's2' ~ 'S2-random',
      'heltai' ~ 'S2-heltai',
      'latin' ~ 'S2-latin',
    ),
    data = factor(data, levels = c('S1-random', 'S2-random', 'S2-heltai', 'S2-latin'))
  ) %>% 
  arrange(data, method)
richness

overview3 <- overview %>% 
  mutate(
    data = ifelse(data == 'full', 's2', data),
  ) %>% 
  union_all(overview2)
overview3
c(
  'basis' = 'bázis',
  'plus' = 'a',
  'plus_minimal' = 'b',
  'unique' = 'c',
  'increased' = 'd'
)

overviews <- overview3 %>% select(-c(S, n)) %>% 
  pivot_longer(f1:f4) %>% 
  mutate(
    x = as.integer(gsub('f', '', name)),
    method = case_match(
      method,
      'basis' ~ 'bázis',
      'plus' ~ 'a',
      'plus_minimal' ~ 'b',
      'unique' ~ 'c',
      'increased' ~ 'd',
    ),
    method = factor(method, levels = c('bázis', 'a', 'b', 'c', 'd')),
    data = case_match(
      data,
      's1' ~ 'S1-random',
      's2' ~ 'S2-random',
      'heltai' ~ 'S2-heltai',
      'latin' ~ 'S2-latin',
    ),
    data = factor(data, levels = c('S1-random', 'S2-random', 'S2-heltai', 'S2-latin'))
  ) %>% 
  select(-name)

overviews
overviews %>% distinct(data)
richness

my_colors <- overviews %>% 
  mutate(color = ifelse(method == 'bázis', "cornflowerblue", "linen")) %>% 
  select(color) %>% unlist(use.names = F)

my_colors

overviews %>% 
  mutate(color = ifelse(method == 'bázis', "linen", "white")) %>% 
  ggplot(aes(x = x, y = value)) + 
  geom_rect(
    aes(fill = color), 
    xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf, alpha = 0.1) +
  theme_bw() +
  geom_point() +
  geom_text(data = richness, mapping = aes(label = ceiling(richness)), x = 4, y = 380, hjust = 1) +
  geom_line() +
  stat_smooth(method = "lm", col = 'grey', se = FALSE) +
  ylim(0, 400) +
  facet_grid(data ~ method) +
  labs(
    title = 'RMNY I. valós és szimulált halmazok példányszám-eloszlásai',
    x = 'fennmaradt példányok száma',
    y = 'kiadványok száma',
    fill = NULL,
  ) +
  guides(fill="none") +
  scale_color_manual(values = NULL, label = NULL) +
  scale_fill_manual(
    values = c("linen" = "#cccccc", "white" = "white"),
    labels = NULL)

ggsave("img/abundance/v04/simulation-graph-bw.png", 
       dpi = 300, width = 7, height = 6)

models <- overviews %>% 
  group_by(data, method) %>% 
  do(model = lm(x ~ value, data = .)) %>% 
  summarise(
    data = data,
    method = method,
    intercept = coef(model)[1],
    slope = coef(model)[2]
  )

models



estimation
overview

overview3

estimation3 %>% print(n = Inf)

estimation3 %>% 
  left_join(overview3) %>% 
  select(- c(f1, f2, f3, f4)) %>% 
  mutate(
    phase = ifelse(data == 's1', 'S1', 'S2'),
    data = case_match(
      data,
      's1' ~ 'S1-random',
      's2' ~ 'S2-random',
      'heltai' ~ 'S2-heltai',
      'latin' ~ 'S2-latin',
    ),
    data = factor(data, levels = c('S1-random', 'S2-random', 'S2-heltai', 'S2-latin')),
  ) %>% 
  print(n = Inf)

estimation4 <- estimation3 %>% 
  left_join(overview3) %>% 
  select(- c(f1, f2, f3, f4)) %>% 
  mutate(
    phase = ifelse(data == 's1', 'S1', 'S2'),
    data = case_match(
      data,
      's1' ~ 'S1-random',
      's2' ~ 'S2-random',
      'heltai' ~ 'S2-heltai',
      'latin' ~ 'S2-latin',
    ),
    data = factor(data, levels = c('S1-random', 'S2-random', 'S2-heltai', 'S2-latin')),
    method = case_match(
      method,
      'basis' ~ 'bázis',
      'plus' ~ 'a',
      'plus_minimal' ~ 'b',
      'unique' ~ 'c',
      'increased' ~ 'd',
    ),
    method = factor(method, levels = c('bázis', 'a', 'b', 'c', 'd')),
    estimation = factor(estimation, levels = c('chao1', 'ichao1', 'ace', 'jackknife', 'egghe_proot'))
  ) %>% 
  arrange(data, method) %>% 
  mutate(
    key = paste(data, method),
    # key = factor(key, levels = key)
  )
estimation4 %>% print(n = Inf)

keys <- estimation4 %>% select(key) %>% distinct() %>% pull()
estimation4$key <-factor(estimation4$key, levels = keys)
keys

models
#with_models <- 
estimation4 %>% 
  left_join(models, by = c('data', 'method')) %>% 
  group_by(estimation) %>% 
  summarise(
    cor1 = cor(richness, intercept),
    cor2 = cor(richness, slope),
  ) %>% 
  pivot_longer(cols = c(cor1, cor2)) %>% 
  mutate(
    name = ifelse(name == 'cor1', 'tengelymetszet', 'meredekség')
  ) %>% 
  ggplot(aes(x = estimation, y = value, color = name)) +
  geom_point() +
  geom_text(
    aes(
      label = round(value, 2), 
      y = value * 0.8), 
    angle = 0,
    size = 3) +
  ylim(-1, 1) + 
  theme_bw() + 
  labs(
    title = 'A példányszámok gyakoriságára illesztett egyenes paramétereinek\nkorrelációja a becslési módszerekkel',
    x = 'becslési módszer',
    y = 'korreláció',
    color = 'paraméter',
  )

ggsave("img/abundance/v04/korrelacio.png", dpi = 150,
       width = 5, height = 3)


levels(estimation4$key)

x_labels <- estimation4 %>% 
  filter(estimation == 'chao1') %>% 
  # arrange(desc(method), desc(data)) %>% 
  pull(method)
# select(data, method, richness)
x_labels

estimation4
base_dir
estimation4 %>% 
  select(-key) %>% 
  write_csv(sprintf('%s/all-estimations.csv', base_dir))

nudgex <- 0.3
estimation4 %>% 
  ggplot(aes(x = key, y = richness, color = data, shape = phase)) + 
  geom_point() + 
  geom_point(aes(x = key, y = S), color = 'grey') +
  facet_wrap(vars(estimation), ncol = 1, nrow = 5, strip.position = 'right') +
  ylim(c(500, 2000)) +
  geom_text(
    aes(
      label = round(richness),
      y = richness
    ),
    angle = 60, 
    nudge_y = 50,
    nudge_x = nudgex,
    size = 3,
    alpha = 0.7,
  ) +
  geom_segment(aes(x = key, y = min, xend = key, yend = max)) +
  geom_text(
    aes(
      label = S,
      y = S
    ),
    angle = 60, 
    nudge_y = 50,
    nudge_x = nudgex,
    size = 3,
    color = 'grey',
    alpha = 0.7,
  ) +
  labs(
    x = 'becslési alap',
    y = 'becsült kiadványszám',
    color = 'mintavétel',
    shape = 'tudáshalmaz',
    title = 'Becsült kiadványszámok tényleges és szimulált RMNY tételek alapján',
    subtitle = 'véletlenszerű mintavételi eljárások alapja: S1-random: S1, S2-random: S2, heltai: S2, Helta-nyomda, latin: S2, latin nyelvűek
módosítási eljárások: bázis: nincs módosítás, a becslés alapja az tudáshalmaz, a: új tételek példányszám szerint, b: új tételek maximum két példányban,
c: unkálisok új tételként, a többi példányszám-növeléssel, d: példányszám-növeléssel'
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 60, vjust = 1, hjust=1),
    plot.subtitle = element_text(size = 8),
  ) +
  scale_x_discrete(labels = function(x) {
    gsub('^[^ ]+ ', '', x)
  })
# scale_x_discrete(labels = function(x) {
#    gsub('^[^ ]+ ', '', levels(estimation4$key)))

ggsave("img/abundance/v04/szimulacio.png", dpi = 300,
       width = 10, height = 6)


estimation4 %>% 
  ggplot(aes(x = key, y = richness, color = data)) + 
  geom_point() +
  geom_point(aes(x = key, y = S), color = 'grey') +
  geom_text(
    aes(
      label = round(richness),
      y = max
    ),
    angle = 60, 
    nudge_y = 200
  ) +
  facet_wrap(simulation ~ method) +
  ylim(c(0, 2500)) +
  # geom_hline(yintercept = full_nr, color = 'grey') +
  # annotate(
  #   "text", x = 1, color = 'grey', hjust = 0,
  #   y = full_nr - 100, 
  #   label = sprintf("fennmaradt kiadványok száma (%d)", full_nr), 
  # ) +
  # geom_hline(yintercept = simulated_nr, color = 'cornflowerblue') +
  # annotate(
  #   "text", x = 1, color = 'cornflowerblue', hjust = 0,
  #   y = simulated_nr + 100, 
  #   label = sprintf("szimulált kiadványok száma (%d)", simulated_nr)
  # ) +
  geom_segment(aes(x = key, y = min, xend = key, yend = max)) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 60, vjust = 1, hjust=1)
  ) +
  labs(
    x = 'szimuláció',
    y = 'becsült kiadványszám',
    color = 'becslési\nmódszer',
    title = 'Becsült kiadványszámok szimulált RMNY tételek alapján',
    #    subtitle = 'full: becslés a fennmaradt példányok alapján (2024),
    # full: becslés a fennmaradt példányok alapján (1971),
    # random: véletlenszerű szimuláció
    # latin: szimuláció a latin nyelvű könyvek eloszlása alapján
    # brewer: szimuláció a Brewer nyomda kiadványainak eloszlása alapján
    # brewer2: példányszimuláció a Brewer nyomda kiadványainak eloszlása alapján'
  ) +
  scale_x_discrete(labels = estimation2$estimation)

estimation2 %>% 
  filter(estimation == 'chao1') %>% 
  ggplot(aes(x = method, y = richness, color = method)) + 
  geom_point() +
  geom_text(
    aes(
      label = round(richness),
      y = max
    ),
    angle = 60, 
    nudge_y = 200
  ) +
  facet_wrap(~ data)

