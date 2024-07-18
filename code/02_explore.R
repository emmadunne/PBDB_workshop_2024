# ******************************************************
#
#   PBDB Workshop 2024
#
#   Day 4 | Thursday, July 18th
#
#   Emma Dunne    (emma.dunne@fau.de)
#   Bethany Allen (bethany.allen@bsse.ethz.ch)
# ______________________________________________________
#
#   2. Exploring cleaned PBDB data before analyses
# 
# ******************************************************


## Packages used in this script
# library(tidyverse)
# library(geoscale) # for plotting with the geological time scale on the x-axis (uses base R syntax)
# library(viridis) # for colour scales



# 1. Simple explore -------------------------------------------------------

## Let's start by simply exploring the cleaned dataset

## How many (valid) species do we have?
length(unique(occ_data_sp$accepted_name))

## What species have the greatest number of occurrences?
n_occs <- occ_data_sp %>% 
  count(accepted_name) %>% 
  arrange(desc(n))
n_occs




# 2. Sampling proxy counts ---------------------------------------------------


## Let's explore sampling patterns!
## First we'll calculate counts of sampling proxies and plot these alongside raw diversity

# Taxa per interval 
count_taxa <- vector("numeric") # create empty vector for the loop below to populate
for (i in 1:nrow(intervals)) { # for-loop to count each taxon that appears in each interval
  out <- subset(occ_data, max_ma > intervals[i,]$min_ma & min_ma < intervals[i,]$max_ma) # uses our intervals dataframe
  count_taxa[i] <- (length(unique(out$accepted_name)))
  print(count_taxa[i])
}

# Collections per interval
count_colls <- vector("numeric")
for (i in 1:nrow(intervals)) {
  out <- subset(occ_data, max_ma > intervals[i,]$min_ma & min_ma < intervals[i,]$max_ma)
  count_colls[i] <- (length(unique(out$collection_no)))
  print(count_colls[i])
}

# Formations per interval
count_formations <- vector("numeric")
for (i in 1:nrow(intervals)) {
  out <- subset(occ_data, max_ma > intervals[i,]$min_ma & min_ma < intervals[i,]$max_ma)
  count_formations[i] <- (length(unique(out$formation)))
  print(count_formations[i])
}


## For equal-area gird cells, I would recommend the package 'icosa' (Kocsis, 2017)
## For more info see: http://cran.nexr.com/web/packages/icosa/vignettes/icosaIntroShort.pdf


## Gather the proxy information together in a new dataframe for plotting:
proxy_counts <- data.frame(intervals$interval_name, intervals$mid_ma, count_taxa, count_colls, count_formations)
## Rename the columns for ease:
proxy_counts <- rename(proxy_counts, 
                       "interval_name" = "intervals.interval_name", 
                       "mid_ma" = "intervals.mid_ma")

## Finally, convert all zero's to NAs for plotting 
## This means that the plots won't register zero and instead will leave gaps 
## where there is no sampling instead - this gives a more realistic picture
proxy_counts[proxy_counts == 0] <- NA 



## Let's get plotting these patterns!

## Set interval boundaries for the dotted lines on the plot
## We'll also use this vector again, so its handy to have :)
int_boundaries <- c(237.0, 228.0, 208.5, 201.3, 199.3, 190.8, 182.7, 174.1)

## Set up your ggplot layers (first layer goes on the bottom, etc):
proxy_plot <- ggplot() + 
  # Formations (as dots and a line):
  geom_line(data = proxy_counts, aes(mid_ma, count_formations), colour = "orangered3", linewidth = 1.2, linetype = "dashed")  +
  geom_point(data = proxy_counts, aes(mid_ma, count_formations), colour = "orangered3", size = 4, shape = 16) +
  # Collections (as dots and a line):
  geom_line(data = proxy_counts, aes(mid_ma, count_colls), colour = "peru", linewidth = 1.2, linetype = "dashed")  +
  geom_point(data = proxy_counts, aes(mid_ma, count_colls), colour = "peru", size = 5, shape = 16) +
  # Taxa (as dots and a line):
  geom_line(data = proxy_counts, aes(mid_ma, count_taxa), colour = 'black', linewidth = 1.2)  +
  geom_point(data = proxy_counts, aes(mid_ma, count_taxa), colour = "black", size = 4, shape = 16) +
  # Add a minimal theme - but you can make your own custom themes too!
  theme_minimal() + 
  labs(x = "Time (Ma)", y = "Sampling proxy counts") +
  # Make sure to reverse the x-axis to match geological time!
  scale_x_reverse(breaks = int_boundaries) +
  # And tidy up our y-axis with even breaks that match the totals in our dataframe:
  scale_y_continuous(breaks = seq(0, 320, 20))
