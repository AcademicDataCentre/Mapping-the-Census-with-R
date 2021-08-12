# Set up the working directory for R to read and write data on your computer 
setwd("C:/MappingCensusR_Data")

# Check the working directory is correct 
getwd()

# List all the files in the working directory
dir()

# Install the rgdal package 
install.packages ("rgdal",dependencies = TRUE) #make sure the another package(s) it probably depends on to be also installed

# Load the package "rgdal"
library(rgdal)

# Load the shapefile data and assign it to a new spatial object called "DA"
DA <- readOGR(dsn = "lda_000b16a_e", layer = "lda_000b16a_e")


# Get a quick summary of the data
summary (DA)

# Display the attribute table of the data as a spreadsheet
View(DA@data)

# Create a subset of this spatial object that only contains City of Windsor (whose CSDUID equal to 3537039) and only have one column "DAUID"
DA_Windsor <- DA[DA$CSDUID=="3537039", "DAUID"] 

# Get the summary of the subset data and make a simple map
summary(DA_Windsor)
plot(DA_Windsor)

# Load the csv file and assign it to a new data frame
Census2016 <- read.csv("T1901EN.csv", header = TRUE) 

# Get a summary of the data
summary(Census2016)
str(Census2016)

# Take a look at the data as a spreadsheet 
View(Census2016)

# Create a subset of the data that only contains the desired columns 
Sub_census <- Census2016[,c(1,7,9,12)]

# Fix column names containing spaces and commas
names(Sub_census)<-c("DAUID","POP","Dwelling","PopDen")
str(Sub_census)

# View and compare the attributes of the two data frames
View(Sub_census)
View(DA_Windsor@data)

# In order to join the two datasets, we need compatible versions of "DAUID" (the same data type)
class(DA_Windsor$DAUID)
class(Sub_census$DAUID)

# Install and load the package "dplyr"
install.packages("dplyr",dependencies = TRUE)
library(dplyr)

# join variables from the census data to the data slot of the spatial data frame
DA_Windsor@data <- left_join(DA_Windsor@data, Sub_census, by = "DAUID")
View(DA_Windsor@data)

# Install and load multiple packages 
install.packages(c("RColorBrewer","classInt"),dependencies = TRUE)
lapply(c("RColorBrewer","classInt"), require, character.only = TRUE)

# Assign the variable you want to map 
plotvar <- DA_Windsor$PopDen
# Assign the number of classes that the variable will be grouped into
nclr <- 5

# create a custom color palette for your map using the RColorBrewer package

# display a list of all the color palettes available 
display.brewer.all()

# create a color palette object 
plotclr <- brewer.pal(nclr, name = "YlOrRd")

# Decide the classification method(quantile) and obtain the break points for each class 
q5 <- classIntervals(plotvar, nclr, style="quantile")
q5

# Obtain your color codes for each observation (DA)
q5Colours <- findColours(q5,plotclr) 
str(q5Colours)

# Make a map 
plot(DA_Windsor, col = q5Colours)

# Add a map title 
title(main = "City of Windsor, 2016", sub = "By Census Dissemination Area")

# Create a custom legend for your map 
legend(x = "topleft",# position of the legend
       legend = names(attr(q5Colours, "table")),
       fill = attr(q5Colours,"palette"), 
       bty = "n", #showing no box around the legend
       title="Population density per square kilometer",
       cex = 0.8) #adjust legend size     
