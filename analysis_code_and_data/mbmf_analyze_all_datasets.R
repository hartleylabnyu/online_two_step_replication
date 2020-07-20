## MBMF ANALYSIS ##
# Kate Nussenbaum - katenuss@nyu.edu
# Last updated: 7/17/20

# Run regression analyses for online, decker, and potter datasets and save model outputs #

#### LIBRARIES AND FUNCTIONS ####
library(tidyverse)
library(glue)
library(magrittr)
library(gridExtra)
library(afex)
library(sjPlot)

# age group function
# Add age group variable to data frame with raw ages
addAgeGroup <- function(df, ageColumn){
  ageColumn <- enquo(ageColumn)
  df %>% mutate(age_group = case_when((!! ageColumn) < 13 ~ "Children",
                                      (!! ageColumn) > 12.9 & (!! ageColumn) < 18 ~ "Adolescents",
                                      (!! ageColumn) >= 18 ~ "Adults"), 
                age_group = factor(age_group, levels = c("Children", "Adolescents", "Adults")))
  
}

#define new function so that scale returns a vector, not a matrix
scale_this <- function(x) as.vector(scale(x))


# --- --- --- --- --- --- #
#### 1. ONLINE DATA  ####
# --- --- --- --- --- --- #

#get list of files
data_files <- list.files(path = "data/online/online_csvs")

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

#read in subject ages
sub_ages <- read_csv('data/online/mbmf_ages.csv') 
sub_ages$subject_id <- as.character(sub_ages$subject_id)

#combine with data
data <- full_join(data, sub_ages, by = "subject_id")

#format data
data <- data %>%
  group_by(subject_id) %>%
  mutate(temp_trial = rank(trial_index)) %>%
  mutate(trial = ceiling(temp_trial/2)) %>%
  ungroup() %>%
  select(-trial_index, -temp_trial) %>%
  pivot_wider(names_from = c(trial_stage), 
              values_from = c(transition, reward, choice, rt)) %>%
  select(subject_id, practice_trial, age, trial, transition_2, reward_2, choice_1, choice_2, rt_1, rt_2) %>%
  rename(transition = transition_2,
         reward = reward_2) %>%
  drop_na()

#add columns for previous reward, previous transition type, and "stay"
data <- data %>%
  group_by(subject_id) %>%
  mutate(previous_reward = lag(reward),
         previous_transition = lag(transition),
         previous_choice = lag(choice_1)) %>%
  ungroup() %>%
  mutate(stay = case_when(previous_choice == choice_1 ~ 1,
                          previous_choice != choice_1 ~ 0)) %>%
  filter(trial > 9)

#relabel transitions and reward
data$previous_reward <- factor(data$previous_reward, labels = c("No Reward", "Reward"), ordered = F)
data$previous_reward <- relevel(data$previous_reward, "Reward")

#sanity check - ensure rare transitions were actually rare
transition_probs <- data %>%
  group_by(transition) %>%
  summarize(N = n())

#add age groups to data 
data <- addAgeGroup(data, age)

#name output folder
output_folder <- "output/online_data"

#save data to use later in mediation analysis
write_csv(data, glue("{output_folder}/online_data_processed.txt"))

### RUN ANALYSES ###
source("regression_analyses.R")

#manually save model outputs
tab_model(stay.model, show.stat = F,
          string.ci = "CI (95%)",
          string.est = "Estimate", 
          dv.labels = c("First-stage choice repetition"),
          pred.labels = c("Intercept", 
                          "Reward", 
                          "Transition", 
                          "Age", 
                          "Reward x Transition",
                          "Reward x Age",
                          "Transition x Age",
                          "Reward x Transition x Age"),
          file = glue("{output_folder}/stay_model.html"))

#also save chi-squared and p values from model as .txt file 
chisqdf <- tibble(chisq = stay.model$anova_table$Chisq, p = round(stay.model$anova_table$`Pr(>Chisq)`, 6))
write_delim(chisqdf, glue("{output_folder}/stay_chisq.txt"), delim = "\t")

tab_model(rt.model, 
          show.stat = F,
          show.df = T,
          show.fstat = T,
          string.ci = "CI (95%)",
          string.est = "Estimate", 
          dv.labels = c("Second-stage reaction time"),
          pred.labels = c("Intercept", 
                          "Age",
                          "Transition", 
                          "Age x Transition"),
          file = glue("{output_folder}/rt_model.html"))

#save df, F, and p values from model
fstat_df <- tibble(df = round(rt.model$anova_table$`den Df`, 2), f_stat = rt.model$anova_table$F, p = round(rt.model$anova_table$`Pr(>F)`, 6))
write_delim(fstat_df, glue("{output_folder}/rt_f.txt"), delim = "\t")

