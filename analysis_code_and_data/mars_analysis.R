#################################
## Data Analysis: MaRs-IB & Wasi
#################################

# Maximilian Scheuplein; maximilian.scheuplein@nyu.edu
# Kate Nussenbaum; katenuss@nyu.edu
# Last updated: 7/17/20 - KN


# This analyzes data from the MaRs-IB task, based on
# the analyses used by Chierchia et al., 2019 (with some additions and modifications)

# It saves the following summary statistics, model outputs and plots:
# 1.) summary statistics for age groups
# 2.) summary statistics for subjects
# 3.) results of mars accuracy by age
# 4.) plots of mars accuracy by age
# 5.) results of mars accuracy by item dimensionality score
# 6.) plot of mars accuracy by item dimensionality score
# 7.) results of mars RTs by age
# 8.) results of mars log transformed RTs by age
# 9.) plot of mars RTs by age
# 10.) results of mars RTs by item dimensionality score
# 11.) results of mars number of items completed by age
# 12.) plot of mars number of items completed by age
# 13.) results of mars inverse efficiency by age
# 14.) plot of mars inverse efficiency by age
# 15.) results from regression looking at relation between raw wasi mr score & mars accuracy
# 16.) plot showing relation between raw wasi mr score & mars accuracy
# 17.) plot showing interaction between raw wasi mr score & mars accuracy by age_z



##########################
#### Setting the Stage ####
##########################
# load libraries
library(tidyverse)  # data import
library(glue)       # {}
library(magrittr)   #  (%<>%)
library(afex)       # mixed models
library(sjPlot)     # data visualization
#library(doBy)       # summaryBy function


# standard error function
se <- function(x) sd(x)/sqrt(length(x)) 

# define new function so that scale returns a vector, not a matrix
scale_this <- function(x) as.vector(scale(x))


###################
#### Mars Data ####
###################
# 1. get raw mars data
# list of files
data_files <- list.files(path = "data/online_mars/sub_csvs")

# initialize data frame
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
            timeout = sum(is.na(rt)),
            browser_interactions = mean(num_interactions, na.rm = T))

#### Add WASI Scores ####

# set wasi directory
path = "data/online_mars"

# load scores
wasi = read_csv(glue("{path}/wasi_data.csv"))

# merge summary and wasi data
summary_stats <- full_join(summary_stats, wasi, by="subject_id")


# add item dimensionality
# load scores
dm = read_csv(glue("{path}/item_dimensionality.csv"))

# create mars dataset
mars_raw <- data
mars_raw$correct <- factor(mars_raw$correct, levels = c("FALSE", "TRUE"), labels = c(0,1))

# add trials to mars dataset
mars_raw <- mars_raw %>% 
  group_by(subject_id) %>% 
  mutate(item = rank(trial_index)) %>%
  select(-trial_index)

# add dimensionality information to mars dataset
mars_dm_raw <- full_join(mars_raw, dm, by="item")

# create datafile with all variables
mars_total <- full_join(mars_dm_raw, summary_stats, by="subject_id")
mars_total$subject_id <- factor(mars_total$subject_id) # make subID a factor

# items with a response time under 250 ms as well as timed out trials get excluded from all subsequent analyses
mars_total_filter <- mars_total %>%
  filter(rt > 250)


# create final mars dataset: containing accuracy and inverse efficiency measures
mars  <-  mars_total_filter %>%
  rename(subID = subject_id) %>%
  mutate(acc = num_correct/num_trials,
         inv_e = median_rt/acc) %>%
  mutate(age_group = case_when(age < 11 ~ "Children",
                               age > 10.99 & age < 13 ~ "Younger adolescents",
                               age > 12.99 & age < 16 ~ "Mid adolescents",
                               age > 15.99 & age < 18 ~ "Older adolescents",
                               age > 17.99 ~ "Adults"))

mars$age_group <- factor(mars$age_group, levels = c("Children", 
                                                    "Younger adolescents",
                                                    "Mid adolescents",
                                                    "Older adolescents",
                                                    "Adults"))

# name output folder
output_folder <- "output/mars"



