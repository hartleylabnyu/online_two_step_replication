## Check mbmf data quality ##
# Kate Nussenbaum - katenuss@nyu.edu
# Last updated: 7/17/20

# This script reads in all mbmf data files and saves a .txt file with 
# mean data quality metrics across age groups, as well as plots of metrics
# across all subs and binned by age

#### Load needed libraries ####
library(tidyverse)
library(glue)
library(magrittr)

# age group function
# Add age group variable to data frame with raw ages
addAgeGroup <- function(df, ageColumn){
  ageColumn <- enquo(ageColumn)
  df %>% mutate(age_group = case_when((!! ageColumn) < 13 ~ "Children",
                                      (!! ageColumn) > 12.9 & (!! ageColumn) < 18 ~ "Adolescents",
                                      (!! ageColumn) >= 18 ~ "Adults"), 
                age_group = factor(age_group, levels = c("Children", "Adolescents", "Adults")))
  
}

#get list of files
data_files <- list.files(path = "data/online/online_csvs/")

#initialize data frame
data <- data.frame()

#### Read in data ####
for (i in c(1:length(data_files))){
  sub_data <- read_csv(glue("data/online/online_csvs/{data_files[i]}")) 
  
  #get task date from filename
  task_date <- sapply(strsplit(glue("data/online/online_csvs/{data_files[i]}"), '_'), `[`, 4)
  sub_data$task_date <- task_date
  
  #compute the number of browser interactions
  num_interactions = length(str_split(tail(sub_data,1)$interactions, pattern = "\r\n")[[1]]) - 2
  sub_data$num_interactions <- num_interactions
  
  #compute number of quiz questions answered correctly
  num_quiz_correct = nrow(sub_data %>% filter(grepl('Correct.wav', stimulus)))
  sub_data$correct_quiz_questions <- num_quiz_correct
  
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
  data <- rbind(data, sub_data)
}

#select only the columns we care about
data %<>% 
  select(c(trial_index,
           subject_id, 
           task_date,
           choice,
           rt, 
           trial_stage,
           transition,
           practice_trial,
           reward,
           num_interactions,
           correct_quiz_questions,
           explicit_q_correct,
           explicit_rt)) %>%
  filter(practice_trial == "real")

data$rt <- as.numeric(data$rt)

#compute stats
summary_stats <- data %>%
  group_by(subject_id, task_date) %>%
  summarize(num_quiz_correct = mean(correct_quiz_questions, na.rm = T),
            reward_earned = sum(reward, na.rm = T),
            left_choices =sum(choice==1, na.rm = T),
            right_choices =sum(choice==2, na.rm = T),
            missed_responses = sum(is.na(choice)),
            mean_rt = mean(rt, na.rm = T),
            fast_rts = sum(rt < 150, na.rm = T),
            browser_interactions = mean(num_interactions, na.rm = T),
            explicit_q_correct = mean(explicit_q_correct, na.rm = T),
            explicit_rt = mean(explicit_rt, na.rm = T))


#read in subject ages
sub_ages <- read_csv('data/online/mbmf_ages.csv') 
sub_ages$subject_id <- as.character(sub_ages$subject_id)

#combine with summary stats
summary_stats <- full_join(summary_stats, sub_ages, by = "subject_id")

#add age group
summary_stats <- addAgeGroup(summary_stats, age)

stats_to_plot <- summary_stats %>%
  select(fast_rts, browser_interactions, num_quiz_correct, missed_responses, age_group)


#### Make histograms ####

#Fast RTs
rts_hist <- ggplot(stats_to_plot, aes(x = fast_rts)) +
  geom_histogram(bins = 50, fill = "grey", color = "black", center = T) +
  xlab("Number of RTs < 150 ms") +
  ylab("Number of participants") +
  theme_minimal() 
rts_hist

ggsave('output/online_data/quality_checking/rts_hist.png', plot = last_plot(), height = 2.5, width = 3, unit = "in", dpi = 300)


#Comprehension questions
quiz_hist <- ggplot(stats_to_plot, aes(x = num_quiz_correct)) +
  geom_histogram(bins = 3, fill = "grey", color = "black", center = T) +
  xlab("Comprehension questions correct") +
  ylab("Number of participants") +
  theme_minimal() 
quiz_hist

ggsave('output/online_data/quality_checking/quiz_hist.png', plot = last_plot(), height = 2.5, width = 3, unit = "in", dpi = 300)



