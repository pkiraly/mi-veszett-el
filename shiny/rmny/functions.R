get_mixed_distribution <- function(df, limit, type1, type2) {
  
  fun1 <- get(get_field_by_name(type1)$data_fn)
  fd1 <- get_field_by_name(type1)$field
  # df2 <- fun1(df)
  
  fun2 <- get(get_field_by_name(type2)$data_fn)
  fd2 <- get_field_by_name(type2)$field
  df3 <- df %>% 
    fun1() %>% fun2() %>% 
    select(peldanyszam, fd1, fd2) %>% 
    rename(category1 = fd1, category2 = fd2)
  print(head(df3))
  biplot_distribution(df3, limit, paste(type1, 'és', type2, 'metszeteinek eloszlása'))
}

get_field_by_name <- function(field_name) {
  df <- tribble(
    ~name,             ~field,              ~data_fn,
    'nyelv',           'x_nyelvek',         'filter_language',
    'formátum',        'x_formatum2',       'filter_format',
    'nyomtatás helye', 'x_nyomtatasi_hely', 'filter_city',
    'méret',           'ivszam',            'filter_size',
    'műfaj',           'x_kiadvanytipus',   'filter_genre'
  )
  df %>% filter(name == field_name)
}

filter_language <- function(df) {
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
  
  df2 %>% 
    filter(x_nyelvek %in% nyelvek) %>% 
    mutate(x_nyelvek = factor(x_nyelvek, levels = nyelvek))
}

get_distribution_by_language <- function(df, limit) {
  df3 <- filter_language(df) %>% 
    select(x_nyelvek, peldanyszam) %>%
    rename(category = x_nyelvek)
    
  plot_distribution(df3, limit, 'Fennmaradt példányok nyelvenként')
}

filter_format <- function(df) {
  df %>% 
    filter(!is.na(x_formatum2)) %>% 
    mutate(x_formatum2 = ifelse(x_formatum2 %in% c(1, 2, 4, 8),
                             paste0(as.character(x_formatum2), '°'),
                             'egyéb')) %>% 
    mutate(
      x_formatum2 = factor(formatum, levels = c('1°', '2°', '4°', '8°', 'egyéb')),
      peldanyszam = x_letezo_peldanyok_szama
    )
}

get_distribution_by_format <- function(df, limit) {
  df3 <- filter_format(df) %>% 
    select(x_formatum2, peldanyszam) %>% 
    rename(category = x_formatum2)
  
  plot_distribution(df3, limit, 'Fennmaradt példányok formátumokként')
}

filter_city <- function(df) {
  df2 <- df %>% 
    filter(!is.na(x_nyomtatasi_hely)) %>% 
    mutate(peldanyszam = x_letezo_peldanyok_szama)
  
  helyek <- df2 %>% 
    select(x_nyomtatasi_hely, peldanyszam) %>%
    group_by(x_nyomtatasi_hely) %>% 
    summarise(n = sum(peldanyszam)) %>% 
    arrange(desc(n)) %>% 
    head(n = 7) %>% 
    pull(x_nyomtatasi_hely)
  
  df2 %>% 
    filter(x_nyomtatasi_hely %in% helyek) %>% 
    mutate(x_nyomtatasi_hely = factor(x_nyomtatasi_hely, levels = helyek))
}

get_distribution_by_city <- function(df, limit) {
  df3 <- df %>%
    filter_city() %>% 
    select(x_nyomtatasi_hely, peldanyszam) %>% 
    rename(category = x_nyomtatasi_hely)
  
  plot_distribution(df3, limit, 'Fennmaradt példányok nyomtatási helyenként')
}

filter_size <- function(df) {
  df %>% 
    filter(!is.na(ivszam)) %>% 
    filter(ivszam > 0) %>% 
    mutate(peldanyszam = x_letezo_peldanyok_szama) %>% 
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
                 '31-35', 'egyéb')))
}

get_distribution_by_size <- function(df, limit) {
  df3 <- df %>% 
    filter_size() %>% 
    select(ivszam, peldanyszam) %>% 
    rename(category = ivszam)
    
  plot_distribution(df3, limit, 'Fennmaradt példányok ívméret szerint')
}

filter_genre <- function(df) {
  df2 <- df %>% 
    filter(!is.na(x_kiadvanytipus)) %>% 
    mutate(peldanyszam = x_letezo_peldanyok_szama)
  
  mufajok <- df2 %>% 
    select(x_kiadvanytipus, peldanyszam) %>%
    group_by(x_kiadvanytipus) %>% 
    summarise(n = sum(peldanyszam)) %>% 
    arrange(desc(n)) %>% 
    pull(x_kiadvanytipus)
  
  df2 %>% 
    mutate(x_kiadvanytipus = factor(x_kiadvanytipus, levels = mufajok)) 
}

get_distribution_by_genre <- function(df, limit) {
  df3 <- df %>% 
    filter_genre() %>% 
    select(x_kiadvanytipus, peldanyszam) %>% 
    rename(category = x_kiadvanytipus)
  
  plot_distribution(df3, limit, 'Fennmaradt példányok kiadványtípusonként')
}

plot_distribution <- function(df, limit, plot_title) {
  df2 <- df %>% 
    mutate(
      peldanyszam = ifelse(peldanyszam > limit, limit, peldanyszam),
      fill_color = ifelse(peldanyszam == 0 | peldanyszam == 50, 'maroon', 'cornflowerblue')
    )

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

biplot_distribution <- function(df, limit, plot_title) {
  nr <- df %>% distinct(category1) %>% nrow()
  print(nr)
  
  df2 <- df %>% 
    mutate(
      peldanyszam = ifelse(peldanyszam > limit, limit, peldanyszam),
      fill_color = ifelse(peldanyszam == 0 | peldanyszam == 50, 'maroon', 'cornflowerblue')
    )
  
  df2 %>% 
    ggplot(aes(x = peldanyszam, fill = fill_color)) +
    geom_histogram(
      bins = limit + 1,
      show.legend = FALSE
    ) +
    # facet_wrap(category1 ~ category2, ncol = nr) +
    facet_grid(cols = vars(category1), rows = vars(category2)) +
    theme_bw() +
    labs(
      title = plot_title,
      x = 'Példányok száma',
      y = 'RMNY tételek száma',
    ) +
    scale_y_log10() +
    scale_fill_manual(labels = c('cornflowerblue', 'maroon'), values = c('cornflowerblue', 'maroon'))
}