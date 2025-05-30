library(tidyverse)

df4 <- read_csv('rmny4.csv')
df4 <- df4 %>% select(`01Sorszám`, `01xHely`, `01xIdö`) %>% 
  rename(id = `01Sorszám`, year = `01xIdö`, place = `01xHely`) %>% 
  mutate(year = as.integer(year))
df4 %>% 
  filter(is.na(place) | is.na(year)) %>% 
  select(id) %>% 
  unlist(use.names = FALSE)
df4 <- df4 %>% select(-id)
df4

df5 <- read_csv('rmny5.csv')
df5 <- df5 %>% select(`01Sorszám`, `01xHely`, `01xIdö`) %>% 
  rename(id = `01Sorszám`, year = `01xIdö`, place = `01xHely`) %>% 
  mutate(year = as.integer(year))
df5 %>% 
  filter(is.na(place) | is.na(year)) %>% 
  select(id) %>% 
  unlist(use.names = FALSE)
df5 <- df5 %>% select(-id)

# df5 <- df5 %>% select(location, year) %>% filter(!is.na(location)) %>% 
#  rename(place = location)
df5

df3 <- read_csv('data/rmny-1-3.v2.2024-01-29.csv')
df3 <- df3 %>% select(`01xHely`, `01xIdö`) %>% 
  rename(year = `01xIdö`, place = `01xHely`) %>% 
  mutate(year = as.integer(year))

df3
df <- bind_rows(df3, df4, df5)
df
yplc <- df %>% 
  group_by(year, place) %>% 
  summarise(count = n(), .groups = "drop")

# view(yplc)

place_name_dir <- '~/git/pkiraly/analysing-nat-libs/place-names/data_internal'
# coords <- read_csv(paste0('/home/pkiraly/git/pkiraly/patterns-of-translations/data/cities-geocoded.csv')
coords <- read_csv(paste0(place_name_dir, '/coord.csv'))
synonyms <- read_csv(paste0(place_name_dir, '/place-synonyms-normalized.csv'))

yplc %>% 
  left_join(synonyms, by = c("place" = "original")) %>% 
  select(-factor) %>% 
  mutate(normalized = ifelse(is.na(normalized), place, normalized)) %>% 
  # filter(!is.na(normalized)) %>% 
  left_join(coords, by = c("normalized" = "city")) %>% 
  filter(is.na(geoid)) %>% 
  view()

geodf <- yplc %>% 
  left_join(synonyms, by = c("place" = "original")) %>% 
  select(-factor) %>% 
  mutate(normalized = ifelse(is.na(normalized), place, normalized)) %>% 
  # filter(!is.na(normalized)) %>% 
  left_join(coords, by = c("normalized" = "city")) %>% 
  filter(!is.na(geoid)) %>% 
  filter(!is.na(year)) %>%
  filter(year != "16ö8-1643?") %>% 
  mutate(year = as.numeric(year)) %>% 
  filter(!is.na(year)) %>%
  select(year, place, count, country, lat, long)

map.europe <- map_data("world")
geodf %>% 
  filter(is.na(long))
maxcount <- max(geodf$count)

minx <- min(geodf$long) - 0.1
maxx <- max(geodf$long) + 0.1
miny <- min(geodf$lat) - 0.1
maxy <- max(geodf$lat) + 0.1

print(paste(minx, maxx, miny, maxy))

years <- geodf %>% select(year) %>% distinct() %>% unlist(use.names = FALSE)

basemap <- ggplot() +
  geom_polygon(
    data = map.europe,
    aes(x = long, y = lat, group = group),
    fill = '#ffffff',
    colour = '#999999'
  ) +
  coord_cartesian(xlim = c(minx, maxx), ylim = c(miny, maxy)) +
  theme(
    # legend.position = 'none',
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    legend.title = element_text(size=rel(0.5)), 
    legend.text = element_text(size=rel(0.5))
  )

for (this_year in years) {
  yeardf <- geodf %>% filter(year == this_year)

  print(paste(this_year, dim(yeardf)[1]))
  yearplot <- basemap +
    geom_point(
      data = yeardf,
      aes(x = long, y = lat, size = count),
      color = "red",
      alpha = .8) +
    geom_text(
      data = yeardf,
      mapping = aes(x = long, y = lat, label = place),
      nudge_y = -0.05,
      size = 1.8
    ) +
    scale_size_continuous(limits = c(1, maxcount), name = 'nr.') +
    ggtitle(this_year)

  ggsave(paste0('img/publications/', this_year, '.png'), yearplot, 
         width = 5.5, height = 4, units = 'in', dpi = 300)
}