tab_model(rt.mb.model, 
          show.stat = T,
          show.se = T,
          string.ci = "CI (95%)",
          string.est = "Estimate", 
          string.stat = "t value",
          string.se = "SE",
          dv.labels = c("Model-based learning random effect"),
          pred.labels = c("Intercept", 
                          "RT Difference",
                          "Age", 
                          "RT Difference x Age"),
          file = glue("{output_folder}/rt_mb_model.html"))


# Compute stats on explicit knowledge of transition structure
#initialize data frame
explicit_data <- data.frame()
for (i in c(1:length(data_files))){
  sub_data <- read_csv(glue("data/online_data/online_csvs/{data_files[i]}")) 
  
  #determine whether explicit question was answered correctly
  red_planet_first = sub_data$red_planet_first_rocket[1]
  rocket_sides = sub_data$rocket_sides[1]
  correct_explicit_response = case_when(red_planet_first == rocket_sides ~ "49",
                                        red_planet_first != rocket_sides ~ "48")
  explicit_response = sub_data %>% filter(grepl('explicit', trial_type)) %>%
    select(key_press)
  sub_data %<>% mutate(explicit_q_correct = case_when(explicit_response == correct_explicit_response ~ 1,
                                                      explicit_response != correct_explicit_response ~ 0))
  
  #get explicit question reaction time
  explicit_response_rt = sub_data %>% 
    filter(grepl('explicit', trial_type)) %>%
    select("rt") %>%
    pull()
  sub_data %<>% mutate(explicit_rt = as.numeric(explicit_response_rt))
  
  #combine subject data into larger data frame
  explicit_data <- rbind(explicit_data, sub_data)
}

#get explicit Q stats
explicit_data <- explicit_data %>%
  select(subject_id, explicit_rt, explicit_q_correct) %>%
  unique()

#combine w/ ages
explicit_data <- inner_join(sub_ages, explicit_data, by = "subject_id") 
explicit_data <- addAgeGroup(explicit_data, age)

explicit_stats <- explicit_data %>%
  group_by(age_group) %>%
  summarize(explicit_response_acc = mean(explicit_q_correct),
            explicit_response_sd = sd(explicit_q_correct),
            N = n(),
            explicit_response_se = explicit_response_sd/sqrt(N))

#save stats
write_delim(explicit_stats, path = glue("{output_folder}/explicit_q_acc.txt"), delim = "\t")

explicit_plot <- ggplot(explicit_stats, aes(x = age_group, y = explicit_response_acc)) +
  geom_bar(stat = "identity", position = "dodge", fill = "lightgrey", color = "black") +
  geom_errorbar(aes(ymin = explicit_response_acc - explicit_response_se, ymax = explicit_response_acc + explicit_response_se),
                width = .1) +
  xlab("Age Group") +
  ylab("Question Accuracy") +
  coord_cartesian(ylim = c(0,1)) +
  theme_minimal()
explicit_plot

#save plot
ggsave(glue("{output_folder}/explicit_q_acc.png"), plot = last_plot(), height = 3, width = 4, unit = "in", dpi = 300)

#test to see whether there's an effect of age on explicit knowledge
explicit_data$age_z <- scale_this(explicit_data$age)
explicit.age.model <- glm(explicit_q_correct ~ age_z, data = explicit_data, family = "binomial")
tab_model(explicit.age.model, file = glue("{output_folder}/explicit_q_model.html"))


# --- --- --- --- --- --- #
#### 2. DECKER DATA ####
# --- --- --- --- --- --- #
data <- read_csv("data/decker/decker_data.dat") %>% 
  rename(subject_id = subj,
         previous_reward = lastwin,
         previous_transition = lasttransR,
         transition = currtransR) %>%
  mutate(rt_1 = s1rt * 1000,
         rt_2 = s2rt * 1000) %>%
  select(-c(s1rt, s2rt))

#recode factors
data$previous_reward <- factor(data$previous_reward, labels = c("No Reward", "Reward"), ordered = F)
data$previous_transition <- factor(data$previous_transition, labels = c("common", "rare"), ordered = F)
data$transition <- factor(data$transition, labels = c("common", "rare"), ordered = F)

#put factors in right order
data$previous_reward <- relevel(data$previous_reward, "Reward")
data$previous_transition <- relevel(data$previous_transition, "common")
data$transition <- relevel(data$transition, "common")

#sanity check - ensure rare transitions were actually rare
transition_probs <- data %>%
  group_by(transition) %>%
  summarize(N = n())

#read in subject ages
sub_ages <- read_csv('data/decker/decker_ages.csv') %>%
  select(subject_id, age)
  