###########################
#### Summary Statistics ###
###########################
# get summary statistics for age groups
mars_summary <- mars %>%
  group_by(age_group) %>%
  summarize(mean_acc = mean(acc),
            se_acc = se(acc),
            med_rt = median(rt),
            se_rt = se(rt),
            med_rt_correct = median(rt[correct == 1]),
            se_rt_correct = se(rt[correct == 1]),
            mean_inv_e = mean(inv_e),
            se_inv_e = se(inv_e),
            mean_num_trials = mean(num_trials),
            se_num_trials = se(num_trials))

#save stats
write_delim(mars_summary, path = glue("{output_folder}/summary_stats_age_groups.txt"), delim = "\t")

# get summary statistics for subjects
mars_subs <- mars %>%
  group_by(subID, age_group, age, sex) %>%
  summarize(acc = mean(acc),
            med_rt = mean(median_rt),
            med_rt_correct = median(rt[correct == 1]),
            se_rt = se(rt),
            fast_rt = mean(fast_rts),
            browser_interactions = mean(browser_interactions),
            inv_e = mean(inv_e),
            num_trials = mean(num_trials),
            WASI_rawVerbal = mean(WASI_rawVerbal),
            WASI_raw_MR = mean(WASI_raw_MR), 
            WASI_Verbal_T = mean(WASI_Verbal_T), 
            WASI_MR_T = mean(WASI_MR_T), 
            WASI_IQ = mean(WASI_IQ))

#save stats
write_delim(mars_subs, path = glue("{output_folder}/summary_stats_subs.txt"), delim = "\t")


# get summary statistics for each age group
mars_group_summary <- mars_subs %>%
  group_by(age_group) %>%
  summarise(across(
    .cols = where(is.numeric), 
    .fns = list(mean = mean, median = median, sd = sd), na.rm = TRUE, 
    .names = "{col}_{fn}"
  ))
write_delim(mars_group_summary, path = glue("{output_folder}/summary_stats_grand_means.txt"), delim = "\t")




#########################
#### Accuracy by Age ####
#########################
# check for linear or quadratic effects of age on accuracy

mars$age_z <- scale_this(mars$age)
mars$age_z_sq <- (mars$age)^2

# Test for quadratic effect of age on accuracy
acc.age.model.1 <- mixed(correct ~ age_z + (1|subID) + (1|item), data = mars,
                       control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun=100000)), family ='binomial',
                       return = "merMod") 

acc.age.model.2 <- mixed(correct ~ age_z + age_z_sq + (1|subID) + (1|item), data = mars,
                         control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun=100000)), family ='binomial',
                         return = "merMod") 

# Does the quadratic model fit better?
anova(acc.age.model.1, acc.age.model.2) #not significant - No

# effect of age on accuracy 
acc.age.model <- mixed(correct ~ age_z + (1|subID) + (1|item), data = mars,
                       control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun=100000)), family ='binomial',
                       method = "LRT") # LRT = likelihood ratio test
acc.age.model

# manually save model outputs
tab_model(acc.age.model, show.stat = F,
          string.ci = "CI (95%)",
          string.est = "Estimate", 
          dv.labels = c("Accuracy by Age"),
          pred.labels = c("Intercept", 
                          "Age"),
          file = glue("{output_folder}/acc.age.model.html"))

# plot
data_summary <- function(x) {
  m <- mean(x)
  ymin <- m-sd(x)
  ymax <- m+sd(x)
  return(c(y=m,ymin=ymin,ymax=ymax))
}

# accuracy age groups violin plot
acc_plot <- ggplot(data=mars_subs, aes(x=age_group, y=acc, fill = age_group)) +
  geom_violin(trim = T) +
  geom_jitter(size = .5, alpha = .3, position=position_jitter(0.1, 0.1)) +
  stat_summary(fun.data=data_summary) +
  scale_fill_manual(values = c("#7f4e5e", "#fd958a", "#96bc2e", "#20ccd2", "#d59dff")) +
  ylab("Accuracy (%)") +
  xlab("Age group") +
  scale_y_continuous(labels=function(x)x*100)+
  coord_cartesian(ylim = c(0, 1)) + 
  theme_bw()+
  theme(legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.title = element_text(face = "bold"))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.border = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))
acc_plot

#save plot
ggsave(glue("{output_folder}/acc_violin_plot.png"), plot = last_plot(), height = 5, width = 7, unit = "in", dpi = 300)

