# 02-basics - exercise

# 1. Create a vector with five numbers.
myvector <- c(5, 7, 24, 67, 1)

# 2. Use the sum() function to calculate the sum of the four numbers.
sum(myvector)

# 3. Install the package "tidyverse" (if you haven't already)
install.packages("tidyverse")

# 4. Load the package tidyverse
library(tidyverse)

# 5. Create a vector with three words
mywords <- c("bird", "feather", "animal")

# 6. Use the function str_c() from the stringr package (part of tidyverse) to make one string out of the vector you created. Use the attribute collapse = " ,".
str_c(mywords, collapse = ", ")

# 7. Select only the last three numbers from your number vector using the square brackets [].
myvector[3:5]

# 8. Save these three numbers as a new vector.
newvector <- myvector[3:5]

# 9. Make a dataframe using the new vector and the vector with three words. 
mydata <- data.frame(newvector, mywords)
mydata

# 10. Add a column/variable called "multiply" that is made up of the first column multiplied by 3
mydata$multiply <- mydata$newvector * 3
mydata

# 11. Load the dataframe from last week (it is called mdb_data)
load(file = "mdb_data.RData")

# 12. Add a variable for "age"
mdb_data$age <- 2023 - mdb_data$year

# 13. Select only the column "first_name"
mdb_data$first_name

# 14. Select only the rows with the first name "Michael"
mdb_data[mdb_data$first_name == "Michael", ]

# 15. Write the selected rows into a new object called michael
michael <- mdb_data[mdb_data$first_name == "Michael", ]

# 16. Are the Michaels older or younger, on average, than all MPs together? (You may have to add the argument into the function you use: na.rm = T)
mean(mdb_data$age, na.rm = T)
mean(michael$age)

# Optional: 

# 17. Load the package "genderdata" from the "lib" folder using the following command (This package is not available at CRAN):
library(genderdata, lib.loc = "lib")

# 18. Install and load the package "gender".
install.packages("gender")
library(gender)

# 19. Find the right function in the gender package, and use it to guess the gender of the first names from mdb_data. Save the result in a new dataframe.
mdb_gender <- gender(mdb_data$first_name)

# 20. Use the function table() on the variable gender of the dataframe from 19.
table(mdb_gender$gender)