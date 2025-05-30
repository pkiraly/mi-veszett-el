library(tidyverse)

base_dir <- 'scripts/abundance/outputs'

overview1 <- NULL
estimation1 <- NULL
datasources <- c('1971', '2024')
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
row <- overview1 %>% filter(data == 2024)
overview2 <- overview1 %>% rbind(row) %>% rbind(row)
overview2$data <- c('1971', '2024', 'heltai', 'latin')
overview2

estimation1
row <- estimation1 %>% filter(data == 2024)
estimation2 <- estimation1 %>% rbind(row) %>% rbind(row)
estimation2$data <- rep(c('1971', '2024', 'heltai', 'latin'), each = 5)
estimation2

datasources <- c('1971', 'full', 'heltai', 'latin')
selection_methods <- c('plus', 'plus_minimal', 'unique', 'increased')
overview <- NULL
estimation <- NULL
for (datasource in datasources) {
  for (selection_method in selection_methods) {
    dir <- sprintf('%s/%s_%s', base_dir, datasource, selection_method)
    # print(dir)
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
estimation2

estimation3 <- estimation %>% 
  mutate(
    data = ifelse(data == 'full', '2024', data),
  ) %>% 
  union_all(estimation2)
estimation3

overview3 <- overview %>% 
  mutate(
    data = ifelse(data == 'full', '2024', data),
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
      '1971' ~ 'S1-random',
      '2024' ~ 'S2-random',
      'heltai' ~ 'S2-heltai',
      'latin' ~ 'S2-latin',
    ),
    data = factor(data, levels = c('S1-random', 'S2-random', 'S2-heltai', 'S2-latin'))
  ) %>% 
  select(-name)

overviews %>% 
  ggplot(aes(x = x, y = value)) + 
  geom_point() +
  geom_line() +
  stat_smooth(method = "lm", col = "red") +
  ylim(0, 400) +
  facet_grid(data ~ method) +
  theme_bw() +
  labs(
    title = 'RMNY I. valós és szimulált halmazok példányszám-eloszlásai',
    x = 'femmaradt példányok száma',
    y = 'kiadványok száma',
  )
ggsave("img/abundance/v03/eloszlasok.png", dpi = 300,
       width = 7, height = 6)

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

estimation3 %>% print(n = Inf)

estimation4 <- estimation3 %>% 
  left_join(overview3) %>% 
  select(- c(f1, f2, f3, f4)) %>% 
  mutate(
    phase = ifelse(data == '1971', 'S1', 'S2'),
    data = case_match(
      data,
      '1971' ~ 'S1-random',
      '2024' ~ 'S2-random',
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
  
ggsave("img/abundance/v03/korrelacio.png", dpi = 150,
       width = 5, height = 3)


levels(estimation4$key)

x_labels <- estimation4 %>% 
  filter(estimation == 'chao1') %>% 
  # arrange(desc(method), desc(data)) %>% 
  pull(method)
  # select(data, method, richness)
x_labels

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

ggsave("img/abundance/v03/szimulacio.png", dpi = 300,
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
  