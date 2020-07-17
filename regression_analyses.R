## MBMF Regression analyses ##
# Kate Nussenbaum - katenuss@nyu.edu
# Last updated: 7/17/20

# This script analyzes mbmf data that has already been processed into a dataframe 
# by the script "mbmf_analyze_all_datasets.R" To run, it requires a dataframe (called 'data') 
# w/ all relevant task variables, a dataframe called "sub_ages" w/ subject_ids and ages
# and a 'folder_name' where model outputs and figures are saved. 

# It runs the following models and creates plots:
# 1.) repeated-choice logistic regression
# 2.) plot of stay probability by age group
# 3.) plot of MB effect by continuous age
# 4.) second-stage RT linear regression
# 5.) plot of second-stage RT by age group
# 6.) regression looking at relation between RT & MB effect
# 7.) plot showing relation between RT slowing and MB effect by age group

theme_set(theme_minimal(base_size = 18))

################################################
#### 1. Stay logistic regression ####
################################################
# Z-score age
data$age_z <- scale_this(data$age)

#run model
stay.model <- mixed(stay ~ previous_reward * previous_transition * age_z + (previous_reward * previous_transition|subject_id), 
                    family = "binomial", 
                    data = data, 
                    control = glmerControl(optimizer = "bobyqa"),
                    expand_re = T,
                    method = "LRT")
stay.model



################################################
#### 2. Plot stay probability by age group ####
################################################

# First plot individual subs
stay_stats <- data %>%
  group_by(previous_reward, previous_transition, subject_id, age_group) %>%
  summarize(mean_stay = mean(stay, na.rm = T),
            n = n()) %>%
  drop_na 

stay_plot_subs <- ggplot(stay_stats, aes(x = previous_reward, 
                                    y = mean_stay,
                                    fill = previous_transition)) +
  geom_bar(position = "dodge", stat = "identity", color = "black") +
  xlab("Outcome of Previous Trial") +
  ylab("Probability of First-Stage Stay") +
  scale_fill_manual(values = c("royalblue4", "firebrick2"), name = "Previous Trial Transition") +
  theme_minimal() +
  facet_wrap(~subject_id) +
  theme(panel.grid = element_blank(),
        axis.line = element_line(size = .2),
        legend.position = "top")
stay_plot_subs

#save individual sub plot
ggsave(filename = glue("{output_folder}/stay_plot_subs.png"), plot = last_plot(), width = 14, height = 12, units = "in", dpi = 300)


# Plot proportion of stay trials by age group 
stay_stats_group <- stay_stats %>%
  group_by(previous_reward, previous_transition, age_group) %>%
  summarize(stay_prop = mean(mean_stay),
            sd_stay = sd(mean_stay, na.rm = T),
            N = n(),
            se_stay = sd_stay/sqrt(N))

n_children <- stay_stats_group$N[1]
n_adolescents <- stay_stats_group$N[2]
n_adults <- stay_stats_group$N[3]

#create age group labels
age_group_labels = c(Children = glue("Children (n = {n_children})"),
                     Adolescents = glue("Adolescents (n = {n_adolescents})"),
                     Adults = glue("Adults (n = {n_adults})"))

stay_plot <- ggplot(stay_stats_group, aes(x = previous_reward, 
                                         y = stay_prop,
                                         fill = previous_transition)) +
  geom_bar(position = "dodge", stat = "identity", color = "black") +
  geom_errorbar(position = position_dodge(width = .9), aes(ymin = stay_prop - se_stay, ymax = stay_prop + se_stay), width = 0) + 
  facet_wrap(~age_group, labeller = labeller(age_group = age_group_labels)) +
  xlab("Outcome of Previous Trial") +
  ylab("Proportion of of First-Stage Stays") +
  coord_cartesian(ylim = c(.5, 1)) +
  scale_fill_manual(values = c("royalblue4", "firebrick2"), name = "Previous Trial Transition") +
  theme_minimal() +
  theme(panel.grid = element_blank(),
        axis.line = element_line(size = .2),
        legend.position = "top",
        strip.text.x = element_text(size = 10.5),
        axis.title = element_text(size = 10),
        axis.text = element_text(size = 9.5)
        )
stay_plot

#save group plot
ggsave(filename = glue("{output_folder}/stay_plot_age_group.png"), plot = last_plot(), width = 5, height = 3, units = "in", dpi = 300)


################################################
#### 3. Plot of MB effect by continuous age ####
################################################

### Logistic regression w/o age for plotting ###
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
mb_plot <- ggplot(mb_age, aes(x = age, y = mb_effect)) +
  geom_point() +
  geom_smooth(method = "lm", color = "black") +
  theme_minimal() +
  ylab("Reward x Transition Interaction Effect") +
  scale_x_continuous(name ="Age", 
                     breaks=c(8, 12, 16, 20, 24),
                     labels =c(8, 12, 16, 20, 24)) +
  theme(panel.grid = element_blank(),
        axis.line = element_line(size = .2),
        axis.text = element_text(size = 12),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 11),
        legend.position = "top",
        plot.title = element_text(hjust = 0.5, face = "bold")) +
  coord_cartesian(ylim = c(-1, 2))
