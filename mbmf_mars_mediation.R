#### MBMF - Mars mediation ####
# Kate Nussenbaum - katenuss@nyu.edu
# Last updated: 7/17/20

# Does accuracy on the MaRS-IB mediate the relation between age and model-based behavior?

#### LIBRARIES AND FUNCTIONS ####
library(glue)
library(magrittr)
library(afex)
library(mediation)
library(diagram)
library(tidyverse)

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


##############################
#### 1. Process mbmf data ####
##############################
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
  dplyr::select(c(trial_index,
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
  dplyr::select(-trial_index, -temp_trial) %>%
  pivot_wider(names_from = c(trial_stage), 
              values_from = c(transition, reward, choice, rt)) %>%
  dplyr::select(subject_id, practice_trial, age, trial, transition_2, reward_2, choice_1, choice_2, rt_1, rt_2) %>%
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

### Logistic regression w/o age ###
stay.model.no.age <- mixed(stay ~ previous_reward * previous_transition + (previous_reward * previous_transition|subject_id), 
                           family = "binomial", 
                           data = data, 
                           control = glmerControl(optimizer = "bobyqa"),
                           return = "merMod",
                           method = "LRT")
res <- ranef(stay.model.no.age)
fes <- fixef(stay.model.no.age)
subject_id <- row.names(res$subject_id)
mb_effect <- res$subject_id$`previous_reward1:previous_transition1` + fes[[4]]

mb_index <- data.frame(subject_id, mb_effect) 
sub_ages$subject_id <- factor(sub_ages$subject_id)

mb_age <- full_join(mb_index, sub_ages, by = "subject_id")


##############################
#### 2. Process mars data ####
##############################

#get list of files
mars_files <- list.files(path = "../../mars/mars_analysis/data/")

#initialize data frame
mars_data <- data.frame()

# Read in data
for (i in c(1:length(data_files))){
  sub_data <- read_csv(glue("../../mars/mars_analysis/data/{mars_files[i]}")) 
  
  #get task date from filename
  task_date <- sapply(strsplit(glue("../../mars/mars_analysis/data/{mars_files[i]}"), '_'), `[`, 4)
  sub_data$task_date <- task_date
  
  #compute the number of browser interactions
  num_interactions = length(str_split(tail(sub_data,1)$interactions, pattern = "\r\n")[[1]]) - 2
  sub_data$num_interactions <- num_interactions
  
  #compute number of practice trials answered correctly
  num_quiz_correct = nrow(sub_data %>% filter(sub_data$part == "practice"))
  sub_data$correct_quiz_questions <- num_quiz_correct
  
  #combine subject data into larger data frame
  mars_data <- rbind(mars_data, sub_data)
}

#select only the columns we care about
mars_data %<>% 
  dplyr::select(c(trial_index,
           subject_id, 
           task_date,
           rt,
           correct,
           correct_quiz_questions,
           num_interactions)) %>%
  filter(mars_data$part == "exp")

mars_data$rt <- as.numeric(mars_data$rt)

#compute stats
mars_summary <- mars_data %>%
  group_by(subject_id) %>%
  summarize(num_quiz_correct = mean(correct_quiz_questions, na.rm = T),
            num_correct = sum(correct, na.rm = T),
            num_trials = length(trial_index))

mars_summary %<>% mutate(mars_acc = num_correct/num_trials) %>%
  dplyr::select(subject_id, mars_acc)

#######################################
#### 3. Perform mediation analysis ####
#######################################
data <- inner_join(mb_age, mars_summary) %>%
  drop_na()

#standardize all values
data$mb_effect_z <- scale_this(data$mb_effect)
data$age_z <- scale_this(data$age)
data$mars_acc_z <- scale_this(data$mars_acc)

# Does mars accuracy mediate the relation between age and mb effect?

# DV: MB-learning
# IV: Age
# Mediator: MaRS Accuracy

# Step 1: The total effect - is there a relation between age and mb? DV ~ IV
fit.totaleffect <- lm(mb_effect_z ~ age_z, data)
summary(fit.totaleffect)

# Answer: Yes.

# Step 2: The effect of the IV on the mediator - is there a relation between age and mars accuracy?
# Mediator ~ IV
fit.mediator <- lm(mars_acc_z ~ age_z, data)
summary(fit.mediator)

# Answer: Yes

# Step 3: The effect of the mediator on the DV whiel controlling for the IV
# Is there a relation between mars acc and mb when controlling for age?
# DV ~ IV + Mediator
fit.dv <- lm(mb_effect_z ~ age_z + mars_acc_z, data)
summary(fit.dv)


# Answer: Yes - evidence for a partial mediation

# Step 4: Causal mediation analysis - treat = IV, mediator = mediator
results = mediate(fit.mediator, fit.dv, treat='age_z', mediator='mars_acc_z', boot=T)
summary(results)


# Determine strings for plotting
a_string = round(fit.mediator$coefficients[[2]],3)
b_string = round(fit.dv$coefficients[[3]],3)
c_string = round(fit.totaleffect$coefficients[[2]],3)
c_prime = round(fit.dv$coefficients[[2]],3)


# Plot mediation results - need to manually adjust asterisks
plot_data <- c(0, glue("'a = {a_string}***'"), 0,
          0, 0, 0, 
          glue("'b = {b_string}***'"), glue("'c = {c_string}*** 
                                          c` = {c_prime}**'"), 0)
M <- matrix(nrow=3, ncol=3, byrow = TRUE, data=plot_data)
plot <- plotmat(M, pos=c(1,2), 
                name = c( "Fluid reasoning","Age", "Model-based learning"), 
                box.type = "rect", box.size = 0.12, box.prop=0.5, curve=0)
