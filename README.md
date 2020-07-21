# Moving developmental research online: comparing in-lab and web-based studies of model-based reinforcement learning
Tasks, data, and analysis scripts for [Nussenbaum, K., Scheuplein, M., Phaneuf, C., Evans, M.D., & Hartley, C.A. (_submitted_). 
Moving developmental research online: comparing in-lab and web-based studies of model-based reinforcement learning.](https://osf.io/vewyq/)

We collected data from 151 participants on two tasks: the two-step task, as described in Decker et al. (2016)
and the Matrix Reasoning Item Bank (MaRs-IB) as described in Chierchia, Fuhrmann et al. (2019). 

## Tasks
Versions of both tasks, coded in [jsPsych](https://www.jspsych.org/), can be found in the "tasks" folder.
_Please note: the tasks were designed to be hosted on [Pavlovia](https://pavlovia.org/). As such, they will not run locally unless the Pavlovia-specific code is commented out._ 

### 1. Developmental two-step task
This sequential decision-making task was originally described in [Decker et al. (2016)](https://journals.sagepub.com/doi/full/10.1177/0956797616639301?url_ver=Z39.88-2003&rfr_id=ori:rid:crossref.org&rfr_dat=cr_pub%20%200pubmed), and is based off of an adult task originally described in [Daw et al. (2011)](https://www.cell.com/neuron/fulltext/S0896-6273(11)00125-5?_returnURL=https%3A%2F%2Flinkinghub.elsevier.com%2Fretrieve%2Fpii%2FS0896627311001255%3Fshowall%3Dtrue).
Participants make a series of sequential decisions to try to gain as much reward as possible. In this version, on each trial, participants first must select a spaceship, which then transports them to one of two planets where they can ask an alien for space treasure.

The jsPsych version of the task was originally coded by the [Niv Lab](https://nivlab.princeton.edu/) at Princeton, and adapted by the [Hartley Lab](https://www.hartleylab.org/) at NYU for use online with children, adolescents, and adults.

### 2. Matrix Reasoning Item Bank (MaRs-IB)
This abstract reasoning task was developed by and originally described in [Chierchia, Furhmann et al. (2019)](https://royalsocietypublishing.org/doi/10.1098/rsos.190232). All stimuli used in the task are from the [OSF repository](https://osf.io/g96f4/) set up by the original study authors.
Participants complete a series of reasoning puzzles within an 8-minute time limit.
The jsPsych version of the task uses one of the color-blind friendly stimulus sets as well as the "minimal" distractors described in the original manuscript. It was coded by the Hartley Lab for use online with children, adolescents, and adults.


## Data and analysis code
All raw data and analysis code can be found in the "analysis_code_and_data" folder. All analyses and results reported in the manuscript can be reproduced by running the R scripts (for all data summary statistics and regression analyses) and matlab code (for the computational modeling of the two-step task data). 

The output folder contains all model results and generated figures. 

For questions, please contact katenuss@nyu.edu.
