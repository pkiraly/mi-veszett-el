library(tidyverse)
# library(patchwork)
# library(scatterpie)
# library(maptools)
library(stringr)
library(gsubfn)

ivmeret <- 600 * 460
calculateSum <- function(text) {
  a <- str_split(text, ' ')
  c <- c()
  for (b in a) {
    c <- c(c, sum(as.numeric(b), na.rm = TRUE))
  }
  c
}

addIvszam <- function(fileName) {
  print(paste('processing ', fileName))
  # df4 <- read_csv(paste0(fileName, '.csv'))

  if (fileName == 'data/rmny-1-3.with-cities') {
    df4 <- read_csv(paste0(fileName, '.csv'),
      col_types = cols(
        `Tárgyi hungarikum` = col_character(),
        `xTérkép-map` = col_character()
      ),
      show_col_types = FALSE
    )
    problems()
    
    df4_id <- df4 %>%
      mutate(
        id2 = ifelse(
          is.na(`01Sorszám_RMNY-S`),
          paste(id, `00Bibliográfia`, `01Sorszám_RMNY`, sep = '|'),
          paste(id, `00Bibliográfia`, `01Sorszám_RMNY`, `01Sorszám_RMNY-S`, sep = '|')
        )
      )
  } else {
    df4 <- read_csv(paste0(fileName, '.csv'), show_col_types = FALSE)
    df4_id <- df4 %>% 
      mutate(id2 = `01Sorszám`)
  }

  df <- df4_id %>% 
    rename(
      terjedelem = `08Terjedelem`,
      formatum = `09Formátum`
    ) %>% 
    select(id2, terjedelem, formatum) %>% 
    filter(!is.na(terjedelem) & !is.na(formatum))

  df_ivszam <- df %>% 
    mutate(
      tab = ifelse(
        str_detect(terjedelem, " \\+ \\[?(\\d+)\\]? tab\\."),
        gsub("^.* \\+ \\[?(\\d+)\\]? tab\\..*$", "\\1", terjedelem),
        0
      ),
      t = ifelse(
        str_detect(terjedelem, " \\+ \\[?(\\d+)\\]? tab\\."),
        gsub(" \\+ \\[?(\\d+)\\]? tab\\.", "", terjedelem),
        terjedelem
      ),
      tab = ifelse(
        str_detect(t, "\\[?(\\d+)\\]? tab\\. \\+ "),
        gsub("^.*\\[?(\\d+)\\]? tab\\. \\+ .*$", "\\1", t),
        tab
      ),
      t = ifelse(
        str_detect(t, "\\[?(\\d+)\\]? tab\\. \\+ "),
        gsub("\\[?(\\d+)\\]? tab\\. \\+ ", "", t),
        t
      ),
      tab = as.numeric(tab),
      unit = ifelse(
        str_detect(terjedelem, " pag\\.$"),
        1,
        2
      ),
      t = gsub(" \\+ \\?$", "", t),
      t = gsub(" (fol|pag)\\.$", "", t),
      t = gsub("\\[(\\d+)\\]", "\\1", t),
      t = gsub("\\d+ \\[recte (\\d+)\\]", "\\1", t),
      t = gsub("\\d+ \\(recte (\\d+)\\)", "\\1", t),
      t = gsub("\\[!\\]", "", t),
      t = gsubfn(
        "(\\d+)-(\\d+)",
        function(f, s) as.numeric(s) - as.numeric(f), 
        t,
        perl=TRUE
      ),
      t = gsub("[,;\\.\\+\\?\\(\\)]", "", t),
      t = gsub("\\[|\\]", "", t),
      t = gsub(" +", " ", t),
      n = ifelse(
        str_detect(t, "[^\\d ]"),
        0,
        t
      ),
      b = calculateSum(n),
      pages = unit * (b + tab),
    
      # formatum
      f = formatum,
      f = gsub(' ?\\+ ?\\?', '', f),
      f = gsub('c(r|a)\\. ', '', f),
      f = gsub("\\[|\\]", "", f),
      f = gsub('(keskeny|forma oblonga) ', '', f),
      f = gsub('\\d\\d\\d-(\\d\\d\\d)', '\\1', f),
      f = gsub('(\\d\\d\\d)\\?', '\\1', f),
    
      f2 = ifelse(
        str_detect(f, '^.*?\\d+ [×x] \\d+ (c|m)m.*$'),
        gsubfn(
          "^.*?(\\d+) [×x] (\\d+) (c|m)m.*$",
          function(a, b, c) {
            i <- ifelse(c == 'm', 1, 100)
            n <- round(ivmeret / (as.numeric(a) * as.numeric(b) * i))
            return(n)
          }, 
          f,
          perl=TRUE
        ),
        gsubfn(
          '^(\\d+)°.*',
          function(a) as.numeric(a) * 2, 
          f,
          perl=TRUE
        )
      ),
      f3 = str_detect(f2, '^\\d+$'),
      f2 = ifelse(str_detect(f2, '^\\d+$'), f2, 1),
      f2 = as.numeric(f2),
      f2 = ifelse(f2 == 0, 1, f2),
      `09xFormátum2` = ceiling(2^(log2(f2)-1)),
      ivszam = pages / f2
    ) %>% 
    rename(`08xTerjedelem` = pages, oldal_per_iv = f2)

  df_ivszam <- df_ivszam %>% 
    select(id2, `08xTerjedelem`, `09xFormátum2`, oldal_per_iv, ivszam)

  df4_id %>% count(id2) %>% filter(n > 1)

  df4_extra <- df4_id %>% 
    left_join(df_ivszam, join_by(id2)) %>% 
    select(-id2)
  # view(df4_extra)
  outFile <- paste0(fileName, '.with-ivszam.csv')
  print(paste('export to', outFile))
  write_csv(df4_extra, paste0(fileName, '.with-ivszam.csv'), na = '')
  problems()
}

fileNames <- c('data/rmny-1-3.with-cities', 'data/rmny4', 'data/rmny5')
for (fileName in fileNames) {
  addIvszam(fileName)
}
