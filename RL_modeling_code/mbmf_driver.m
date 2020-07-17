% Reinforcement learning model fitting driver for Model-Based Model-Free two-step
% task; Runs mbmf_lik.m
% Adapted and commented by Gail Rosenbaum in spring of 2018 
% Adapted again by Kate Nussenbaum in summer 2020

%Clear everything
clearvars

%% Change this stuff %%

% Data set to fit - change one to true
decker_data = false;
potter_data = true;
online_data = false;

%% Get data and name output
if decker_data == true
    files = dir('../data/decker/decker_mat_files/*.mat');
    outfile = '../output/decker_data/RL/decker_fits';
    outfile_txt = '../output/decker_data/RL/decker_fits.txt';
elseif potter_data == true
    files = dir('../data/potter/potter_mats/*.mat');
    outfile = '../output/potter_data/RL/potter_fits';
    outfile_txt = '../output/potter_data/RL/potter_fits.txt';
elseif online_data == true
    files = dir('../data/online/online_mat_files/*.mat');
    outfile = '../output/online_data/RL/online_fits';
    outfile_txt = '../output/online_data/RL/online_fits.txt';
end

%% Fit models
Nsubjects = length(files);
Fit.Nparms = 6; %defining the number of free parameters: alpha, beta_mb, beta_mf, beta, lambda, stickiness
Fit.LB = [1e-6 1e-6 1e-6 1e-6 1e-6 -30]; %lower bounds of each of the parameters
Fit.UB = [1 30 30 30 1 30]; %upper bounds of each of the parameters - the 30 is somewhat arbitrary 

sub_names = [];

%loop through subjects
for s = 1:length(files)
    
    %take the next file 
    filename = strcat(files(s).folder,'/',files(s).name);
    
    %load the relevant variables from the file: First-stage choice,
    %second-stage choice, outcome (whether or not they were rewarded),
    %state (what planet they were sent to) 
    load(filename,'choice1','choice2', 'money', 'state', 'name');
    
    if decker_data == true || potter_data == true
        name = ['000', name];
        sub_names = [sub_names; name(end-3:end)];
    else
        sub_names = [sub_names; name];
    end
      
    
%   Start model-fitting at choice 10 (this is what was done in Decker et
%   al. (2016) and Potter et al. (2017)
    choice1short = choice1(10:end);
    choice2short = choice2(10:end);    
    moneyshort = money(10:end);
    stateshort = state(10:end);
    
%   Remove trials where the participant didn't respond to either
%   the first or second stage choice
    
    noanswertrials = find(choice1short==0 | choice2short==0 |stateshort ==0);
    choice1short(noanswertrials) = [];
    choice2short(noanswertrials) = [];    
    moneyshort(noanswertrials) = [];
    stateshort(noanswertrials) = [];
    
    %define the prior choice, for the first choice we're coding (this is
    %necessary for stickiness)
    choice10 = choice1(9);
    
    %use choice 8 if they missed choice 9
    if choice10 == 0
        choice10 = choice1(8);
    end
    
    fprintf('Fitting subject %d out of %d...\n',s,Nsubjects)
    
    
    niter = 10; %Number of iterations per participant
    
    for iter = 1:niter  % run niter times from random initial conditions, to get best fit
        
        fprintf('Iteration %d...\n',iter)
        
        % choosing a random number between the lower and upper bounds
        % (defined above) to initialize each of the parameters
        Fit.init(s,iter,:) = rand(1,length(Fit.LB)).*(Fit.UB-Fit.LB)+Fit.LB; % random initialization
        
%        Run fmincon; a few notes:
% %         you only need to change the second line below; everything else
% %         is a recommended setting that you don't need to mess with
% %         second line of input below should be fmincon(@(x) [name of
% %         model fitting script, e.g. MBMF_RWFit_Commented](variables listed,
% %         x(1),x(2),x(3)... corresponding to the free parameters)
      [res,lik] = ...
       fmincon(@(x) mbmf_lik(choice1short,choice2short,moneyshort,stateshort,choice10,x(1),x(2),x(3),x(4),x(5),x(6)),...
       squeeze(Fit.init(s,iter,:)),[],[],[],[],Fit.LB,Fit.UB,[],...
       optimset('maxfunevals',10000,'maxiter',2000,'GradObj','off','DerivativeCheck','off','LargeScale','on','Algorithm','active-set'));
        % GradObj = 'on' to use gradients, 'off' to not use them *** ask us about this if you are interested ***
        % DerivativeCheck = 'on' to have fminsearch compute derivatives numerically and check the ones I supply
        % LargeScale = 'on' to use large scale methods, 'off' to use medium
        
%         this stores the results for each iteration in the structure named
%         Fit; change these to correspond to your parameters
        Fit.Result.Alpha(s,iter) = res(1);
        Fit.Result.Beta_MB(s, iter) = res(2);
        Fit.Result.Beta_MF(s, iter) = res(3);
        Fit.Result.Beta(s,iter) = res(4);
        Fit.Result.lambda(s,iter) = res(5);
        Fit.Result.stickiness(s,iter) = res(6);
        Fit.Result.Lik(s,iter) = lik;
        Fit.Result.Lik  % This doesn't have a semicolon so that the results are displayed in the command window so we can view progress so far
    end
    
%     finds the iteration with the best fit (the minimum logliklihood value) for the subject
%     and saves each of the parameter values from that iteration as
%     Fit.Result.BestFit
    [a, b] = min(Fit.Result.Lik(s, :));
    Fit.Result.BestFit(s,:) = [s,...
        Fit.Result.Alpha(s,b),...
        Fit.Result.Beta_MB(s,b),...
        Fit.Result.Beta_MF(s,b),...
        Fit.Result.Beta(s,b),...
        Fit.Result.lambda(s,b),...
        Fit.Result.stickiness(s,b),...
        Fit.Result.Lik(s,b)];
end


%save data (decker or potter data sets)
if decker_data == true || potter_data == true
    for i = 1:length(sub_names)
        sublist(i) = str2double(sub_names(i,:));
    end
    save(outfile, 'Fit', 'sublist');
    sublist = sublist';
    best_fits = [Fit.Result.BestFit, sublist];
    dlmwrite(outfile_txt, best_fits);
end


%save online data
if online_data == true 
    sublist = sub_names;
    save(outfile, 'Fit', 'sublist');
    best_fits = [Fit.Result.BestFit, sublist];
    fid = fopen(outfile_txt,'w');
    [rows, columns] = size(best_fits);
    for r = 1:rows
    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', best_fits{r, :});
    end
    fclose(fid)
end