# accuracy continuous age plot
acc_continuous_age_plot <- ggplot(mars_subs, aes(x = age, y = acc)) +
  geom_point() +
  stat_smooth(aes(y = acc), method = "lm", formula = y ~ poly(x, 1), color = "black") + # change regression line to quadratic --> poly(x, 2)
  ylab("Accuracy (%)") +
  xlab("Age")  +
  scale_y_continuous(labels=function(x)x*100)+
  coord_cartesian(ylim = c(0, 1)) + 
  theme_bw()+
  theme(legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.title = element_text(face = "bold"))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.border = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))
acc_continuous_age_plot

#save plot
ggsave(glue("{output_folder}/acc_continuous_age_plot.png"), plot = last_plot(), height = 3, width = 4, unit = "in", dpi = 300)



####################################
#### Accuracy by Dimensionality ####
#####################################
#z-score dimensionality
mars$dim_z <- scale_this(mars$dimensionality_score)

# effect of dimensionality on accuracy - sig effect
acc.dim.model <- mixed(correct ~ dim_z + (1|subID), data = mars,
                       control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun=100000)), family ='binomial',
                       method = "LRT")
acc.dim.model

# manually save model outputs
tab_model(acc.dim.model, show.stat = F,
          string.ci = "CI (95%)",
          string.est = "Estimate",
          dv.labels = c("Accuracy by Dimensionality"),
          pred.labels = c("Intercept", 
                          "Dimensionality Score (z)"),
          file = glue("{output_folder}/acc.dim.model.html"))

# accuracy age groups violin plot
mars_dim <- mars %>%
  group_by(dimensionality_score) %>%
  summarize(mean_acc = mean(acc),
            se_acc = se(acc))

# accuracy continuous age plot
acc_continuous_dim_plot <- ggplot(mars_dim, aes(x = dimensionality_score, y = mean_acc)) +
  geom_point() +
  stat_smooth(aes(y = mean_acc), method = "lm", formula = y ~ x, color = "black") + # change regression line to quadratic --> poly(x, 2)
  ylab("Accuracy (%)") +
  xlab("Dimensionality Score")  +
  scale_y_continuous(labels=function(x)x*100)+
  coord_cartesian(xlim = c(1, 8)) + 
  theme_bw()+
  theme(legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.title = element_text(face = "bold"))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.border = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))
acc_continuous_dim_plot

#save plot
ggsave(glue("{output_folder}/acc_continuous_dim_plot.png"), plot = last_plot(), height = 3, width = 4, unit = "in", dpi = 300)

# effect of dimensionality and age on accuracy 
acc.age.dim.model <- mixed(correct ~ age_z*dim_z + (1+dimensionality_score|subID), data = mars,
                       control = glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun=100000)), family ='binomial',
                       method = "LRT")
acc.age.dim.model


############################
#### Correct RTs by Age ####
############################

mars_correct_rts <- mars %>% 
  filter(correct == 1)
mars_correct_rts$log_rt <- log(mars_correct_rts$rt)
mars_correct_rts$age_z <- scale_this(mars_correct_rts$age)
mars_correct_rts$age_z_sq <- (mars_correct_rts$age)^2


#test for quadratic effect of age
log.correct.rt.age.model.1 <- mixed(log_rt ~ age_z + (1|subID), data = mars_correct_rts,
                                    control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun=100000)),
                                    return = "merMod")

log.correct.rt.age.model.2 <- mixed(log_rt ~ age_z + age_z_sq + (1|subID), data = mars_correct_rts,
                                  control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun=100000)),
                                  return = "merMod")

anova(log.correct.rt.age.model.1, log.correct.rt.age.model.2) #not significant

#run model
log.correct.rt.age.model <- mixed(log_rt ~ age_z + (1|subID), data = mars_correct_rts,
                          control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun=100000)),
                          method = "S")
log.correct.rt.age.model

tab_model(log.correct.rt.age.model, 
          show.stat = T,
          show.se = T,
          string.ci = "CI (95%)",
          string.est = "Estimate", 
          string.stat = "t value",
          string.se = "SE",
          dv.labels = c("Log(RTs) by Age"),
          pred.labels = c("Intercept", 
                          "Age"),
          file = glue("{output_folder}/log.correct.rt.age.model.html"))

