%% KN 6/29/20
%% Gail Rosenbaum, Spring 2018, modified from 
%% HR 7.17.17 modified RWFit.m from

%https://github.com/krm58/Reinforcement-Learning-Models/tree/master/CreditAssignment

function [lik] = mbmf_lik(choice1short,choice2short,moneyshort,stateshort,choice10,alpha,beta_mb,beta_mf,beta,lambda,stickiness) %inputs from raw data: choice @ stage 1, choice @ stage 2, reward (money), state (to tell if the transition is common or rare)

% initialize log likelihood at 0
lik = 0;   
% initialize q values; 3 states, 2 options per state
Qd = zeros(3,2); 
%transition matrix
Tm = [.7,.3;.3,.7];

%looping through each trial
for i = 1:length(choice1short)
 
    %the matrix priorchoice stores the first stage prior
    %choice; first we set it to [0,0]; it becomes [1,0] if the prior
    %first-stage choice was 1 and [0,1] if the prior choice was 2
     priorchoice = [0,0];
     if (i==1)
        %for the first trial, we need to use the choice from trial 9, which
        %we defined in the driver and passed through the function as an
        %input variable
         priorchoice(choice10) = 1;
     else
         %for all other trials, we can take the prior choice from
         %choice1short
         priorchoice(choice1short(i-1)) = 1;
     end 
   
    %in model-based Q computation, we assume that the participant is making
    %a choice between the first-stage states based on likelihood of
    %transitioning from the first stage to each given second stage state
    %and the maximum reward value that might be obtained at those second
    %states. 
    MaxQ = max(Qd,[],2); %take the maximum Q value of each row in Q (but this includes state 1, and we don't need that for MF computation)
    MaxQS2 = MaxQ(2:end); %maximum Q-value in the second stage only (for multiplication)
    
%     compute model-based and model-free Q values
    Qmb = [sum(MaxQS2.*Tm(:,1)),sum(MaxQS2.*Tm(:,2))]; %Maximum Q value for second stage states multiplied by likelihood of transition to each of those states
    Qmf = Qd(1,:);

%   Softmax function - based on computed Q values, how likely was their
%   first-stage choice?

    numerator = exp(beta_mf*(Qmf(1,choice1short(i))) + beta_mb*(Qmb(1,choice1short(i))) + stickiness*priorchoice(choice1short(i)));
    denominator = sum(exp(beta_mf*(Qmf(1,:))+ beta_mb*(Qmb(1,:)) + (stickiness*priorchoice)));
    lik_choice1 = numerator/denominator; %probability of the choice they made for stage 1 based on their computed Q values
 
    
    %updating loglikelihood based on choice 1
    lik = lik + log(lik_choice1);
    
    
    %softmax Choice 2 - based on computed Q values, how likely was their
%     second-stage choice?

    numerator = exp(beta*(Qd(stateshort(i),choice2short(i))));
    denominator = sum(exp(beta*(Qd(stateshort(i),:)))); 
    lik_choice2 = numerator/denominator;
    
    %updating loglikelihood of choice 2
    lik = lik + log(lik_choice2);
     
    
    %Compute Reward Prediction Error (RPE)
    %for MF learning
    
    %Store RPEs in a 1x2 matrix
    tdQ = [0,0]; 
    
    % State prediction error: Difference between the Q value from the first stage choice and the updated Q of the ultimate second stage choice
    tdQ(1) = Qd(stateshort(i), choice2short(i)) - Qd(1,choice1short(i)); 
 
    %RPE - reward - second-stage value estimate
    tdQ(2) = moneyshort(i) - Qd(stateshort(i),choice2short(i)); 
    
    % MF update - update first-stage choice values based on state prediction error and discounted RPE
    Qd(1,choice1short(i)) = Qd(1,choice1short(i)) + alpha * tdQ(1) + lambda * alpha * tdQ(2); 
    
    % MB update - directly to the Q value of the stage 2 stimulus
    Qd(stateshort(i),choice2short(i)) = Qd(stateshort(i),choice2short(i)) + alpha * tdQ(2); 

%     uncomment this if you want to store the q values for each trial;
%     helpful for debugging, or finding the trial-by-trial RPEs once you've
%     already run fmincon
%     QStore(:,:,i) = Qd;

    
    
end

% Put priors on parameters

 lik= lik+log(pdf('beta',alpha,1.1,1.1));
 lik= lik+log(pdf('gam',beta,3,1));
 lik= lik+log(pdf('gam',beta_mb,3,1));
 lik= lik+log(pdf('gam',beta_mf,3,1));
 lik= lik+log(pdf('beta',lambda,1.1,1.1));
 lik= lik+log(pdf('Normal',stickiness,0,10));

% 


%flip sign of loglikelihood (which is negative, and we want it to be as close to 0 as possible) so we can enter it into fmincon, which searches for minimum, rather than maximum values 

lik = -lik;  