mb_plot

#save group plot
ggsave(filename = glue("{output_folder}/mb_continuous_age.png"), plot = last_plot(), width = 4, height = 3, units = "in", dpi = 300)


################################################
#### 4. Second-stage RT regression ####
################################################
# run model
rt.model <- mixed(rt_2 ~ age_z * transition + (transition|subject_id), 
                  data = data, 
                  method = "S", 
                  expand_re = T)


################################################
#### 5. Plot RTs by age group ####
################################################

# Plot second-stage RTs (individual subs)
rt_stats <- data %>%
  group_by(transition, subject_id, age_group) %>%
  summarize(mean_rt = mean(rt_2, na.rm = T),
            sd_rt = sd(rt_2, na.rm = T),
            N = n(),
            se_rt = (sd_rt/sqrt(N))) %>%
  drop_na


rt_plot <- ggplot(rt_stats, aes(x = transition, y = mean_rt, fill = transition)) +
  geom_bar(position = "dodge", stat = "identity", color = "black") +
  geom_errorbar(aes(x = transition, ymin = mean_rt - se_rt, ymax = mean_rt + se_rt), width = 0) +
  xlab("Previous Transition Type") +
  ylab("Response Time (ms)") +
  facet_wrap(~subject_id) +
  coord_cartesian(ylim = c(200, 1100)) +
  scale_fill_manual(values = c("royalblue4", "firebrick2")) +
  theme_minimal() +
  theme(panel.grid = element_blank(),
        axis.line = element_line(size = .2))
rt_plot

# Plot second-stage RTs by age group 
rt_stats_group <- rt_stats %>%
  group_by(transition, age_group) %>%
  summarize(mean_rt_group = mean(mean_rt),
            N = n(),
            se_rt = sd(mean_rt)/sqrt(N))

rt_plot_group <- ggplot(rt_stats_group, aes(x = transition, y = mean_rt_group, fill = transition)) +
  geom_bar(position = "dodge", stat = "identity", color = "black") +
  geom_errorbar(aes(x = transition, ymin = mean_rt_group - se_rt, ymax = mean_rt_group + se_rt), width = 0) +
  xlab("Previous Transition Type") +
  ylab("Response Time (ms)") +
  facet_wrap(~age_group) +
  coord_cartesian(ylim = c(500, 1200)) +
  scale_fill_manual(values = c("royalblue4", "firebrick2")) +
  theme_minimal() +
  theme(panel.grid = element_blank(),
                panel.spacing.x = unit(1, "lines"),
                axis.line = element_line(size = .1),
                strip.text.x = element_text(size = 14),
                axis.title = element_text(size = 12),
                axis.text = element_text(size = 12),
                plot.title = element_text(size = 20, face = "bold"),
        legend.position = "none")
rt_plot_group

#save group rt plot
ggsave(filename = glue("{output_folder}/rt_plot_age_group.png"), plot = last_plot(), width = 5, height = 3, units = "in", dpi = 300)



################################################
#### 6. RT / MB Regression ####
################################################

## Compute each sub's RT difference
rt_diff <- rt_stats %>%
  select(transition, subject_id, mean_rt) %>%
  pivot_wider(id_cols = subject_id, names_from = transition, values_from = mean_rt) %>%
  mutate(diff = rare - common)

rt_diff$subject_id <- factor(rt_diff$subject_id)

#combine w/ mb estimates
mb_rt <- full_join(mb_age, rt_diff, by = "subject_id")
mb_rt <- addAgeGroup(mb_rt, age)

#run regression
mb_rt$age_z <- scale_this(mb_rt$age)
mb_rt$rt_diff_z <- scale_this(mb_rt$diff)

rt.mb.model <- lm(mb_effect ~ rt_diff_z * age_z, data = mb_rt)


################################################
#### 7. RT / MB Plot ####
################################################
rt_mb_plot <- ggplot(mb_rt, aes(x = diff, y = mb_effect)) +
  geom_point(stat = "identity") + 
  geom_smooth(method = "lm", color = "black") +
  facet_wrap(~age_group) +
  ylab("Reward x Transition Interaction Effect") +
  xlab("Response Time Difference (Rare - Common) (ms)") +
  coord_cartesian(ylim = c(-.5, 1.5), xlim = c(-200, 600)) +
  theme_minimal() + 
  theme(panel.grid = element_blank(),
        panel.spacing.x = unit(1, "lines"),
        axis.line = element_line(size = .1),
        strip.text.x = element_text(size = 14),
        axis.title = element_text(size = 12),
        axis.text = element_text(size = 9),
        plot.title = element_text(size = 20, face = "bold"))
rt_mb_plot

#save plot
ggsave(filename = glue("{output_folder}/rt_mb_plot.png"), plot = last_plot(), width = 5, height = 3, units = "in", dpi = 300)
