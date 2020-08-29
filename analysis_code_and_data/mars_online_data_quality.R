## Check MaRs-IB data ##
# Kate Nussenbaum - katenuss@nyu.edu
# Last updated: 7/17/20

# This script reads in all mars data files and computes summary stats on data quality metrics.
# It also saves histograms (overall and by age group) showing the distribution of these metrics.

# Load needed libraries
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
data_files <- list.files(path = "data/online_mars/sub_csvs")

#initialize data frame
data <- data.frame()

# read in data
for (i in c(1:length(data_files))){
  sub_data <- read_csv(glue("data/online_mars/sub_csvs/{data_files[i]}")) 
  
  
  # compute the number of browser interactions
  num_interactions = length(str_split(tail(sub_data,1)$interactions, pattern = "\r\n")[[1]]) - 2
  sub_data$num_interactions <- num_interactions
  
  # compute number of practice trials answered correctly
  num_quiz_correct = nrow(sub_data %>% filter(sub_data$part == "practice"))
  sub_data$correct_quiz_questions <- num_quiz_correct
  
  # combine subject data into larger data frame
  data <- rbind(data, sub_data)
}

# select only the columns we care about
data %<>% 
  select(c(trial_index,
           subject_id,
           rt,
           correct,
           correct_quiz_questions,
           num_interactions)) %>%
  filter(data$part == "exp")

data$rt <- as.numeric(data$rt)
data$subject_id <- as.factor(data$subject_id)

# compute stats
summary_stats <- data %>%
  group_by(subject_id) %>%
  summarize(num_quiz_correct = mean(correct_quiz_questions, na.rm = T),
            num_correct = sum(correct, na.rm = T),
            num_trials = length(trial_index),
            mean_rt = mean(rt, na.rm = T),
            median_rt = median(rt, na.rm = T),
            fast_rts = sum(rt < 250, na.rm = T),
            missed_responses = sum(is.na(rt)),
            browser_interactions = mean(num_interactions, na.rm = T))


#read in subject ages
sub_ages <- read_csv('data/online_mars/wasi_data.csv') 

#combine with summary stats
summary_stats <- full_join(summary_stats, sub_ages, by = "subject_id")

#add age group
summary_stats <- addAgeGroup(summary_stats, age)


stats_to_plot <- summary_stats %>%
  select(fast_rts, browser_interactions, num_quiz_correct, missed_responses, age_group)

#histograms

#Fast RTs
rts_hist <- ggplot(stats_to_plot, aes(x = fast_rts)) +
  geom_histogram(bins = 50, fill = "grey", color = "black", center = T) +
  xlab("Number of RTs < 250 ms") +
  ylab("Number of participants") +
  theme_minimal() 
rts_hist

ggsave('output/mars/quality_checking/rts_hist.png', plot = last_plot(), height = 2.5, width = 3, unit = "in", dpi = 300)


#Comprehension questions
quiz_hist <- ggplot(stats_to_plot, aes(x = num_quiz_correct)) +
  geom_histogram(binwidth = 1, fill = "grey", color = "black", center = T) +
  xlab("Practice trials needed") +
  ylab("Number of participants") +
  theme_minimal() 
quiz_hist

ggsave('output/mars/quality_checking/quiz_hist.png', plot = last_plot(), height = 2.5, width = 3, unit = "in", dpi = 300)



#browser interactions
browser_hist <- ggplot(stats_to_plot, aes(x = browser_interactions)) +
  geom_histogram(binwidth = 1, fill = "grey", color = "black", center = T) +
  xlab("Number of browser interactions") +
  ylab("Number of participants") +
  theme_minimal() 
browser_hist

ggsave('output/mars/quality_checking/browser_hist.png', plot = last_plot(), height = 2.5, width = 3, unit = "in", dpi = 300)


#missed responses
missed_hist <- ggplot(stats_to_plot, aes(x = missed_responses)) +
  geom_histogram(bins = 5, fill = "grey", color = "black", center = T) +
  xlab("Number of missed responses") +
  ylab("Number of participants") +
  theme_minimal()
missed_hist

