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
#   4. Functions within other R packages
# 
# ******************************************************


## Packages used in this script
# library(rgplates)
# library(divDyn)



# 1. Paleogeographic maps ---------------------------------------------------


## First, create a new, simplified data object to build our map:
map_data <- occ_data %>% 
  select(collection_name, lat, lng, paleolat, paleolng, early_interval, late_interval, max_ma, min_ma) %>% 
  distinct(collection_name, .keep_all = TRUE) %>% 
  na.omit(collection_name)


## Now, let's split these data in Late Triassic and Early Jurassic 
map_data_LT <- map_data %>% filter(max_ma >= 201.4)
map_data_EJ <- map_data %>% filter(max_ma <= 201.4)


## Let's now grab our paleogeographies for the time bins from the GPlates (via rgplates)
paleogeog_LT <- reconstruct("coastlines", age = 215, model="MERDITH2021") 
paleogeog_EJ <- reconstruct("coastlines", age = 190, model="MERDITH2021") 


## Now let's start the map!
## Begin by setting a theme (these settings are pretty minimal):
palaeomap_theme <- theme_minimal() + theme(axis.title.x=element_blank(), axis.text.x=element_blank(),
                                           axis.title.y=element_blank(), axis.text.y=element_blank(),
                                           axis.ticks.x=element_blank(), axis.ticks.y=element_blank(),
                                           legend.title=element_blank())

## Now let's plot the each of the maps!
paleomap_LT <-  ggplot() +
    ## Add the landmasses
    geom_sf(data = paleogeog_LT, colour = "grey75", fill = "grey75") +
    ## Use the Mollweide projection:
    #coord_map("mollweide") +
    ## Add the occurrence data (and set your colour!):
    geom_point(data = map_data_LT, aes(x = paleolng, y = paleolat), color = "#0DA69B", size = 4,  alpha = 0.8) + 
    ## Add lines from the x and y axes
    #scale_y_continuous(breaks = seq(from = -90, to = 90, by = 30), limits = c(-90,90)) + 
    #scale_x_continuous(breaks = seq(from = -180, to = 180, by = 30), limits = c(-180,180)) + 
    ## Add the interval name to the title of each map 
    ggtitle("Late Triassic") +
    ## Finally, add the custom theme
    palaeomap_theme
paleomap_LT


## And finally, save as a .pdf
ggsave(plot = paleomap_LT,
       width = 12, height = 10, dpi = 600, 
       filename = "./plots/Paleomap_LateTriassic.pdf", useDingbats=FALSE)






# divDyn paleodiversity ---------------------------------------------------

## Taking a coral dataset from divDyn, which derives from the PBDB
data(corals)
?corals

## collect the fossil occurrences
fossils <- corals[corals$stg!=95,]
# check the number of occurrences
nrow(fossils)

# indicate identical collection/genus combinations
collGenus <- paste(fossils$collection_no, fossils$genus)
# omit the duplicates from the occurrence datasets
fossGen <- fossils[!duplicated(collGenus),]


# sqs with 0.6 quorum
sqs0.6 <-subsample(fossGen, iter=50, q=0.6,
                   tax="genus", bin="stg", type="sqs")
#sqs with 0.3 quorum
sqs0.3 <-subsample(fossGen, iter=50, q=0.3,
                   tax="genus", bin="stg", type="sqs")

# grab the stages information:
data(stages)

# metrics - for plotting
dd <- divDyn(fossils, bin="stg", tax="genus")

# plotting
tsplot(stages, shading="series", boxes="sys", xlim=52:95,
       ylab="corrected SIB richness", ylim=c(0,175))
lines(stages$mid[1:94], sqs0.6$divCSIB, col="cadetblue")
lines(stages$mid[1:94], sqs0.3$divCSIB, col="chartreuse3")
lines(stages$mid[1:94], dd$divCSIB, col="grey30")
legend("topleft", legend=c("raw", "SQS, q=0.6", "SQS, q=0.3"),
       col=c("grey30", "cadetblue", "chartreuse3"), lwd=c(2,2,2), bg="white")