# rt continuous age plot
rt_continuous_age_plot <- ggplot(mars_subs, aes(x = age, y = med_rt)) +
  geom_point() +
  stat_smooth(aes(y = med_rt), method = "lm", formula = y ~ poly(x, 1), color = "black") +
  ylab("Median Response Time (ms)") +
  xlab("Age")  +
  #coord_cartesian(ylim = c(0, 1)) + 
  theme_bw()+
  theme(legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.title = element_text(face = "bold"))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.border = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))
rt_continuous_age_plot

#save plot
ggsave(glue("{output_folder}/rt_correct_continuous_age_plot.png"), plot = last_plot(), height = 3, width = 4, unit = "in", dpi = 300)



###############################
#### RTs by Dimensionality ####
###############################
#scale dimensionality score
mars_correct_rts$dim_z <- scale_this(mars_correct_rts$dimensionality_score)

# effect of dimensionality on correct reaction times
rt.dim.model <- mixed(log_rt ~ dim_z + (1|subID), data = mars_correct_rts,
                      control = lmerControl(optimizer = "bobyqa", optCtrl = list(maxfun=100000)),
                      method = "S")
rt.dim.model

# manually save model outputs
tab_model(rt.dim.model, 
          show.stat = T,
          show.se = T,
          string.ci = "CI (95%)",
          string.est = "Estimate", 
          string.stat = "t value",
          string.se = "SE",
          dv.labels = c("RTs by Dimensionality"),
          pred.labels = c("Intercept", 
                          "Dimensionality Score (z)"),
          file = glue("{output_folder}/rt.dim.model.html"))



##########################################
#### Number of Items Completed by Age ####
##########################################

#scale age
mars_subs$age_z <- scale_this(mars_subs$age)
mars_subs$age_z_sq <- (mars_subs$age_z)^2

#test for quadratic effects of age
items.age.model.1 <- lm(num_trials ~ age_z, data = mars_subs)
items.age.model.2 <- lm(num_trials ~ age_z + age_z_sq, data = mars_subs)
anova(items.age.model.1, items.age.model.2) #not significant

items.age.model <- lm(num_trials ~ age_z, data = mars_subs)
summary(items.age.model)

# manually save model outputs
tab_model(items.age.model, show.stat = F,
          string.ci = "CI (95%)",
          string.est = "Estimate", 
          dv.labels = c("Number of Items Completed by Age"),
          pred.labels = c("Intercept", 
                          "Age"),
          file = glue("{output_folder}/no.I.age.model.html"))

# no. items completed age groups violin plot
items_plot <- ggplot(data=mars_subs, aes(x=age_group, y=num_trials, fill = age_group)) +
  geom_violin(trim = T) +
  geom_jitter(size = .5, alpha = .3, position=position_jitter(0.1, 0.1)) +
  stat_summary(fun.data=data_summary) +
  scale_fill_manual(values = c("#7f4e5e", "#fd958a", "#96bc2e", "#20ccd2", "#d59dff")) +
  ylab("No. of Items Completed") +
  xlab("Age group") +
  ylim(c(0, 85))+
  theme_bw()+
  theme(legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.title = element_text(face = "bold"))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.border = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))
items_plot

#save plot
ggsave(glue("{output_folder}/items_plot.png"), plot = last_plot(), height = 5, width = 7, unit = "in", dpi = 300)

# no. items completed continuous age plot
items_continuous_age_plot <- ggplot(mars_subs, aes(x = age, y = num_trials)) +
  geom_point() +
  stat_smooth(aes(y = num_trials), method = "lm", formula = y ~ x, color = "black") +
  ylab("No. of Items Completed") +
  xlab("Age")  +
  #coord_cartesian(ylim = c(0, 1)) + 
  theme_bw()+
  theme(legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.title = element_text(face = "bold"))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.border = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))
items_continuous_age_plot
ggsave(glue("{output_folder}/items_continuous_plot.png"), plot = last_plot(), height = 3, width = 4, unit = "in", dpi = 300)




####################################
##### Inverse Efficiency by Age ####
#####################################
# inverse efficiency = median RTs/accuracy
# check for linear, quadratic or cubic age effects on inverse efficiency
in.e.model.1 <- lm(inv_e ~ age_z, data = mars_subs)
in.e.model.2 <- lm(inv_e ~ age_z + age_z_sq, data = mars_subs)
anova(in.e.model.1, in.e.model.2) #not significant

