library(tidyverse)

df <- read_rds('data_raw/rmny-v04.rds')
df_full <- df %>% filter(bibliografiai_halmaz == 'RMNY' & x_teruleti_hungarikum == TRUE) %>% # 3520
  filter(x_nyomtatasi_ev <= 1600) 

n <- names(df_full)
n[grepl('letezo', n)]

#' letezo_peldanyok
#' x_s1_letezo_peldanyok_szama
#' x_s1_letezo_peldanyok_szorodasa
#' x_s2_peldanyok_letezo
#' x_s2_peldanyok_letezok_szama_calc
#' x_s2_peldanyok_letezok_szorodasa_calc

df_full$x_s2_letezo_peldanyok_szama
df_full %>% 
  filter(x_fazis_2024_esemeny == 'besorolás') %>% # 3504
  count(!is.na(x_s2_letezo_peldanyok_szama) & x_s2_letezo_peldanyok_szama > 0)

# FALSE    173
# TRUE     694

df_full %>% 
  filter(x_fazis_01_esemeny == 'besorolás') %>% # 3504
  count(!is.na(x_s1_letezo_peldanyok_szama)
        & x_s1_letezo_peldanyok_szama > 0)
# FALSE    168
# TRUE     651

overview1 <- NULL
estimation1 <- NULL

base_dir <- 'scripts/abundance/outputs4'
datasources <- c('rmk', 's1', 's2')
for (datasource in datasources) {
  dir <- sprintf('%s/%s_basis', base_dir, datasource)
  df <- read_csv(sprintf('%s/estimation.csv', dir), col_types = "cccddd")
  if (is.null(estimation1)) {
    estimation1 <- df
  } else {
    estimation1 <- estimation1 %>% union_all(df)
  }
  
  df <- read_csv(sprintf('%s/overview.csv', dir), col_types = 'ccddddd')
  if (is.null(overview1)) {
    overview1 <- df
  } else {
    overview1 <- overview1 %>% union_all(df)
  }
}
overview1

overview1 <- overview1 %>% 
  mutate(data = ifelse(data == 'rmk', '1885', data))
estimation1 <- estimation1 %>% 
  mutate(data = ifelse(data == 'rmk', '1885', data))

overview1$data <- c('1885', '1971', '2025')
estimation1 <- estimation1 %>% 
  mutate(
    data = ifelse(data == 's1', '1971', data),
    data = ifelse(data == 's2', '2025', data)
  )
estimation1
    
overview1$data = factor(overview1$data, levels = c('1885', '1971', '2025'))
estimation1$data = factor(estimation1$data, levels = c('1885', '1971', '2025'))
overview1$hipothetical = c(122, 168, 173)
overview1
estimation1 %>% filter(estimation == 'jackknife')

# estimation1 %>% 

joined <- overview1 %>% 
  select(data, method, S, hipothetical) %>% 
  left_join(estimation1, by = join_by(data, method)) %>% 
  mutate(
    total = S + hipothetical,
    diff = richness - total,
    percent = diff * 100 / total,
    label = sprintf(
      '%d\n%f%%',
      ceiling(richness),
      round(percent)
    ),
    estimation = factor(estimation, levels = c('chao1', 'ichao1', 'ace', 'jackknife', 'egghe_proot'))
  )
joined
# write_csv(joined)

joined %>%
  ggplot(aes(x = estimation, y = richness)) +
  geom_point() +
  geom_text(
    aes(label = sprintf('%d', ceiling(richness))), 
    angle = 90,
    nudge_x = 0.2,
    nudge_y = 40,
    size = 3,
    # color = 'grey',
    alpha = 0.7,
  ) +
  geom_text(
    aes(label = sprintf('%s%%', round(percent))), 
    angle = 90,
    nudge_x = 0.45,
    nudge_y = 40,
    size = 3,
    color = '#999999',
    # alpha = 0.7,
  ) +
  geom_text(data = overview1, mapping = aes(label = S, y = S+30, x = 3)) +
  geom_text(
    data = overview1, 
    mapping = aes(
      label = sprintf('%d (h=%d)',
                      S + hipothetical,
                      hipothetical),
      y = S + hipothetical + 30, 
      x = 3
    ),
    color = '#666666'
  ) +
  geom_segment(
    aes(x = estimation, y = min, xend = estimation, yend = max),
    alpha = 0.4,
  ) +
  geom_hline(data = overview1, mapping = aes(yintercept = S)) +
  geom_hline(
    data = overview1,
    mapping = aes(yintercept = S + hipothetical),
    color = '#666666'
  ) +
  facet_wrap(~data) +
  ylim(0, max(estimation1$max) + 10) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 60, vjust = 1, hjust=1),
  ) +
  labs(
    # title = 'A nyomtatványokról szóló ismeretek és a becslések változása',
    x = 'becslési eljárás',
    y = 'nyomtatványok száma',
  )

ggsave("img/abundance/v04/3-fazisu-becsles.png", dpi = 300,
       width = 10, height = 6)

write_csv(joined, 'data_raw/v04/3-fazisu-becsles.csv')
