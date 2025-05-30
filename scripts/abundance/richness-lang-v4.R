library(tidyverse)

base_dir <- 'scripts/abundance/outputs4'

overview <- NULL
estimation <- NULL
datasources <- c('magyar', 'latin', 'német')
for (datasource in datasources) {
  dir <- sprintf('%s/lang_%s', base_dir, datasource)
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
  print(file)
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
# overview
# estimation

stat <- read_csv('data_raw/v04/abundance/lang_stat.csv')
stat <- stat %>% 
  pivot_wider(names_from = is_hipothetical, values_from = n)
names(stat) <- c('method', 'real', 'hipothetical')
stat

df <- estimation %>% 
  mutate(
    estimation = factor(estimation, levels = c('chao1', 'ichao1', 'ace', 'jackknife', 'egghe_proot')),
  ) %>% 
  left_join(stat) %>% 
  mutate(
    method = factor(method, levels = datasources),
    total = real + hipothetical,
    diff = richness - total,
    perc = diff *100 / total
  )

df

df %>% 
  ggplot(aes(x = estimation, y = richness)) +
  geom_segment(aes(y = min, xend = estimation, yend = max), color = '#cccccc') +
  geom_point() +
  geom_text(
    aes(x = estimation, y = richness + 140, 
        label = sprintf("%d", round(richness))),
    size = 3
  ) +
  geom_text(
    aes(x = as.numeric(estimation) + 0.3, y = richness + 100, 
        label = sprintf("%d%%", round(perc))),
    color = '#666666', size=2.8, angle = 90, hjust = 1
  ) +
  geom_hline(aes(yintercept = real)) +
  geom_hline(aes(yintercept = real + hipothetical), color = '#cccccc') +
  geom_text(aes(y = real - 50,
                label = sprintf("%d", real)), 
            x = 3) +
  geom_text(
    aes(
      y = (real + hipothetical) - 50,
      label = sprintf("%d (h=%d))", real + hipothetical, hipothetical)), 
    x = 3, color = '#cccccc'
  ) +
  ylim(0, max(estimation$richness)*1.1) +
  facet_wrap(~ method, nrow = 1) +
  theme_bw() +
  theme(
    axis.text.x = element_text(
      angle = 60, vjust = 1, hjust=1)
  ) +
  labs(
    x = 'becslési eljárások',
    y = 'kiadványszám'
  )

ggsave("img/abundance/v04/richnes-lang-bw.png", 
       dpi = 300, width = 7, height = 5)