ggsave('output/mars/quality_checking/missed_hist.png', plot = last_plot(), height = 2.5, width = 3, unit = "in", dpi = 300)



#histograms with age group
stats_to_plot <- stats_to_plot %>%
  filter(age_group == "Children" | age_group == "Adolescents" | age_group == "Adults")


#Fast RTs
rts_hist_age <- ggplot(stats_to_plot, aes(x = fast_rts, fill = age_group)) +
  facet_wrap(~age_group) +
  geom_histogram(bins = 5, center = T, position = "dodge", color = "black") +
  scale_fill_brewer(palette = "Set2") +
  xlab("Number of RTs < 250 ms") +
  ylab("Number of participants") +
  theme_minimal() +
  theme(legend.position = "none")
rts_hist_age

ggsave('output/mars/quality_checking/rts_hist_age.png', plot = last_plot(), height = 2.5, width = 5, unit = "in", dpi = 300)


#Comprehension questions
quiz_hist_age <- ggplot(stats_to_plot, aes(x = num_quiz_correct, fill = age_group)) +
  facet_wrap(~age_group) +
  scale_fill_brewer(palette = "Set2") +
  geom_histogram(binwidth = 1, color = "black", center = T) +
  xlab("Number of practice trials needed") +
  ylab("Number of participants") +
  theme_minimal() +
  theme(legend.position = "none")
quiz_hist_age

ggsave('output/mars/quality_checking/quiz_hist_age.png', plot = last_plot(), height = 2.5, width = 5, unit = "in", dpi = 300)



#browser interactions
browser_hist_age <- ggplot(stats_to_plot, aes(x = browser_interactions, fill = age_group)) +
  facet_wrap(~age_group) +
  scale_fill_brewer(palette = "Set2") +
  geom_histogram(bins = 4, color = "black", center = T) +
  xlab("Number of browser interactions") +
  ylab("Number of participants") +
  theme_minimal() +
  theme(legend.position = "none")
browser_hist_age

ggsave('output/mars/quality_checking/browser_hist_age.png', plot = last_plot(), height = 2.5, width = 5, unit = "in", dpi = 300)


#missed responses
missed_hist_age <- ggplot(stats_to_plot, aes(x = missed_responses, fill = age_group)) +
  facet_wrap(~age_group) +
  scale_fill_brewer(palette = "Set2") +
  geom_histogram(bins = 5, color = "black", center = T) +
  xlab("Number of missed responses") +
  ylab("Number of participants") +
  theme_minimal() +
  theme(legend.position = "none")
missed_hist_age

ggsave('output/mars/quality_checking/missed_hist_age.png', plot = last_plot(), height = 2.5, width = 5, unit = "in", dpi = 300)



#### Compute age group medians ####
age_group_stats <- stats_to_plot %>% 
  group_by(age_group) %>%
  summarise(across(
    .cols = where(is.numeric), 
    .fns = list(mean = mean, sd = sd, median = median), na.rm = TRUE, 
    .names = "{col}_{fn}"
  ))

age_group_stats <- age_group_stats %>% 
  mutate_if(is.numeric, round, digits = 3)

write_delim(age_group_stats, 'output/mars/quality_checking/mars_age_group_stats.txt',
            delim = "\t")


#### Make summary table ####
mars_data_summary <- stats_to_plot %>%
  group_by(age_group) %>%
  summarize(three_quiz = sum(num_quiz_correct == 3),
            four_quiz = sum(num_quiz_correct <= 4),
            five_quiz = sum(num_quiz_correct <=5),
            browser_int_under_3 = sum(browser_interactions <= 3),
            browser_int_under_5 = sum(browser_interactions <= 5),
            browser_int_under_10 = sum(browser_interactions <= 10),
            missed_under_3 = sum(missed_responses <= 3),
            missed_under_5 = sum(missed_responses <= 5),
            missed_under_10 = sum(missed_responses <= 10),
            fast_under_3 = sum(fast_rts <= 3),
            fast_under_5 = sum(fast_rts <= 5),
            fast_under_10 = sum(fast_rts <= 10)
  )
mars_data_summary