#combine with data
data <- full_join(data, sub_ages, by = "subject_id")

#add age groups to data 
data <- addAgeGroup(data, age)

#name output folder
output_folder <- "output/decker_data"

### RUN ANALYSES ###
source("regression_analyses.R")

#manually save model outputs
tab_model(stay.model, show.stat = F,
          string.ci = "CI (95%)",
          string.est = "Estimate", 
          dv.labels = c("First-stage choice repetition"),
          pred.labels = c("Intercept", 
                          "Reward", 
                          "Transition", 
                          "Age", 
                          "Reward x Transition",
                          "Reward x Age",
                          "Transition x Age",
                          "Reward x Transition x Age"),
          file = glue("{output_folder}/stay_model.html"))

#save chi-squared and p values from model as .txt file to merge with html table
chisqdf <- tibble(chisq = stay.model$anova_table$Chisq, p = round(stay.model$anova_table$`Pr(>Chisq)`, 6))
write_delim(chisqdf, glue("{output_folder}/stay_chisq.txt"), delim = "\t")

tab_model(rt.model, 
          show.stat = F,
          show.df = T,
          show.fstat = T,
          string.ci = "CI (95%)",
          string.est = "Estimate", 
          dv.labels = c("Second-stage reaction time"),
          pred.labels = c("Intercept", 
                          "Age",
                          "Transition", 
                          "Age x Transition"),
          file = glue("{output_folder}/rt_model.html"))

#save df, F, and p values from model as .txt file to merge with html table
fstat_df <- tibble(df = round(rt.model$anova_table$`den Df`, 2), f_stat = rt.model$anova_table$F, p = round(rt.model$anova_table$`Pr(>F)`, 6))
write_delim(fstat_df, glue("{output_folder}/rt_f.txt"), delim = "\t")


tab_model(rt.mb.model, 
          show.stat = T,
          show.se = T,
          string.ci = "CI (95%)",
          string.est = "Estimate", 
          string.stat = "t value",
          string.se = "SE",
          dv.labels = c("Model-based learning random effect"),
          pred.labels = c("Intercept", 
                          "RT Difference",
                          "Age", 
                          "RT Difference x Age"),
          file = glue("{output_folder}/rt_mb_model.html"))

# Compute stats on explicit knowledge of transition structure
explicit_data <- read_csv('data/decker/decker_ages.csv') %>%
  select(subject_id, explicit_q_correct, age)

explicit_data <- addAgeGroup(explicit_data, age)

explicit_stats <- explicit_data %>%
  group_by(age_group) %>%
  drop_na() %>%
  summarize(explicit_response_acc = mean(explicit_q_correct, na.rm = T),
            explicit_response_sd = sd(explicit_q_correct, na.rm = T),
            N = n(),
            explicit_response_se = explicit_response_sd/sqrt(N))

#save stats
write_delim(explicit_stats, path = glue("{output_folder}/explicit_q_acc.txt"), delim = "\t")

explicit_plot <- ggplot(explicit_stats, aes(x = age_group, y = explicit_response_acc)) +
  geom_bar(stat = "identity", position = "dodge", fill = "lightgrey", color = "black") +
  geom_errorbar(aes(ymin = explicit_response_acc - explicit_response_se, ymax = explicit_response_acc + explicit_response_se),
                width = .1) +
  coord_cartesian(ylim = c(0,1)) +
  xlab("Age Group") +
  ylab("Question Accuracy") +
  theme_minimal()
explicit_plot

#save plot
ggsave(glue("{output_folder}/explicit_q_acc.png"), plot = last_plot(), height = 3, width = 4, unit = "in", dpi = 300)


#test to see whether there's an effect of age on explicit knowledge
explicit_data$age_z <- scale_this(explicit_data$age)
explicit.age.model <- glm(explicit_q_correct ~ age_z, data = explicit_data, family = "binomial")
tab_model(explicit.age.model, file = glue("{output_folder}/explicit_q_model.html"))

# --- --- --- --- --- --- #
#### 3. POTTER DATA #####
# --- --- --- --- --- --- #
data <- read_csv("data/potter/potter_data.dat") %>% 
  rename(subject_id = subj,
         previous_reward = lastwin,
         previous_transition = lasttransR,
         transition = currtransR) %>%
  mutate(rt_1 = s1rt * 1000,
         rt_2 = s2rt * 1000) %>%
  select(-c(s1rt, s2rt))

#recode factors
data$previous_reward <- factor(data$previous_reward, labels = c("No Reward", "Reward"), ordered = F)
data$previous_transition <- factor(data$previous_transition, labels = c("common", "rare"), ordered = F)
data$transition <- factor(data$transition, labels = c("common", "rare"), ordered = F)

