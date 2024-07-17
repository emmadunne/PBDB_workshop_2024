#NOTES
#Open R
#Import a .csv download
#Explore some data (variables, structure, summaries, etc.)

# Remember to set a working directory - this tells R where to save your file
# (and look for files you want to load into R). This requires a file path to
# the folder you want to use, e.g. to save to the desktop in Windows you would use:
setwd("C:/Users/PCname/Desktop")

# We will be using dplyr to manipulate our data, so we need to download it...
utils::install.packages("dplyr", dependencies = TRUE)

# ... and load it into memory:
library(dplyr)

# To read in your .csv of PBDB data into R, you can use:
fossils <- read.csv("Neogene_Canidae.csv")

# Let's take a look at what this contains.
colnames(fossils)
