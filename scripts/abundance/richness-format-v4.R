library(tidyverse)

base_dir <- 'scripts/abundance/outputs4'

overview <- NULL
estimation <- NULL
datasources <- c('1', '2', '4', '8', 'egyéb')
for (datasource in datasources) {
  dir <- sprintf('%s/format_%s', base_dir, datasource)
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

stat <- read_csv('data_raw/v04/abundance/format_stat.csv')
stat <- stat %>% 
  mutate(
    format = ifelse(format == 'egyéb',
                    format,
                    sprintf("%s°", format))
  ) %>% 
  pivot_wider(names_from = is_hipothetical, values_from = n)
names(stat) <- c('method', 'real', 'hipothetical')
# stat
stat

estimation

df <- estimation %>% 
  mutate(
    estimation = factor(estimation, levels = c('chao1', 'ichao1', 'ace', 'jackknife', 'egghe_proot')),
    method = ifelse(method == 'egyéb',
                    method,
                    sprintf("%s°", method))
  ) %>% 
  left_join(stat) %>% 
  mutate(
    method = factor(method, levels = c('1°', '2°', '4°', '8°', 'egyéb')),
    total = real + hipothetical,
    diff = richness - total,
    perc = diff *100 / total
  )
df

df %>% 
  ggplot(aes(x = estimation, y = richness)) +
  geom_segment(aes(y = min, xend = estimation, yend = max), color = '#666666') +
  geom_point() +
  geom_text(
    aes(x = as.numeric(estimation) + 0.3, y = richness - 30, 
        label = sprintf("%d - %d%%", round(richness), round(perc))),
    size = 2.8, angle = 90, hjust = 0
  ) +
  geom_hline(aes(yintercept = real)) +
  geom_hline(aes(yintercept = real + hipothetical), color = '#cccccc') +
  geom_text(
    aes(y = real - 50,
        label = sprintf("%d", real)), 
    x = 3, size = 3
  ) +
  geom_text(
    aes(
      y = (real + hipothetical) + 50,
      label = sprintf("%d (h=%d))", real + hipothetical, hipothetical)), 
    x = 3, color = '#cccccc', size = 3
  ) +
  ylim(0, max(estimation$richness)*1.2) +
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

ggsave("img/abundance/v04/richnes-format-bw.png", 
       dpi = 300, width = 8, height = 5)
