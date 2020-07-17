%% Construct mat files from .txt files for online data set

%read in data file
opts = detectImportOptions('../online_mat_files/online_data_for_matlab.txt');
opts = setvartype(opts, 'subject_id', 'string'); 
data = readtable('../online_mat_files/online_data_for_matlab.txt', opts);

%get all subject ids
subs = unique(data.subject_id);

% split up table based on sub
for subject = 1:length(subs)
    
    %get subject data
    sub_data = data(data.subject_id == subs(subject),:);
    
    %create structure w/ 
    choice1 = sub_data.choice_1;
    choice2 = sub_data.choice_2;
    money = sub_data.reward;
    state = sub_data.state;
    name = subs(subject);
    
    %save as mat file
    mat_name = strcat('../online_mat_files/', name, '_onsets.mat');
    
    save(mat_name, 'choice1', 'choice2', 'money', 'state', 'name');
end
    




