library(tidyverse)

df <- read_rds('data_raw/rmny-v03.rds')
# df %>% view()
nrow(df)
names(df)

df_full <- df %>% 
  filter(!is.na(x_letezo_peldanyok_szama) &
                       x_letezo_peldanyok_szama > 0) %>% # 3832
  filter(bibliografiai_halmaz == 'RMNY' & x_teruleti_hungarikum == TRUE) %>% # 3520
  filter(x_fazis_2024_esemeny == 'besorolás') # 3504
nrow(df_full)

# S1: x fazis 1 = 'besorolás'
s1_full <- df %>% 
  filter(!is.na(x_letezo_peldanyok_szama) &
           x_letezo_peldanyok_szama > 0) %>% # 3832
  filter(bibliografiai_halmaz == 'RMNY' & x_teruleti_hungarikum == TRUE) %>% # 3520
  filter(x_fazis_01_esemeny == 'besorolás') # 3504
nrow(s1_full)


df_full %>% 
  count(bibliografiai_halmaz) %>% 
  arrange(desc(n))

getPercentageDf <- function(.df, .collection, .filter = 10) {
  # print(.df)
  percentageDF <- .df %>% 
    select(x = x_letezo_peldanyok_szama) %>% 
    count(x) %>% 
    mutate(p = n / nrow(.df)) %>% 
    select(x, p) %>% 
    mutate(collection = .collection)

  if (!is.na(.filter)) {
    print(percentageDF)
    percentageDF <- percentageDF %>% 
      filter(x <= .filter)
  }
  return(percentageDF)
}

df3 <- getPercentageDf(df_full, 'teljes')

df4 <- df_full %>%
  sample_n(100) %>% 
  getPercentageDf('100 kiadvány mintája')

df5 <- df_full %>%
  filter(x_nyelvek == 'latin') %>% 
  # sample_n(100) %>% 
  getPercentageDf('latin kiadványok')
df5 %>% mutate(cat = cut(x, breaks = c(0, 1, 4, 1000), labels = c('1', '2-4', '5+')))

df6 <- df_full %>%
  filter(x_nyomda == 'Brewer nyomda') %>% 
  # sample_n(100) %>% 
  getPercentageDf('Brewer kiadványok')
df6

brewerIds <- df_full %>%
  filter(x_nyomda == 'Brewer nyomda') %>% 
  sample_n(100) %>% 
  select(id) %>% 
  pull()
brewerIds

df7 <- df_full %>% 
  mutate(x_letezo_peldanyok_szama = ifelse(
    id %in% brewerIds,
    x_letezo_peldanyok_szama + 1,
    x_letezo_peldanyok_szama)
  ) %>% 
  getPercentageDf('Brewer2')
df7

union(df3, df4) %>% union(df5) %>% union(df6) %>% union(df7) %>% 
  mutate(collection = factor(
    collection, 
    levels = c('teljes', '100 kiadvány mintája',
               'latin kiadványok', 'Brewer kiadványok',  'Brewer2'))) %>% 
  ggplot(aes(x = x, y = p, fill = collection)) +
  # geom_jitter(alpha = 0.5) +
  geom_col(position = "dodge", alpha = 0.5) +
  geom_line(aes(color = collection), size=1) +
  labs(title = 'eloszlások összehasonlítása',
       y = "az összes kiadványok szäääzaléka",
       x = 'fennmaradt példányszám') +
  scale_x_continuous(breaks = seq(1:10))

random_sample <- df_full %>%
  sample_n(100) %>% 
  select(x = x_letezo_peldanyok_szama)

latin_sample <- df_full %>%
  filter(x_nyelvek == 'latin') %>% 
  sample_n(100) %>% 
  select(x = x_letezo_peldanyok_szama)

brewer_sampleDf <- df_full %>%
  filter(x_nyomda == 'Brewer nyomda') %>% 
  sample_n(100)

brewer_sample <- brewer_sampleDf %>% 
  select(x = x_letezo_peldanyok_szama)

brewer_sampleDf$id

full_x <- data.frame(count = c(df_full$x_letezo_peldanyok_szama))
sum(full_x$count)
random_x <- data.frame(count = c(df_full$x_letezo_peldanyok_szama, random_sample$x))
latin_x  <- data.frame(count = c(df_full$x_letezo_peldanyok_szama, latin_sample$x))
brewer_x <- data.frame(count = c(df_full$x_letezo_peldanyok_szama, brewer_sample$x))
brewer2_x <- df_full %>% 
  mutate(x_letezo_peldanyok_szama = ifelse(
      id %in% brewer_sampleDf$id,
      x_letezo_peldanyok_szama + 1,
      x_letezo_peldanyok_szama
    )
  ) %>% 
  select(count = x_letezo_peldanyok_szama)


write_csv(full_x, 'data_raw/v02/abundance-full.csv')
write_csv(random_x, 'data_raw/v02/abundance-random.csv')
write_csv(latin_x, 'data_raw/v02/abundance-latin.csv')
write_csv(brewer_x, 'data_raw/v02/abundance-brewer.csv')
write_csv(brewer2_x, 'data_raw/v02/abundance-brewer2.csv')

