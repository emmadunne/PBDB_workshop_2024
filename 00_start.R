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
#   0. Getting set up in R 
#         & loading packages
# 
# ******************************************************


## We will be using dplyr to manipulate our data, so we need to install them.
## We cna do this with code like this or via the main menu in RStudio:
utils::install.packages("dplyr", dependencies = TRUE)


## Packages used in this session
## (be sure to install them first!)
library(tidyverse) 
library(sepkoski)
library(rgplates)
library(divDyn)
library(geojsonsf)


## Clear R's environment before starting so you're working with a clean slate:
rm(list = ls())

## If you've been using a lot of different packages, some function names might be masked;
## this step ensures that the function 'select' is coming from the dplyr package (part of tidyverse)
select <- dplyr::select



# R package: sepkoski -----------------------------------------------------

### (a) sepkoski

## This package allows easy access to Sepkoski's fossil marine animal genera 
## compendium (Sepkoski, 2002), ported from Shanan Peters' online database.
## More information here: https://github.com/LewisAJones/sepkoski
citation("sepkoski") # citation info

## Accessing the datasets
data("sepkoski_raw") # Sepkoski's raw fossil marine animal genera compendium (Sepkoski, 2002)
data("sepkoski") # Sepkoski's compendium with first and last appearance intervals updated to be consistent with stages from the International Geological Time Scale 2022
data("interval_table") # a table linking intervals in Sepkoski's compendium with the International Geological Time Scale 2022.

## Let's look at the data...
View(sepkoski_raw) # opens a new tab in RStudio

## What variables have we got?
glimpse(sepkoski_raw) # dplyr (tidyverse function)
str(sepkoski_raw) # base R function

## Let's plot Sepkoski's famous curve
sepkoski_curve()

## Take a look at the help file to customise the plot
?sepkoski_curve
sepkoski_curve(fill = TRUE)


