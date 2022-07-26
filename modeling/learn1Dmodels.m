% This script learns LWPR models, looping over the kernel width
% hyperparameters and validation masses. The learning process for each
% model stops when a criterion is met: the nMSE on the training data has
% not decreased by more than epsilon over the last 5 training iterations,
% and a minimum amount of iterations has been reached. Training also stops
% when a maximum amount of iterations is reached. The progress bar shows an
% estimate of remaining time untill completion.
close all; clear; clc;

%% Load data and format it to be readable for LWPR algorithm
load("meanAndStdData.mat")
data = expStats; % replace name for ease
clear struct1Dreduced
exps = fieldnames(data);

% Getting unique sorted list of masses
masses = [];
for i = 1:length(exps)
    masses = [masses, data.(exps{i}).mass];
end
masses = sort(unique(masses));

%% Train models
wb = waitbar(0,'Training..');
k = 0; % dummy to for waitbar

% init_Dvec = 650:-10:550; % initial kernel width/receptive field distance metric
init_Dvec = 600;
% Convergence criterion settings
maxIter = 100; % maximum amount of iterations
minIter = 5; % minimum amount of iterations
epsilon = 0.0001; % convergence criterion: if the NMSE does not decrease more than this ten times -> convergence

trainingBouts = length(masses)*length(init_Dvec); % amount of training bouts to be done
timeLefts = []; % vector to save the time that is left for estimation of the remaining time
for init_D = init_Dvec % initial kernel width hyperparameter loop
    for m = masses % validation/test mass loop
        tic
        % Update waitbar
        x = k/trainingBouts;
        waitbar(x,wb,append(string(round(x*100,1)), "%, estimated time left: ", string(round((trainingBouts - k)*mean(timeLefts)/60,1)), " minutes..."))
        
        % Train a model
        learnLWPRfunc(data, m, init_D, maxIter, minIter, epsilon) % models are saved within this function
        
        % Estimate time left
        timeElapsed = toc;
        k = k + 1;
        timeLefts = [timeLefts; timeElapsed]; % add to vector of time elapsed per model training
    end
end
close(wb)

