## MBMF Bootstrap Power Analysis ##
# Kate Nussenbaum - katenuss@nyu.edu
# Last updated: 7/17/20

# This analysis determines the minimum sample size necessary to produce the
# age x reward x transition interaction effect from Decker et al. (2016) with 80% power.

#### LIBRARIES #### 
library(tidyverse)
library(doSNOW)
cl <- makeCluster(8, outfile="") #set to number of cores on computer
registerDoSNOW(cl)

#### DETERMINE DATA SET ####
# manually change to 1, 2 or 3, for Decker (1), Potter (2), online (3)
dataset = 3 

#### FUNCTIONS ####

#Add age group variable to data frame with raw ages
addAgeGroup <- function(df, ageColumn){
  ageColumn <- enquo(ageColumn)
 df %>% mutate(age_group = case_when((!! ageColumn) < 13 ~ "Children",
                                     (!! ageColumn) > 12 & (!! ageColumn) < 18 ~ "Adolescents",
                                     (!! ageColumn) >= 18 ~ "Adults"), 
                age_group = factor(age_group, levels = c("Children", "Adolescents", "Adults")))
  }



#### SELECT DATASET ####

# Decker dataset
if (dataset == 1){
  data <- read_csv("previous_data/decker_full_data.dat") %>%
    rename(subject_id = subj,
           previous_reward = lastwin,
           previous_transition = lasttransR,
           transition = currtransR) 
  
  #recode factors
  data$previous_reward <- factor(data$previous_reward, labels = c("No Reward", "Reward"), ordered = F)
  data$previous_transition <- factor(data$previous_transition, labels = c("common", "rare"), ordered = F)
  data$transition <- factor(data$transition, labels = c("common", "rare"), ordered = F)
  
  #put factors in right order
  data$previous_reward <- relevel(data$previous_reward, "Reward")
  data$previous_transition <- relevel(data$previous_transition, "common")
  data$transition <- relevel(data$transition, "common")
  
  ages <- read_csv('previous_data/decker_ages.csv') 
  data <-full_join(data, ages, by = c("subject_id"))
  data <- addAgeGroup(data, age)
  
  output_name <- "output/power_analysis/decker_pvals.Rda"
  output_power_name <- "output/power_analysis/decker_power_results.txt"
}




# Potter dataset
if (dataset == 2){
  data <- read_csv("previous_data/potter_all.dat") %>%
    rename(subject_id = subj,
           previous_reward = lastwin,
           previous_transition = lasttransR,
           transition = currtransR) 
  
  #recode factors
  data$previous_reward <- factor(data$previous_reward, labels = c("No Reward", "Reward"), ordered = F)
  data$previous_transition <- factor(data$previous_transition, labels = c("common", "rare"), ordered = F)
  data$transition <- factor(data$transition, labels = c("common", "rare"), ordered = F)
  
  #put factors in right order
  data$previous_reward <- relevel(data$previous_reward, "Reward")
  data$previous_transition <- relevel(data$previous_transition, "common")
  data$transition <- relevel(data$transition, "common")
  
  ages <- read_csv('previous_data/potter_ages.csv') 
  data <-full_join(data, ages, by = c("subject_id"))
  data <- addAgeGroup(data, age)
  
  output_name <- "output/power_analysis/potter_pvals.Rda"
  output_power_name <- "output/power_analysis/potter_power_results.txt"
  
  
}

# Online dataset
if (dataset == 3) {
  data <- read_csv("online_data_processed.txt", 
                 col_types = cols(subject_id = "f"))

  output_name <- "output/power_analysis/online_pvals.Rda"
  output_power_name <- "output/power_analysis/online_power_results.txt"
}


#### RUN POWER ANALYSIS ####

## Sample with replacement from each age group ##
# divide data up into age group data frames
child_data <- data %>%
  filter(age_group == "Children")

teen_data <- data %>%
  filter(age_group == "Adolescents")

adult_data <- data %>%
  filter(age_group == "Adults")


#### SAMPLE DIFFERENT NUMBERS OF SUBS ####
p_vals <- foreach(age_group_sample = c(10:30)) %:%
          foreach(iteration = c(1:100)) %dopar% {
            
  #load libraries
  library(afex)
  library(tidyverse)
  scale_this <- function(x) as.vector(scale(x))
  
  #select sub ids
  children <- sample(unique(child_data$subject_id), size = age_group_sample, replace = T)
  teens <- sample(unique(teen_data$subject_id), size = age_group_sample, replace = T)
  adults <- sample(unique(adult_data$subject_id), size = age_group_sample, replace = T)

  #get relevant data
  df1 <- child_data[child_data$subject_id %in% children, ]
  df2 <- teen_data[teen_data$subject_id %in% teens, ]
  df3 <- adult_data[adult_data$subject_id %in% adults, ]

  #combine into a single data frame
  df <- rbind(df1, df2, df3)
  
  #zscore age
  df$ageZ <- scale_this(df$age)

  # run glmer models with and without 3-way interaction
  model1 <- mixed(stay ~ (previous_reward*previous_transition) + (ageZ*previous_reward) + (ageZ*previous_transition)  + (previous_reward * previous_transition|subject_id),
                 family = "binomial", 
                 data = df, 
                 return = "merMod",
                 control = glmerControl(optimizer = "bobyqa"))
  
  model2 <- mixed(stay ~ previous_reward * previous_transition * ageZ + (previous_reward * previous_transition|subject_id),
                 family = "binomial", 
                 data = df, 
                 return = "merMod",
                 control = glmerControl(optimizer = "bobyqa"))
  
  #run LRT
  lrt <- anova(model1, model2)
  
  #get p value
  p_val <- lrt$`Pr(>Chisq)`[2]

  #store p value
  return(p_val)
  
}
stopCluster(cl) 


#compute proportion of times p < .05
N_30 = as.data.frame.vector(p_vals[[1]])
N_33 = as.data.frame.vector(p_vals[[2]])
N_36 = as.data.frame.vector(p_vals[[3]])
N_39 = as.data.frame.vector(p_vals[[4]])
N_42 = as.data.frame.vector(p_vals[[5]])
N_45 = as.data.frame.vector(p_vals[[6]])
N_48 = as.data.frame.vector(p_vals[[7]])
N_51 = as.data.frame.vector(p_vals[[8]])
N_54 = as.data.frame.vector(p_vals[[9]])
N_57 = as.data.frame.vector(p_vals[[10]])
N_60 = as.data.frame.vector(p_vals[[11]])
N_63 = as.data.frame.vector(p_vals[[12]])
N_66 = as.data.frame.vector(p_vals[[13]])
N_69 = as.data.frame.vector(p_vals[[14]])
N_72 = as.data.frame.vector(p_vals[[15]])
N_75 = as.data.frame.vector(p_vals[[16]])
N_78 = as.data.frame.vector(p_vals[[17]])
N_81 = as.data.frame.vector(p_vals[[18]])
N_84 = as.data.frame.vector(p_vals[[19]])
N_87 = as.data.frame.vector(p_vals[[20]])
N_90 = as.data.frame.vector(p_vals[[21]])


p_df <- bind_cols(N_30, N_33, N_36, N_39, N_42, N_45, N_48, N_51, N_54, N_57,
                  N_60, N_63, N_66, N_69, N_72, N_75, N_78, N_81, N_84, N_87, 
                  N_90) 

prop_sig_effect <- sapply(p_df, function(x) sum(x < .05))
power_results <- tibble(age_group_n = c(10:30), prop_sig_effect = prop_sig_effect)

#### SAVE OUTPUT ####
write_delim(power_results, output_power_name, delim = "\t")
save(p_vals, file = output_name)