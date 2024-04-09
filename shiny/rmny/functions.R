get_distribution_by_language <- function(df, limit) {
  df2 <- df %>% 
    filter(!is.na(x_nyelvek)) %>%
    mutate(peldanyszam = x_letezo_peldanyok_szama) %>% 
    mutate(x_nyelvek = ifelse(x_nyelvek == 'magyar # - latin', 'latin; magyar', x_nyelvek)) %>% 
    mutate(x_nyelvek = ifelse(x_nyelvek == 'latin # - magyar', 'latin; magyar', x_nyelvek)) %>% 
    mutate(x_nyelvek = ifelse(x_nyelvek == 'latin # - német', 'latin; német', x_nyelvek)) %>% 
    mutate(x_nyelvek = ifelse(x_nyelvek == 'görög # - latin', 'görög; latin', x_nyelvek)) %>% 
    mutate(x_nyelvek = ifelse(x_nyelvek == 'latin # - görög', 'görög; latin', x_nyelvek))
  
  nyelvek <- df2 %>% 
    select(x_nyelvek, peldanyszam) %>%
    group_by(x_nyelvek) %>% 
    summarise(n = sum(peldanyszam)) %>% 
    arrange(desc(n)) %>% 
    head(n = 7) %>% 
    pull(x_nyelvek)
  print(nyelvek)
  
  df3 <- df2 %>% 
    select(x_nyelvek, peldanyszam) %>% 
    filter(x_nyelvek %in% nyelvek) %>% 
    mutate(x_nyelvek = factor(x_nyelvek, levels = nyelvek)) %>% 
    rename(category = x_nyelvek)
  
  plot_distribution(df3, limit, 'Fennmaradt példányok nyelvenként')
}

get_distribution_by_format <- function(df, limit) {
  print(head(df))
  df2 <- df %>% 
    filter(!is.na(x_formatum2)) %>% 
    mutate(formatum = ifelse(x_formatum2 %in% c(1, 2, 4, 8),
                             paste0(as.character(x_formatum2), '°'),
                             'egyéb')) %>% 
    mutate(formatum = factor(formatum, levels = c('1°', '2°', '4°', '8°', 'egyéb')),
           peldanyszam = x_letezo_peldanyok_szama)
  print(head(df))
  
  df2 %>% 
    select(formatum, peldanyszam) %>%
    group_by(formatum) %>% 
    summarise(n = sum(peldanyszam)) %>% 
    arrange(desc(n)) %>% 
    print(n = 20)
  
  df3 <- df2 %>% 
    select(formatum, peldanyszam) %>% 
    rename(category = formatum)
  
  plot_distribution(df3, limit, 'Fennmaradt példányok formátumokként')
}

get_distribution_by_city <- function(df, limit) {
  df2 <- df %>% 
    filter(!is.na(x_nyomtatasi_hely)) %>% 
    mutate(
      hely = x_nyomtatasi_hely,
      peldanyszam = x_letezo_peldanyok_szama
    )
  
  helyek <- df2 %>% 
    select(hely, peldanyszam) %>%
    group_by(hely) %>% 
    summarise(n = sum(peldanyszam)) %>% 
    arrange(desc(n)) %>% 
    head(n = 7) %>% 
    pull(hely)

  df3 <- df2 %>% 
    filter(hely %in% helyek) %>% 
    mutate(hely = factor(hely, levels = helyek)) %>% 
    select(hely, peldanyszam) %>% 
    rename(category = hely)
  
  plot_distribution(df3, limit, 'Fennmaradt példányok nyomtatási helyenként')
}

get_distribution_by_size <- function(df, limit) {
  df2 <- df %>% 
    filter(!is.na(ivszam)) %>% 
    filter(ivszam > 0) %>% 
    mutate(peldanyszam = x_letezo_peldanyok_szama)
  
  df3 <- df2 %>% 
    mutate(ivszam = ceiling(ivszam)) %>% 
    mutate(ivszam = 
             ifelse(ivszam <= 5, '1-5',
             ifelse(ivszam > 5 & ivszam <= 10, '6-10',
             ifelse(ivszam > 10 & ivszam <= 15, '11-15', 
             ifelse(ivszam > 15 & ivszam <= 20, '16-20', 
             ifelse(ivszam > 20 & ivszam <= 25, '21-25', 
             ifelse(ivszam > 25 & ivszam <= 30, '26-30', 
             ifelse(ivszam > 30 & ivszam <= 35, '31-35', 
             'egyéb')
           ))))))
    ) %>% 
    mutate(ivszam = factor(
      ivszam,
      levels = c('1-5', '6-10', '11-15', '16-20', '21-25', '26-30',
                 '31-35', 'egyéb'))) %>% 
    select(ivszam, peldanyszam) %>% 
    rename(category = ivszam)
    
  plot_distribution(df3, limit, 'Fennmaradt példányok ívméret szerint')
}

get_distribution_by_genre <- function(df, limit) {
  df2 <- df %>% 
    filter(!is.na(x_kiadvanytipus)) %>% 
    mutate(
      mufaj = x_kiadvanytipus,
      peldanyszam = x_letezo_peldanyok_szama
    )
  
  mufajok <- df2 %>% 
    select(mufaj, peldanyszam) %>%
    group_by(mufaj) %>% 
    summarise(n = sum(peldanyszam)) %>% 
    arrange(desc(n)) %>% 
    pull(mufaj)
  
  df3 <- df2 %>% 
    mutate(mufaj = factor(mufaj, levels = mufajok)) %>% 
    select(mufaj, peldanyszam) %>% 
    rename(category = mufaj)
  
  plot_distribution(df3, limit, 'Fennmaradt példányok kiadványtípusonként')
}

plot_distribution <- function(df, limit, plot_title) {
  print('plot_distribution')
  print(head(df))
  df2 <- df %>% 
    mutate(
      peldanyszam = ifelse(peldanyszam > limit, limit, peldanyszam),
      fill_color = ifelse(peldanyszam == 0 | peldanyszam == 50, 'maroon', 'cornflowerblue')
    )
  print('df2')
  print(df2, n = Inf)
  df2 %>% 
    ggplot(aes(x = peldanyszam, fill = fill_color)) +
    geom_histogram(
      bins = limit + 1,
      show.legend = FALSE
    ) +
    facet_wrap(vars(category), ncol = 1) +
    theme_bw() +
    labs(
      title = plot_title,
      x = 'Példányok száma',
      y = 'RMNY tételek száma',
    ) +
    scale_y_log10() +
    scale_fill_manual(labels = c('cornflowerblue', 'maroon'), values = c('cornflowerblue', 'maroon'))
}