# effect of age on inverse efficiency - not sig
inv.e.age.model <- lm(inv_e ~ age_z, data = mars_subs)
summary(inv.e.age.model)

# manually save model outputs
tab_model(inv.e.age.model, show.stat = F,
          string.ci = "CI (95%)",
          string.est = "Estimate", 
          dv.labels = c("Inverse Efficiency by Age"),
          pred.labels = c("Intercept", 
                          "Age"),
          file = glue("{output_folder}/inv.e.age.model.html"))

# inverse efficiency age groups violin plot
in.e_plot <- ggplot(data=mars_subs, aes(x=age_group, y= inv_e, fill = age_group)) +
  geom_violin(trim = T) +
  geom_jitter(size = .5, alpha = .3, position=position_jitter(0.1, 0.1)) +
  stat_summary(fun.data=data_summary) +
  scale_fill_manual(values = c("#7f4e5e", "#fd958a", "#96bc2e", "#20ccd2", "#d59dff")) +
  ylab("Inverse Efficiency") +
  xlab("Age group") +
  #ylim(c(0, 30000))+
  coord_cartesian(ylim = c(0, 30000)) + 
  theme_bw()+
  theme(legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.title = element_text(face = "bold"))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.border = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))
in.e_plot

#save plot
ggsave(glue("{output_folder}/in.e_plot.png"), plot = last_plot(), height = 5, width = 7, unit = "in", dpi = 300)

# inverse efficiency continuous age plot
in.e_continuous_age_plot <- ggplot(mars_subs, aes(x = age, y = inv_e)) +
  geom_point() +
  stat_smooth(aes(y = inv_e), method = "lm", formula = y ~ x, color = "black") +
  ylab("Inverse Efficiency (ms)") +
  xlab("Age")  +
  coord_cartesian(ylim = c(0, 25000)) + 
  theme_bw()+
  theme(legend.position = "none",
        panel.grid.minor = element_blank(),
        axis.title = element_text(face = "bold"))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.border = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))
in.e_continuous_age_plot

#save plot
ggsave(glue("{output_folder}/in.e_continuous_age_plot.png"), plot = last_plot(), height = 3, width = 4, unit = "in", dpi = 300)



########################
#### MaRs-IB ~ WASI ####
########################
# create dataset
wasi_data <- mars_subs %>%
  rename(wasi_mr = WASI_raw_MR,
            wasi_verbal = WASI_rawVerbal,
            wasi_IQ = WASI_IQ) %>%
  filter(wasi_mr > 0)

wasi_data$age_z <- scale_this(wasi_data$age)
wasi_data$wasi_mr_z <- scale_this(wasi_data$wasi_mr)

# Examine relation between WASI MR and mars-accuracy
wasi.mars <- lm(acc ~ wasi_mr_z * age_z , data = wasi_data)
summary(wasi.mars)

# manually save model outputs
tab_model(wasi.mars, 
          show.stat = F,
          string.ci = "CI (95%)",
          string.est = "Estimate", 
          dv.labels = c("MaRs-IB ~ WASI"),
          pred.labels = c("Intercept", 
                          "WASI MR",
                          "Age",
                          "WASI MR * Age"),
          file = glue("{output_folder}/wasi.mars.html"))


#add age group to plot
wasi_data <- wasi_data %>%
  mutate(age_group_2 = case_when(age < 13 ~ "Children",
                                 age > 12.99 & age < 18 ~ "Adolescents",
                                 age > 18 ~ "Adults")) 

wasi_data$age_group_2 <- factor(wasi_data$age_group_2, levels = c("Children", "Adolescents", "Adults"))

# plot
wasi_plot <- ggplot(wasi_data, aes(y = acc, x = wasi_mr)) +
  geom_point() +
  geom_smooth(method = "lm", color = "black") +
 # scale_fill_brewer(palette = "Set2", name = "Age Group") +
#  scale_color_brewer(palette = "Set2", name = "Age Group") +
  xlab("Raw WASI MR Score") +
  ylab("MaRs-IB Accuracy") +
  theme_bw() +
  theme(panel.grid.minor = element_blank(),
        axis.title = element_text(face = "bold"))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.border = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))
wasi_plot


#save plot
ggsave(glue("{output_folder}/wasi_plot.png"), plot = last_plot(), height = 3, width = 5, unit = "in", dpi = 300)
