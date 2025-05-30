library(tidyverse)

df <- read_rds('data_raw/rmny-v04.rds')

df_s2 <- df %>% 
  filter(!is.na(x_s2_letezo_peldanyok_szama) &
           x_s2_letezo_peldanyok_szama > 0) %>% # 3832
  filter(bibliografiai_halmaz == 'RMNY' & x_teruleti_hungarikum == TRUE) %>% # 3520
  filter(x_fazis_2024_esemeny == 'besorolás') %>% # 3504
  filter(x_nyomtatasi_ev <= 1600) %>% 
  mutate(
    x_letezo_peldanyok_szama = x_s2_letezo_peldanyok_szama,
    category = cut(x_letezo_peldanyok_szama, 
                   breaks = c(0, 1, 4, 1000), 
                   labels = c('1', '2-4', '5+')),
    x_nyelvek = ifelse(grepl('(; | - )', x_nyelvek), 'multi', x_nyelvek)
  )
nrow(df_s2) # 694

n <- names(df_s2)
n[grepl('x_fazis', n)]

df_s1 <- df %>% 
  filter(!is.na(x_s1_letezo_peldanyok_szama) &
           x_s1_letezo_peldanyok_szama > 0) %>% # 3832
  filter(bibliografiai_halmaz == 'RMNY' & x_teruleti_hungarikum == TRUE) %>% # 3520
  filter(x_fazis_01_esemeny == 'besorolás') %>% # 3504
  filter(x_nyomtatasi_ev <= 1600) %>% 
  mutate(
    x_letezo_peldanyok_szama = x_s1_letezo_peldanyok_szama,
    category = cut(x_letezo_peldanyok_szama, 
                   breaks = c(0, 1, 4, 1000), 
                   labels = c('1', '2-4', '5+')),
    x_nyelvek = ifelse(grepl('(; | - )', x_nyelvek), 'multi', x_nyelvek))
nrow(df_s1) # 651

calculateWeights <- function(.df) {
  .df %>%
    select(id, category, x_nyelvek) %>% 
    group_by(category, x_nyelvek) %>% 
    summarise(num_rows = n(), .groups = 'keep') %>%
    ungroup() %>% 
    mutate(
      percent = num_rows * 100 / sum(num_rows),
      pr = round(percent)
    ) %>% 
    arrange(desc(percent)) %>% 
    mutate(x = cumsum(percent), y = cumsum(pr))
}

sample_by_weigth <- function(.df, .weigths) {
  sample <- NULL
  for (i in 1:nrow(.weigths)) {
    d <- slice(.weigths, i)
    if (d$pr > 0) {
      # print(d)
      s <- .df %>% 
        filter(category == d$category 
               & (
                 (is.na(d$x_nyelvek) & is.na(x_nyelvek)) 
                 | x_nyelvek == d$x_nyelvek)) %>% 
        slice_sample(n = d$pr)
      if (is.null(sample)) {
        sample <- s
      } else {
        sample <- sample %>% union(s)
      }
    }
  }
  sample
}

#' Simply add the sample to the basis
#' 
#' @param .df The basis
#' @param .sample The sample
addSample <- function(.df, .sample) {
  tibble(
    count = c(.df$x_letezo_peldanyok_szama, .sample$x_letezo_peldanyok_szama)
  )
}

addSampleMinimal <- function(.df, .sample) {
  x <- .sample$x_letezo_peldanyok_szama
  tibble(
    count = c(.df$x_letezo_peldanyok_szama, x[ifelse(x > 2, 2, x)])
  )
}

addUnique <- function(.df, .sample) {
  .unique <- .sample %>% filter(x_letezo_peldanyok_szama == 1)
  print(nrow(.unique))
  .nonunique <- .sample %>% filter(x_letezo_peldanyok_szama != 1)
  print(nrow(.nonunique))
  print(nrow(.df))
  .df %>% 
    union_all(.unique) %>% 
    nrow() %>% print()
  
  .df %>% 
    union_all(.unique) %>% 
    mutate(
      x_letezo_peldanyok_szama = ifelse(
        id %in% .nonunique$id,
        ifelse(x_letezo_peldanyok_szama == 1, 1, x_letezo_peldanyok_szama + 1),
        x_letezo_peldanyok_szama
      )
    ) %>% 
    select(count = x_letezo_peldanyok_szama)
}

increaseBySample <- function(.df, .sample) {
  .df %>% 
    mutate(
      x_letezo_peldanyok_szama = ifelse(
        id %in% .sample$id,
        x_letezo_peldanyok_szama + 1,
        x_letezo_peldanyok_szama
      )
    ) %>% 
    select(count = x_letezo_peldanyok_szama)
}

runProcess <- function(.prefix, .fullDf, .filteredDf) {
  
  weightsDf <- calculateWeights(.filteredDf)
  sampleDf <- sample_by_weigth(.filteredDf, weightsDf)
  
  plus <- addSample(.fullDf, sampleDf)
  plus_minimal <- addSampleMinimal(.fullDf, sampleDf)
  unique <- addUnique(.fullDf, sampleDf)
  increased <- increaseBySample(.fullDf, sampleDf)
  
  dirName <- 'data_raw/v04/abundance/'
  sampleDf %>% 
    select(id) %>%
    write_csv(sprintf('%s/%s_sample.csv', dirName, .prefix))
  
  print('write2')
  write_csv(plus, sprintf('%s/%s_plus.csv', dirName, .prefix))
  print('write3')
  write_csv(plus_minimal, sprintf('%s/%s_plus_minimal.csv', dirName, .prefix))
  print('write4')
  write_csv(unique, sprintf('%s/%s_unique.csv', dirName, .prefix))
  print('write5')
  write_csv(increased, sprintf('%s/%s_increased.csv', dirName, .prefix))
  print('done')
}

df_s2 %>% 
  count(x_nyomda) %>% 
  arrange(desc(n))

runProcess('s2', df_s2, df_s2)

selected <- df_s2 %>%
  filter(x_nyomda == 'Heltai nyomda')
runProcess('heltai', df_s2, selected)

selected <- df_s2 %>%
  filter(x_nyelvek == 'latin')
runProcess('latin', df_s2, selected)

runProcess('s1', df_s1, df_s1)

dirName <- 'data_raw/v04/abundance/'
df_s1 %>% select(count = x_letezo_peldanyok_szama) %>% write_csv(sprintf('%s/%s_basis.csv', dirName, 's1'))
df_s2 %>% select(count = x_letezo_peldanyok_szama) %>% write_csv(sprintf('%s/%s_basis.csv', dirName, 's2'))

