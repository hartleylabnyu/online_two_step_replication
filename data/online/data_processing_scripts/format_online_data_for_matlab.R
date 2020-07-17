## Format online data for matlab

#### LIBRARIES AND FUNCTIONS ####
library(tidyverse)
library(glue)

#get list of files
data_files <- list.files(path = "data/online/online_csvs/")

#initialize data frame
data <- data.frame()

# Read in data
for (i in c(1:length(data_files))){
  sub_data <- read_csv(glue("data/online/online_csvs/{data_files[i]}")) 
  data <- rbind(data, sub_data)
}

#get rid of yuck columns
data %<>% 
  select(c(trial_index,
           subject_id, 
           choice,
           rt, 
           trial_stage,
           transition,
           practice_trial,
           reward)) %>%
  filter(practice_trial == "real")

data$rt <- as.numeric(data$rt)

#format data
data <- data %>%
  group_by(subject_id) %>%
  mutate(temp_trial = rank(trial_index)) %>%
  mutate(trial = ceiling(temp_trial/2)) %>%
  ungroup() %>%
  select(-trial_index, -temp_trial) %>%
  pivot_wider(names_from = c(trial_stage), 
              values_from = c(transition, reward, choice, rt)) %>%
  select(subject_id, practice_trial, trial, transition_2, reward_2, choice_1, choice_2, rt_1, rt_2) %>%
  rename(transition = transition_2,
         reward = reward_2) %>%
  mutate(state = case_when(choice_1 == 1 & transition == "common" ~ 2,
                           choice_1 == 1 & transition == "rare" ~ 3,
                           choice_1 == 2 & transition == "common" ~ 3,
                           choice_1 == 2 & transition == "rare" ~ 2)) %>%
  mutate_at(vars(contains("choice")), ~replace(., is.na(.), 0)) %>%
  mutate_at(vars(contains("state")), ~replace(., is.na(.), 0))

#write csv
write_csv(data, 'data/online/online_data_for_matlab.txt')
