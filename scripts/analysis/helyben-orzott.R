library(tidyverse)
library(patchwork)
library(scatterpie)
library(maptools)

place_name_dir <- '~/git/pkiraly/analysing-nat-libs/place-names/data_internal'
selected_countries <- c(
  'Hungary', 'Slovakia', 'Romania', 'Austria', 'Slovenia',
  'Croatia', 'Serbia')

df4 <- read_csv('rmny4.csv')
df5 <- read_csv('rmny5.csv')
df5 <- df5 %>% mutate(`01xIdö` = as.character(`01xIdö`))
df <- bind_rows(df4, df5)

coords <- read_csv(paste0(place_name_dir, '/coord.csv'))
coords_hu <- read_csv(paste0(place_name_dir, '/coord.hu.csv'))
synonyms <- read_csv(paste0(place_name_dir, '/place-synonyms-normalized.csv'))

df2 <- df %>% 
  select(`01Sorszám`, `01xHely`, `cities`, `olimCities`) %>% 
  rename(id = `01Sorszám`, place = `01xHely`)

libraries <- df2 %>%
  select(id, cities) %>% 
  filter(!is.na(cities)) %>% 
  separate_longer_delim(cities, ", ") %>% 
  separate(cities, c('city', 'count'), '=')

# synonyms %>% 
#   select(original) %>% 
#   group_by(original) %>% 
#   summarise(n = n()) %>% 
#   filter(n > 1) %>% 
#   view()

libraries_normalized <- libraries %>% 
  left_join(synonyms, by = c("city" = "original")) %>% 
  select(-factor) %>% 
  mutate(city = ifelse(is.na(normalized), city, normalized)) %>% 
  select(-normalized)

olim <- df2 %>%
  select(id, olimCities) %>% 
  filter(!is.na(olimCities)) %>% 
  separate_longer_delim(olimCities, ", ") %>% 
  rename(olim = olimCities)

olim_normalized <- olim %>% 
  left_join(synonyms, by = c("olim" = "original")) %>% 
  select(-factor) %>% 
  mutate(olim = ifelse(is.na(normalized), olim, normalized)) %>% 
  select(-normalized)

pub_normalized <- df2 %>% 
  select(id, place) %>% 
  left_join(synonyms, by = c("place" = "original")) %>% 
  select(-factor) %>% 
  mutate(place = ifelse(is.na(normalized), place, normalized)) %>% 
  select(-normalized)

local <- pub_normalized %>% 
  full_join(libraries_normalized, join_by(id)) %>% 
  mutate(same = place == city)

locally_saved <- local %>% 
  filter(same == TRUE) %>% 
  group_by(place) %>% 
  summarise(n = n(), .groups = 'drop')

pub_by_place <- pub_normalized %>% 
  group_by(place) %>% 
  summarise(n = n(), .groups = 'drop')

final <- pub_by_place %>% 
  left_join(locally_saved, join_by(place)) %>% 
  rename(all = n.x, locally_saved = n.y) %>% 
  mutate(
    locally_saved = ifelse(is.na(locally_saved), 0, locally_saved),
    saved = locally_saved / all * 100,
    lost = 100-saved
  ) %>% 
  arrange(desc(saved)) %>% 
  left_join(coords, by = c("place" = "city")) %>% 
  filter(!is.na(geoid)) %>% 
  filter(country %in% selected_countries) %>% 
  select(-c(geoid, name, country)) %>% 
  left_join(coords_hu, by = c('place' = 'city')) %>% 
  mutate(place = ifelse(is.na(hu), place, hu)) %>% 
  select(-hu)

final

minx <- min(final$long) - 0.2
maxx <- max(final$long) + 0.2
miny <- min(final$lat) - 0.2
maxy <- max(final$lat) + 0.2

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

ggplot() +
  geom_polygon(
    data = map.europe,
    aes(x = long, y = lat, group = group),
    fill = '#ffffff',
    colour = '#999999'
  ) + 
  coord_map(xlim = c(minx, maxx), ylim = c(miny, maxy)) +
  geom_scatterpie(
    aes(x=long, y=lat, group=place, r=log2(all)/20),
    data=final,
    alpha = 0.4,
    cols=c('saved', 'lost'),
    color=NA
  ) +
  geom_text(
    data = final,
    mapping = aes(x = long, y = lat, 
                  label = place
    ),
    nudge_y = -0.1,
    size = 3
  ) +
  geom_text(
    data = final,
    mapping = aes(x = long, y = lat, 
                  label = paste0('(', all, ')')
    ),
    color = '#666666',
    nudge_y = -0.25,
    size = 3
  ) +
  geom_scatterpie_legend(
    radius = log2(final$all)/20, 
    x = 16.5, y = 46,
    labeller=function(x) 2^(x*20)) +
  labs(
    title='Régi Magyarországi Nyomtatványok 1656-1685',
    subtitle = 'Milyen arányban találhatók meg helyi gyűjteményben az itt nyomtatott kiadványok?',
    # caption = 'A diagramok mérete kiadványszám log2 értékét tükrözi, ezért a\nkiadványszámok tényleges aránya nagyobb a diagrammokénál'
  ) +
  scale_fill_discrete(name = 'megtalálható?', 
                      labels = c('igen', 'nem')) +
  theme(
    # legend.position = 'none',
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    # legend.title = element_text(size=rel(0.5)), 
    # legend.text = element_text(size=rel(0.5))
  )


ggsave(paste0('img/helyben.png'), 
       width = 9, height = 6, units = 'in', dpi = 300)

