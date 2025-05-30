library(tidyverse)
library(patchwork)
library(scatterpie)
library(maptools)

selected_countries <- c('Hungary', 'Slovakia', 'Romania', 'Austria', 'Slovenia',
                        'Croatia', 'Serbia')

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
# view(publications)

place_name_dir <- '~/git/pkiraly/analysing-nat-libs/place-names/data_internal'
# coords <- read_csv(paste0('/home/pkiraly/git/pkiraly/patterns-of-translations/data/cities-geocoded.csv')
coords <- read_csv(paste0(place_name_dir, '/coord.csv'))
synonyms <- read_csv(paste0(place_name_dir, '/place-synonyms-normalized.csv'))

coords %>% select(geoid) %>% 
  group_by(geoid) %>% 
  summarise(n = n()) %>% 
  filter(n != 1)

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
  filter(country != 'United States') %>% 
  filter(country %in% selected_countries)

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
  select(year, place, count, country, lat, long) %>% 
  filter(country %in% selected_countries)

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

map.europe <- map_data("world")
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
  yearly_publications <- geo_pub %>% filter(year == this_year) %>%
    select(-c(year, country))
  yearly_publications
  yearly_libraries <- geo_libraries %>% filter(year == this_year) %>%
    select(-c(year, country))
  yearly_libraries
  
  yearly <- yearly_publications %>% 
    full_join(yearly_libraries, join_by(lat, long)) %>% 
    mutate(place.x = ifelse(!is.na(place.x), place.x, place.y)) %>% 
    select(-c(place.y)) %>% 
    rename(place = place.x, pubs = count.x, libs = count.y) %>% 
    mutate(
      pubs = ifelse(is.na(pubs), 0, pubs),
      libs = ifelse(is.na(libs), 0, libs),
      shift = ifelse(pubs == 0 | libs == 0, 0, 0.1),
      r1 = log1p(pubs) * .2, 
      r2 = log1p(libs) * .2, 
    )
  print(paste(this_year, dim(yearly)[1]))
  
  # basemap +
  #   geom_scatterpie(
  #     data = yearly,
  #     aes(x=long, y=lat, group = place, r = radius),
  #     cols = c('pubs', 'libs'))
  
  pubplot <- basemap +
    geom_point(
      data = yearly,
      aes(x = long - shift, y = lat, size = pubs),
      color = "maroon",
      alpha = .5) +
    geom_point(
      data = yearly,
      aes(x = long + shift, y = lat, size = libs),
      color = "cornflowerblue",
      alpha = .5) +
    geom_text(
      data = yearly,
      mapping = aes(x = long, y = lat, label = place, 
                    ),
      color = ifelse(yearly$pubs != 0, 'maroon', 'cornflowerblue'),
      nudge_y = -0.1,
      size = 3
    ) +
    scale_size_continuous(limits = c(1, maxcount), name = 'nr.') +
    ggtitle(paste(this_year, 'nyomdahely-őrzőhely / place of publication-place of custody'))

  ggsave(paste0('img/mixed/', this_year, '.png'), pubplot, 
         width = imageWidth, height = 6, units = 'in', dpi = 300)
}
