## MBMF RL ANALYSIS ##
# Kate Nussenbaum - katenuss@nyu.edu
# Last updated: 7/17/20

# Examine how hybrid RL model parameters vary as a function of age # 

#### LIBRARIES AND FUNCTIONS ####
library(tidyverse)
library(glue)
library(magrittr)
library(afex)

#define new function so that scale returns a vector, not a matrix
scale_this <- function(x) as.vector(scale(x))

# age group function
# Add age group variable to data frame with raw ages
addAgeGroup <- function(df, ageColumn){
  ageColumn <- enquo(ageColumn)
  df %>% mutate(age_group = case_when((!! ageColumn) < 13 ~ "Children",
                                      (!! ageColumn) > 12.9 & (!! ageColumn) < 18 ~ "Adolescents",
                                      (!! ageColumn) >= 18 ~ "Adults"), 
                age_group = factor(age_group, levels = c("Children", "Adolescents", "Adults")))
  
}


########################
#### ONLINE DATASET ####
########################
# Read in model fits
model_fits <- read_tsv("output/online_data/RL/online_fits.txt",
                       col_names = c("sub", "alpha", "beta_mb", "beta_mf", "beta", "lambda", "stickiness", "lik", "subject_id")) %>%
  select(-c(sub))

#read in sub ages
sub_ages <- read_csv("data/online/mbmf_ages.csv") %>%
  select(subject_id, age)

#combine
model_fits <- inner_join(sub_ages, model_fits, by = c("subject_id"))

#scale age
model_fits$age_z <- scale_this(model_fits$age)

#set output folder name
output_folder <- "output/online_data/RL"

#run analysis
source("RL_analyses.R")


########################
#### DECKER DATASET ####
########################
# Read in model fits
model_fits <- read_csv("output/decker_data/RL/decker_fits.txt",
                       col_names = c("sub", "alpha", "beta_mb", "beta_mf", "beta", "lambda", "stickiness", "lik", "subject_id")) %>%
  select(-c(sub))

#read in sub ages
sub_ages <- read_csv("data/decker/decker_ages.csv") %>%
  select(subject_id, age)

#combine
model_fits <- inner_join(sub_ages, model_fits, by = c("subject_id"))

#scale age
model_fits$age_z <- scale_this(model_fits$age)

#set output folder name
output_folder <- "output/decker_data/RL"

#run analysis
source("RL_analyses.R")


########################
#### POTTER DATASET ####
########################
# Read in model fits
model_fits <- read_csv("output/potter_data/RL/potter_fits.txt",
                       col_names = c("sub", "alpha", "beta_mb", "beta_mf", "beta", "lambda", "stickiness", "lik", "subject_id")) %>%
  select(-c(sub))

#read in sub ages
sub_ages <- read_csv("data/potter/potter_ages.csv") %>%
  select(subject_id, age)

#combine
model_fits <- full_join(sub_ages, model_fits, by = c("subject_id"))

#scale age
model_fits$age_z <- scale_this(model_fits$age)

#set output folder name
output_folder <- "output/potter_data/RL"

#run analysis
source("RL_analyses.R")