#' stratified sample
iris_subset <- iris[c(1:50, 51:80, 101:120), ]
iris_subset
iris_subset$condition <- rep(seq(1,5,by=1), 20)

# next line does not run, but I'm wondering how it could. 
stratified_sample <- iris_subset %>%
  group_by(Species, condition) %>%
  mutate(num_rows=n()) %>%
  sample_frac(0.4, weight=num_rows) %>%
  ungroup

stratified_sample

# stratified_sample on Brewer
df_full %>%
  filter(x_nyomda == 'Brewer nyomda') %>% 
  mutate(sum1 = sum(x_letezo_peldanyok_szama)) %>% 
  select(sum1)

names(df_full)
brewer <- df_full %>%
  filter(x_nyomda == 'Brewer nyomda') %>% 
  mutate(category = cut(x_letezo_peldanyok_szama, 
                        breaks = c(0, 1, 4, 1000), 
                        labels = c('1', '2-4', '5+'))) %>% 
  mutate(x_nyelvek = ifelse(grepl('(; | - )', x_nyelvek), 'multi', x_nyelvek))

brewer$x_letezo_peldanyok_szama
weigths <- brewer %>%
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
weigths %>% print(n = Inf)
sum(weigths$pr)

sample <- NULL
for (i in 1:nrow(weigths)) {
  d <- slice(weigths, i)
  if (d$pr > 0) {
    # print(d)
    s <- brewer %>% 
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
    print(sprintf("%d) %d vs %d", i, d$pr, nrow(s)))
  }
}
sample

slice(dataFrame, 10)


slice_sample(.data, ..., n, prop, by = NULL, weight_by = NULL, replace = FALSE)

brewer %>% left_join(weigths, join_by(category, x_nyelvek)) %>% 
  select(id, category, x_nyelvek, x_letezo_peldanyok_szama, percent) %>% 
  slice_sample(n = 100, weight_by = percent) %>%
  ggplot(aes(x = x_letezo_peldanyok_szama)) +
  geom_bar(stat = "count")


brewer %>% left_join(weigths, join_by(category, x_nyelvek)) %>% 
  select(id, category, x_nyelvek, x_letezo_peldanyok_szama, percent) %>% 
  sample_n(100, weight = percent) %>%
  ggplot(aes(x = x_letezo_peldanyok_szama)) +
  geom_histogram()




%>% 
  mutate(num_rows = n()) %>% 
  select(category, x_nyelvek, num_rows) %>% 
  ungroup() %>% 
  mutate(sum1 = sum(num_rows)) %>% 


%>% 

  
    filter(num_rows > 6) %>% 
  # ungroup() %>%
  sample_n(100, weight = num_rows) %>%
  ungroup() %>% 
  # select(x_letezo_peldanyok_szama) %>% 
  ggplot(aes(x = x_nyelvek)) +
  geom_histogram(stat = 'count')


mtcars %>% 
  ggplot(aes(x = wt)) + 
  geom_histogram()

mtcars %>% 
  slice_sample(weight_by = wt, n = 20) %>% 
  ggplot(aes(x = wt)) + 
  geom_histogram()

#'-----------------
size.vec <- 2:4 
set.seed(250) 
tibble(x = rnbinom(nrow(brewer), size = 0.8, prob = 0.1)) %>% 
  ggplot(aes(x = x)) +
  geom_bar()

tibble(x = rnbinom(nrow(brewer), size = 0.2, prob = 0.08)) %>% 
  ggplot(aes(x = x)) +
  geom_bar()

real <- brewer %>%
  select(x = x_letezo_peldanyok_szama) %>% 
  count(x)

real2 <- tibble(x = 1:60) %>% 
  left_join(real, by = join_by(x)) %>%
  mutate(n = ifelse(is.na(n), 0, n))

sizes = seq(0.2, 1, 0.05)
probs = c(0.08, 0.12, 0.01)

diffs <- c()
ddd <- tibble(
  s = 0.0,
  p = 0.0,
  d = 0.0
)
ddd

for (s in sizes) {
  for (p in probs) {
    experimental <- tibble(
      x = rnbinom(nrow(brewer), size = s, prob = p) + 1
      ) %>% 
      count(x)
    experimental2 <- normalise(experimental)
    diff <- c(diffs, sum(abs(real2$n - experimental2$n)))
    ddd <- ddd %>% add_row(s = s, p = p, d = diff)
  }
}
ddd
ddd %>% 
  filter(d > 0) %>% 
  filter(d == min(d))

tibble(
  s = rep(sizes, length(probs)),
  p = rep(probs, length(sizes)),
  diff <- diffs
)

experimental <- tibble(x = rnbinom(nrow(brewer), size = 0.8, prob = 0.1) + 1) %>% 
  count(x)
experimental2 <- normalise(experimental)
sum(abs(real2$n - experimental2$n))

normalise <- function(.df) {
  tibble(x = 1:60) %>% 
    left_join(.df, by = join_by(x)) %>%
    mutate(n = ifelse(is.na(n), 0, n))  
}
