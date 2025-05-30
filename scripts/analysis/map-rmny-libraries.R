library(tidyverse)
library(patchwork)

df4 <- read_csv('rmny4.csv')
df5 <- read_csv('rmny5.csv')
df5 <- df5 %>% mutate(`01xIdö` = as.character(`01xIdö`))
df <- bind_rows(df4, df5)

libraries <- df %>% 
  rename(year = `01xIdö`, place = cities) %>% 
  select(year, place) %>% 
  filter(!is.na(place)) %>% 
  # create new rows for each places
  separate_longer_delim(place, ", ") %>% 
  # create new columns
  separate(place, c('place', 'count1'), '=') %>% 
  mutate(count1 = as.numeric(count1)) %>% 
  group_by(year, place) %>% 
  summarise(count = sum(count1), .groups = 'drop')

publications <- df %>% select(`01Sorszám`, `01xHely`, `01xIdö`) %>% 
  rename(id = `01Sorszám`, year = `01xIdö`, place = `01xHely`) %>% 
  mutate(year = as.integer(year)) %>% 
  group_by(year, place) %>% 
  summarise(count = n(), .groups = "drop")

place_name_dir <- '~/git/pkiraly/analysing-nat-libs/place-names/data_internal'
# coords <- read_csv(paste0('/home/pkiraly/git/pkiraly/patterns-of-translations/data/cities-geocoded.csv')
coords <- read_csv(paste0(place_name_dir, '/coord.csv'))
synonyms <- read_csv(paste0(place_name_dir, '/place-synonyms-normalized.csv'))

# libraries %>% 
#   left_join(synonyms, by = c("place" = "original")) %>% 
#   select(-factor) %>% 
#   mutate(normalized = ifelse(is.na(normalized), place, normalized)) %>% 
#   # filter(!is.na(normalized)) %>% 
#   left_join(coords, by = c("normalized" = "city")) %>% 
#   filter(is.na(geoid)) %>% 
#   view()

geo_libraries <- libraries %>% 
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
  select(year, place, count, country, lat, long) %>% 
  filter(country != 'United States')

geo_pub <- publications %>% 
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

# map.europe <- map_data("world")
geo_libraries %>% 
  filter(is.na(long))
maxcount <- max(geo_libraries$count)
fullMap <- TRUE
                              # if Nizgij Novgorod is removed 
minx <- ifelse(fullMap, min(geo_libraries$long) - 0.1, 5.0)
maxx <- ifelse(fullMap, max(geo_libraries$long) + 0.1, max(geo_pub$long) + 0.1) # 26.1 
miny <- ifelse(fullMap, min(geo_libraries$lat) - 0.1, 45.0)
maxy <- ifelse(fullMap, max(geo_libraries$lat) + 0.1, max(geo_pub$lat) + 0.1)  # 54.1
imageWidth <- ifelse(fullMap, 8, 6)
print(paste(minx, maxx, miny, maxy))

years <- geo_libraries %>% select(year) %>% distinct() %>% unlist(use.names = FALSE)

basemap <- ggplot() +
  geom_polygon(
    data = map.europe,
    aes(x = long, y = lat, group = group),
    fill = '#ffffff',
    colour = '#999999'
  ) +
  coord_cartesian(xlim = c(minx, maxx), ylim = c(miny, maxy)) +
  theme(
    legend.position = 'none',
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    # legend.title = element_text(size=rel(0.5)), 
    # legend.text = element_text(size=rel(0.5))
  )

for (this_year in years) {
  yearly_publications <- geo_pub %>% filter(year == this_year)
  yearly_libraries <- geo_libraries %>% filter(year == this_year)
  
  print(paste(this_year, dim(yearly_libraries)[1]))

  pubplot <- basemap +
    geom_point(
      data = yearly_publications,
      aes(x = long, y = lat, size = count),
      color = "maroon",
      alpha = .8) +
    geom_text(
      data = yearly_publications,
      mapping = aes(x = long, y = lat, label = place),
      nudge_y = -0.05,
      size = 1.8
    ) +
    scale_size_continuous(limits = c(1, maxcount), name = 'nr.') +
    ggtitle(paste(this_year, 'nyomdahely / place of publication'))

  libplot <- basemap +
    geom_point(
      data = yearly_libraries,
      aes(x = long, y = lat, size = count),
      color = "cornflowerblue",
      alpha = .8) +
    geom_text(
      data = yearly_libraries,
      mapping = aes(x = long, y = lat, label = place),
      nudge_y = -0.05,
      size = 1.8
    ) +
    scale_size_continuous(limits = c(1, maxcount), name = 'nr.') +
    ggtitle(paste(this_year, 'őrzőhely / place of custody'))
  
  yearplot <- pubplot / libplot + plot_layout(heights = c(3, 3), ) +
    plot_annotation(
      title = 'Régi Magyarországi Nyomtatványok / Early Hungarian Printings (1656-1685)')

  ggsave(paste0('img/libraries/', this_year, '.png'), yearplot, 
         width = imageWidth, height = 8, units = 'in', dpi = 300)
}
