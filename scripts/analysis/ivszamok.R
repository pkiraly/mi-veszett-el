library(tidyverse)

df3 <- read_csv('rmny1-3.ivszam.csv')
df3 <- df3 %>% mutate(id2 = ifelse(is.na(`01Sorszám_RMNY-S`),
                    `01Sorszám_RMNY`,
                    paste(`01Sorszám_RMNY`, `01Sorszám_RMNY-S`, sep = ''))) %>% 
  select(`01xIdö`, `01xHely`, ivszam)
df3 

df4 <- read_csv('rmny4.ivszam.csv')
df4
df5 <- read_csv('rmny5.ivszam.csv')
df5 <- df5 %>% mutate(`01xIdö` = as.character(`01xIdö`))
df <- bind_rows(df4, df5)
df <- df %>% mutate(ivszam = ifelse(is.infinite(ivszam), 0, ivszam)) %>% 
  select(`01xIdö`, `01xHely`, ivszam)
view(df)

df <- bind_rows(df3, df)

names(df)
top12 <- df %>% 
  select(`01xHely`, ivszam) %>% 
  filter(!is.na(`01xHely`)) %>% 
  filter(!(`01xHely` %in% c('Velence', 'Amszterdam', 'Frankfurt am Main (Franckfurt am Mayn) D', 'Bázel', 'Lyon'))) %>% 
  group_by(`01xHely`) %>% 
  summarise(
    db = n(),
    iv = sum(ivszam, na.rm = TRUE)
  ) %>% 
  arrange(desc(iv)) %>% 
  head(n = 12) %>% 
  select(`01xHely`)

df %>%
  filter(`01xHely` == 'Detrekő')
hely <- factor(top12$`01xHely`, levels = top12$`01xHely`)
hely
df %>% 
  filter(ivszam <= 2) %>% 
  right_join(top12, join_by(`01xHely`)) %>%
  mutate(hely = factor(`01xHely`, levels = hely)) %>% 
  ggplot(aes(x = ivszam)) +
  geom_histogram(bin = 30, color = 'cornflowerblue') +
  facet_wrap(~hely) +
  # scale_x_sqrt() +
  # scale_y_sqrt() +
  theme_bw() +
  labs(
    title = 'A 12 legnagyobb ívszámot nyomtató város',
    subtitle = '1656-1685 (RMNY 4-5.)',
    x = 'ívszám',
    y = 'nyomtatványszám'
  )

df %>% 
  filter(ivszam > 100) %>% 
  right_join(top12, join_by(`01xHely`)) %>%
  mutate(
    ido = as.numeric(`01xIdö`),
    hely = factor(`01xHely`, levels = hely)
  ) %>% 
  group_by(hely, ido) %>% 
  summarise(
    ivszam = sum(ivszam, na.rm = TRUE),
    .groups = 'drop'
  ) %>% 
  ggplot(aes(y = ivszam, x = ido)) +
  geom_point(color = 'cornflowerblue', alpha = 0.8) +
  # geom_histogram(bin = 30, color = 'cornflowerblue') +
  facet_wrap(~hely)
  

ggsave(paste0('img/ivszamok.png'), 
       width = 9, height = 6, units = 'in', dpi = 300)
