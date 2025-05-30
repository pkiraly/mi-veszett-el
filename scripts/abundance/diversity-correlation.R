library(tidyverse)

base_dir <- 'scripts/abundance/outputs4'

overview1 <- NULL
estimation1 <- NULL
datasources <- c('rmk', 's1', 's2', 'heltai', 'latin')
selection_methods <- c('basis', 'plus', 'plus_minimal', 'unique', 'increased')
for (datasource in datasources) {
  for (selection_method in selection_methods) {
    dir <- sprintf('%s/%s_%s', base_dir, datasource, selection_method)
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
}

overview1
estimation1

all <- estimation1 %>% 
  left_join(overview1) %>% 
  select(-c(f1, f2, f3, f4, n))

all %>% 
  group_by(estimation) %>% 
  summarise(
    cor0 = cor(richness, S),
    cor1 = cor(richness, Hill_Shannon),
    cor2 = cor(richness, Hill_Simpson)
  ) %>%
  pivot_longer(cor0:cor2) %>% 
  mutate(
    estimation = factor(estimation, levels = c('chao1', 'ichao1', 'ace', 'jackknife', 'egghe_proot'))) %>% 
  ggplot(aes(x = estimation, y = value, shape = name)) +
  geom_point(size = 3) +
  theme_bw() +
  ylim(-1, 1) +
  labs(
    x = 'becslési eljárás',
    y = 'korreláció',
    shape = 'diverzitás index'
  ) +
  scale_shape_discrete(labels = c(
    'cor0' = 'fajgazdagság',
    'cor1' = 'Hill-Shannon',
    'cor2' = 'Hill-Simpson'
  ))
ggsave("img/abundance/v04/diversity-correlation.png", dpi = 300,
       width = 7, height = 3)

