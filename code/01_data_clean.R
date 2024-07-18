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
#   1. Accessing the PBDB in R 
#       & cleaning imported data
# 
# ******************************************************

## Packages used in this script:
#library(tidyverse) 



# 1. Importing PBDB download ----------------------------------------------

## Any dataset can be imported into R from a file
## Let's download some data from the PBDB using the Download Generator 
## https://paleobiodb.org/classic/displayDownloadGenerator

## Now let's import it:
pbdb_data_raw <- read.csv("./data/pbdb_data.csv", skip = 18) 

## Take a look inside:
View(pbdb_data_raw)
glimpse(pbdb_data_raw)




# 2. PBDB via URL ---------------------------------------------------------

## The Paleobiology Database data can accessed through an API request
## Note that this requires an internet connection!

## First, choose a taxonomic group and time interval and create new objects:
taxon_group <- "Pseudosuchia" # Taxon group
start_interval <- "Carnian" # Interval to start at
stop_interval <- "Toarcian" # Interval to stop at

## Create an API request form the PBDB and store this URL as an object
## A list of API options can be found here: https://paleobiodb.org/data1.2/
URL <- paste0("https://paleobiodb.org/data1.2/occs/list.csv?base_name=", # occurrence data, as a .csv
              taxon_group, "&interval=", start_interval, ",", stop_interval, # use our inputs from above
              "&show=full&pres=regular") # any additional columns we want 

## Then use this to load the data into R:
occ_data_raw <- as_tibble(read.csv(URL, header = TRUE, stringsAsFactors = FALSE))

## Take a peep:
glimpse(occ_data_raw) # view columns
View(occ_data_raw) # open as new tab

## It's good practice to save copies of your data as you go:
write_csv(occ_data_raw, "./data/PBDB_pseudos_24_08_23.csv")



# 3. Cleaning occurrence data ---------------------------------------------

## Raw occurrence data is imperfect, especially if you have not curated it yourself 
## 'Cleaning' is a very important step to ensure you don't include unnecessary info
## Let's go through step by step and remove some of the noise from the data we just downlaoded

## Remove 'super-generic' identifications, so that we only retain occurrences to species- and genus-level
occ_data_raw2 <- filter(occ_data_raw, (identified_rank %in% c("species","genus")))

## Remove occurrences with “aff.”, “ex. gr.”, “sensu lato”, “informal”, or quotation marks in identified names
occ_data_raw3 <- occ_data_raw2 %>% 
  filter(!grepl("cf\\.|aff\\.|\\?|ex\\. gr\\.|sensu lato|informal|\\\"", identified_name)) 

## Remove ichnotaxa (trace fossils) so that only regular taxa remain
## We can do this via the pres_mode column and entries marked as 'trace' or 'soft'
occ_data_raw4 <- occ_data_raw3[occ_data_raw3$pres_mode != "trace", ] # trace taxa
occ_data_raw5 <- occ_data_raw4[!grepl("soft",occ_data_raw4$pres_mode), ] # 'soft' preservation

## Remove entries without a genus name - in the PBDB these can be errors
occ_data_raw6 <- occ_data_raw5[occ_data_raw5$genus != "", ]

## Finally, filter the data so any duplicate taxon names or collection numbers are eliminated:
occ_data <- distinct(occ_data_raw6, accepted_name, collection_no, .keep_all = TRUE)

## Take a look at the end result - How much has our data been reduced by?
length(unique(occ_data_raw$occurrence_no)) # start
length(unique(occ_data$occurrence_no)) # finish

## Filter to a species-only dataset:
occ_data_sp <- filter(occ_data, (accepted_rank == "species"))


## Save copies of these cleaned datasets as .csv files - Note: your file path might differ!
write_csv(occ_data_sp, "./data/occ_data_sp_cleaned.csv")


## CAUTION:
## If you were publishing with these data, you would also need to check the dataset
##    for errors in taxonomy, stratigraphy, geography, etc. too.




# 4. Intervals data -------------------------------------------------------


## We can also grab time intervals data from the PBDB API. 
## We'll do this here to help us with plotting later. 
## Note: we are using stage-level bins here - for your own analyses I highly 
##    recommend exploring other ways to bin your data and exploring the 
##    associated data structures and biases

## Download names and ages of time intervals from the PBDB using a URL:
intervals_all <- read.csv("http://paleobiodb.org/data1.1/intervals/list.txt?scale=all&limit=all")
View (intervals_all) # take a look in new RStudio tab

## For the rest of this session, we're going to focus on the Late Triassic-Early Jurassic interval
## Make a vector of stage names that we are interested in:
interval_names <- c("Carnian", "Norian", "Rhaetian", # Late Triassic
                    "Hettangian", "Sinemurian", "Pliensbachian", "Toarcian") # Early Jurassic

## Select these intervals from the full PBDB intervals dataset:
intervals <- filter(intervals_all, interval_name %in% interval_names)

## Pare this down to just the 3 columns we'll need:
intervals <- select(intervals, interval_name, early_age, late_age)

## For ease of use later, let's rename the age columns to match the occurrence data:
intervals <- rename(intervals, "max_ma" = "early_age", "min_ma" = "late_age")

## And finally, calculate the midpoint for each interval and add it to a new (4th) column
intervals$mid_ma <- (intervals$min_ma + intervals$max_ma)/2

## Take a peep:
View(intervals) # open as new tab

## Save a copy as a .csv file - Note: your file path will differ!
write_csv(intervals, "./data/intervals_Car_Tor.csv")