#put factors in right order
data$previous_reward <- relevel(data$previous_reward, "Reward")
data$previous_transition <- relevel(data$previous_transition, "common")
data$transition <- relevel(data$transition, "common")

#sanity check - ensure rare transitions were actually rare
transition_probs <- data %>%
  group_by(transition) %>%
  summarize(N = n())

#read in subject ages
sub_ages <- read_csv('data/potter/potter_ages.csv') %>%
  select(subject_id, age) 

sub_ages$subject_id <- as.numeric(sub_ages$subject_id)

#combine with data
data <- full_join(data, sub_ages, by = "subject_id")

#add age groups to data 
data <- addAgeGroup(data, age)

#save unfiltered data
unfiltered_potter_data <- data

#name output folder
output_folder <- "output/potter_data"

# RUN ANALYSES #
source("regression_analyses.R")

#manually save model outputs
tab_model(stay.model, show.stat = F,
          string.ci = "CI (95%)",
          string.est = "Estimate", 
          dv.labels = c("First-stage choice repetition"),
          pred.labels = c("Intercept", 
                          "Reward", 
                          "Transition", 
                          "Age", 
                          "Reward x Transition",
                          "Reward x Age",
                          "Transition x Age",
                          "Reward x Transition x Age"),
          file = glue("{output_folder}/stay_model.html"))

#save chi-squared and p values from model as .txt file to merge with html table
chisqdf <- tibble(chisq = stay.model$anova_table$Chisq, p = round(stay.model$anova_table$`Pr(>Chisq)`, 6))
write_delim(chisqdf, glue("{output_folder}/stay_chisq.txt"), delim = "\t")

tab_model(rt.model, 
          show.stat = F,
          show.df = T,
          show.fstat = T,
          string.ci = "CI (95%)",
          string.est = "Estimate", 
          dv.labels = c("Second-stage reaction time"),
          pred.labels = c("Intercept", 
                          "Age",
                          "Transition", 
                          "Age x Transition"),
          file = glue("{output_folder}/rt_model.html"))

#save df, F, and p values from model as .txt file to merge with html table
fstat_df <- tibble(df = round(rt.model$anova_table$`den Df`, 2), f_stat = rt.model$anova_table$F, p = round(rt.model$anova_table$`Pr(>F)`, 6))
write_delim(fstat_df, glue("{output_folder}/rt_f.txt"), delim = "\t")


tab_model(rt.mb.model, 
          show.stat = T,
          show.se = T,
          string.ci = "CI (95%)",
          string.est = "Estimate", 
          string.stat = "t value",
          string.se = "SE",
          dv.labels = c("Model-based learning random effect"),
          pred.labels = c("Intercept", 
                          "RT Difference",
                          "Age", 
                          "RT Difference x Age"),
          file = glue("{output_folder}/rt_mb_model.html"))


# Compute stats on explicit knowledge of transition structure
explicit_data <- read_csv('data/potter/potter_ages.csv') %>%
  select(subject_id, explicit_q_correct, age) %>%
  filter(!is.na(explicit_q_correct))

#Add age group
explicit_data <- addAgeGroup(explicit_data, age)

#compute stats
explicit_stats <- explicit_data %>%
  group_by(age_group) %>%
  summarize(explicit_response_acc = mean(explicit_q_correct),
            explicit_response_sd = sd(explicit_q_correct),
            N = n(),
            explicit_response_se = explicit_response_sd/sqrt(N))

#save stats
write_delim(explicit_stats, path = glue("{output_folder}/explicit_q_acc.txt"), delim = "\t")

explicit_plot <- ggplot(explicit_stats, aes(x = age_group, y = explicit_response_acc)) +
  geom_bar(stat = "identity", position = "dodge", fill = "lightgrey", color = "black") +
  geom_errorbar(aes(ymin = explicit_response_acc - explicit_response_se, ymax = explicit_response_acc + explicit_response_se),
                width = .1) +
  coord_cartesian(ylim = c(0,1)) +
  xlab("Age Group") +
  ylab("Question Accuracy") +
  theme_minimal()
explicit_plot

#save plot
ggsave(glue("{output_folder}/explicit_q_acc.png"), plot = last_plot(), height = 3, width = 4, unit = "in", dpi = 300)

#test to see whether there's an effect of age on explicit knowledge
explicit_data$age_z <- scale_this(explicit_data$age)
explicit.age.model <- glm(explicit_q_correct ~ age_z, data = explicit_data, family = "binomial")
tab_model(explicit.age.model, file = glue("{output_folder}/explicit_q_model.html"))