## Call the finished plot to the RStudio plots tab:
proxy_plot

## Set dimensions and save plot (as pdf) to the plots folder
#dir.create("./plots") # create new folder if one doesn't already exist
ggsave(plot = proxy_plot,
       width = 20, height = 15, dpi = 500, units = "cm", 
       filename = "./plots/sampling_proxies.pdf", useDingbats=FALSE)







# 3. Alpha diversity (local richness) ------------------------------------------------

## There is evidence to suggest that alpha diversity is not as strongly affected by sampling biases
##    as gamma (or 'global') diversity. For a more sophisticated way to calculate alpha diversity by
##    treating taxonomically indeterminate occurrences as valid, see the method described in 
##    Close et al. (2019) - code available here: https://github.com/emmadunne/local_richness

## Let's get our data set up:
lat_data <- occ_data # rename object to keep the original separate

## Create new column for mid_ma
lat_data$mid_ma <- (lat_data$max_ma + lat_data$min_ma)/2 

## Next, we'll need to count the number of taxa per collection (i.e. their frequency):
taxa_freqs <- count(lat_data, collection_no)

## Subset lat_data to only the columns we need:
lat_data <- lat_data %>% 
  select(collection_no, paleolat, paleolng, mid_ma) %>% 
  distinct() %>% na.omit()

## Add add the frequency information:
lat_data <- left_join(taxa_freqs, lat_data, by = "collection_no")

## Before we plot, let's order the frequencies and remove any NAs that have crept in:
lat_data <- lat_data %>% arrange(n) %>% na.omit()

## Take a look:
View(lat_data)


## Set up our ggplot layers
lat_plot <- ggplot(data = lat_data, aes(x = mid_ma, y = paleolat, colour = n)) +
  geom_vline(xintercept = int_boundaries, lty = 2, col = "grey90") +
  geom_hline(yintercept = 0, colour = "grey10") +
  scale_color_viridis(trans = "log", breaks = c(1, 2, 12), direction = -1, option = "D") + # set the break= to match your richness data
  #scale_y_continuous(labels = function(x) format(x, width = 5), limits = c(-70, 70), breaks = seq(from = -60, to = 60, by = 20)) +
  scale_x_reverse(breaks = int_boundaries) + 
  theme_minimal() + 
  theme(legend.direction = "vertical", 
        panel.grid.major.x = element_blank(), 
        panel.grid.minor.x = element_blank(), panel.grid.minor.y = element_blank(), 
        axis.title = element_text(size = 12)) +
  labs(x = "", y = "Palaeolatitude (º)") +
  geom_point(size = 4, alpha = 0.5) # (alpha sets point transparency)
lat_plot # call to plot window


## Set dimensions and save plot (as pdf)
ggsave(plot = lat_plot,
       width = 20, height = 10, dpi = 500, units = "cm", 
       filename = "./plots/lat_alpha_div.pdf", useDingbats=FALSE)





# 4. World map -----------------------------------------------------------------

## Finally, let's explore our data on a modern world map and see if we can spot
##    any geographic (and even socio-economic) patterns...

## First, let's pear down or occurrence data to only keep the info we need for making the map
locality_info <- occ_data %>% 
  dplyr::select(collection_name, lat, lng, early_interval, late_interval, max_ma, min_ma) %>% 
  distinct(collection_name, .keep_all = TRUE) %>% 
  na.omit()

## Grab a world map for ggplot to work with:
world_map <- map_data("world")
ggplot() + geom_map(data = world_map, map = world_map, aes(long, lat, map_id = region)) 

## Let's make it pretty and add our data
modern_map <- ggplot() + 
  geom_map(data = world_map, map = world_map, aes(long, lat, map_id = region), 
           color = "grey80", fill = "grey90", size = 0.1) +
  geom_point(data = locality_info, aes(lng, lat), alpha = 0.3, size = 4, colour = "#9B1999") +
  theme_void() + theme(legend.position = "none")
modern_map

## And save as a .pdf
ggsave(plot = modern_map,
       width = 8, height = 5, dpi = 600, 
       filename = "./plots/Modern_map.pdf", useDingbats=FALSE)
