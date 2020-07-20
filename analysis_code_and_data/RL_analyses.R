## MBMF RL ANALYSIS ##
# Kate Nussenbaum - katenuss@nyu.edu
# Last updated: 7/17/20

# Examine how RL model parameters vary as a function of age # 

# This script analyzes mbmf RL data that has already been processed into a dataframe 
# by the script "mbmf_analyze_RL_all_datasets.R" 
# To run, it requires a dataframe (called 'model_fits') 
# and a 'folder_name' where model outputs and figures are saved. 

# It saves 6 linear regressions and plots that show the relation between
# age and each model parameter


# Run linear regression w/ age for all parameters
for (i in c(1:6)) {
  column = i+2
  y = model_fits[, column]
  x = model_fits[, "age_z"]
  df <- data.frame(x, y)
  par_name <- colnames(model_fits)[column]
  colnames(df) <- c("x", "y")
  model <- lm(y ~ x, data = df)
  write_delim(as.data.frame(round(summary(model)$coefficients, 4)), path = glue("{output_folder}/RL_model_{par_name}.txt" ))
}


#Make and save plots for all parameters
for (i in c(1:6)) {
  column = i+2
  y = model_fits[, column]
  x = model_fits[, "age"]
  df <- data.frame(x, y)
  par_name <- colnames(model_fits)[column]
  colnames(df) <- c("x", "y")
  
  #make plot
  ggplot(df, aes(x = x, y = y)) +
  geom_point() +
  geom_smooth(method = "lm", color = "black") +
  ylab(par_name) +
  xlab("Age") +
  theme_minimal()
  
  #save plot
  ggsave(filename = glue("{output_folder}/RL_plot_{par_name}.png"), plot = last_plot(), width = 4, height =3, units = "in", dpi = 300)
}

## Make table of parameter distributions
model_fits <- addAgeGroup(model_fits, age)

model_stats <- model_fits %>%
  group_by(age_group) %>%
  summarise(across(
    .cols = where(is.numeric), 
    .fns = list(mean = mean, sd = sd), na.rm = TRUE, 
    .names = "{col}_{fn}"
  ))

model_stats <- model_stats %>% 
  mutate_if(is.numeric, round, digits = 3)

write_delim(model_stats, glue("{output_folder}/RL_parameter_stats.txt"), delim = "\t")