#browser interactions
browser_hist <- ggplot(stats_to_plot, aes(x = browser_interactions)) +
  geom_histogram(bins = 30, fill = "grey", color = "black", center = T) +
  xlab("Number of browser interactions") +
  ylab("Number of participants") +
  theme_minimal() 
browser_hist

ggsave('output/decker_data/quality_checking/browser_hist.png', plot = last_plot(), height = 2.5, width = 3, unit = "in", dpi = 300)


#missed responses
missed_hist <- ggplot(stats_to_plot, aes(x = missed_responses)) +
  geom_histogram(bins = 50, fill = "grey", color = "black", center = T) +
  xlab("Number of missed responses") +
  ylab("Number of participants") +
  theme_minimal()
missed_hist

ggsave('output/online_data/quality_checking/missed_hist.png', plot = last_plot(), height = 2.5, width = 3, unit = "in", dpi = 300)



#histograms with age group
stats_to_plot <- stats_to_plot %>%
  filter(age_group == "Children" | age_group == "Adolescents" | age_group == "Adults")


#Fast RTs
rts_hist_age <- ggplot(stats_to_plot, aes(x = fast_rts, fill = age_group)) +
  facet_wrap(~age_group) +
  geom_histogram(bins = 20, center = T, position = "dodge", color = "black") +
  scale_fill_brewer(palette = "Set2") +
  xlab("Number of RTs < 150 ms") +
  ylab("Number of participants") +
  theme_minimal() +
  theme(legend.position = "none")
rts_hist_age

ggsave('output/online_data/quality_checking/rts_hist_age.png', plot = last_plot(), height = 2.5, width = 5, unit = "in", dpi = 300)


#Comprehension questions
quiz_hist_age <- ggplot(stats_to_plot, aes(x = num_quiz_correct, fill = age_group)) +
  facet_wrap(~age_group) +
  scale_fill_brewer(palette = "Set2") +
  geom_histogram(bins = 3, color = "black", center = T) +
  xlab("Comprehension questions correct") +
  ylab("Number of participants") +
  theme_minimal() +
  theme(legend.position = "none")
quiz_hist_age

ggsave('output/online_data/quality_checking/quiz_hist_age.png', plot = last_plot(), height = 2.5, width = 5, unit = "in", dpi = 300)


#browser interactions
browser_hist_age <- ggplot(stats_to_plot, aes(x = browser_interactions, fill = age_group)) +
  facet_wrap(~age_group) +
  scale_fill_brewer(palette = "Set2") +
  geom_histogram(bins = 10, color = "black", center = T) +
  xlab("Number of browser interactions") +
  ylab("Number of participants") +
  theme_minimal() +
  theme(legend.position = "none")
browser_hist_age

ggsave('output/online_data/quality_checking/browser_hist_age.png', plot = last_plot(), height = 2.5, width = 5, unit = "in", dpi = 300)


#missed responses
missed_hist_age <- ggplot(stats_to_plot, aes(x = missed_responses, fill = age_group)) +
  facet_wrap(~age_group) +
  scale_fill_brewer(palette = "Set2") +
  geom_histogram(bins = 20, color = "black", center = T) +
  xlab("Number of missed responses") +
  ylab("Number of participants") +
  theme_minimal() +
  theme(legend.position = "none")
missed_hist_age

ggsave('output/online_data/quality_checking/missed_hist_age.png', plot = last_plot(), height = 2.5, width = 5, unit = "in", dpi = 300)



#### Compute age group stats ####
age_group_stats <- stats_to_plot %>% 
  group_by(age_group) %>%
  summarise(across(
    .cols = is.numeric, 
    .fns = list(mean = mean, sd = sd, median = median), na.rm = TRUE, 
    .names = "{col}_{fn}"
  ))

age_group_stats <- age_group_stats %>% 
  mutate_if(is.numeric, round, digits = 3)

write_delim(age_group_stats, 'output/online_data/quality_checking/age_group_stats.txt',
            delim = "\t")

#### Age and gender distribution ####
sub_ages_plot <- ggplot(sub_ages, aes(x = age, fill = gender)) +
  geom_histogram(breaks = c(8:26), color = "black") +
  scale_fill_brewer(type = "seq", name = "Gender") +
  ylab("Number of participants") +
  xlab("Age (years)") +
  theme_minimal() 
sub_ages_plot

ggsave('output/online_data/quality_checking/sub_ages.png', plot = last_plot(), height = 2.5, width = 5, unit = "in", dpi = 300)



