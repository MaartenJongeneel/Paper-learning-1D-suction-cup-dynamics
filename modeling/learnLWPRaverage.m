% This script learns LWPR models, looping over the kernel width
% hyperparameters and validation masses. The learning process for each
% model stops when a criterion is met: the nMSE on the training data has
% not decreased by more than epsilon over the last 5 training iterations,
% and a minimum amount of iterations has been reached. Training also stops
% when a maximum amount of iterations is reached. The progress bar shows an
% estimate of remaining time untill completion. This estimate is the mean 
% learning time per model times amount of models still to be learned.
% This estimate may be way off, and to prevent the estimated time from
% increasing while learning, it is advised to arrange the init_Dvec from 
% large to small (large values correspond to small kernel width).

close all; clear; clc;

% Add paths in order to access functions
addpath("functions\")
addpath("functions\LWPR\")

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

% Set training parameters
% init_Dvec = 1000:-100:200; % initial kernel width/receptive field distance metric
% init_Dvec = 100:-10:20;
init_Dvec = 1000;
maxIter = 100; % maximum amount of iterations
minIter = 5; % minimum amount of iterations
epsilon = 0.0001; % convergence criterion

trainingBouts = length(masses)*length(init_Dvec); % amount of training bouts to be done
timeLefts = []; % vector to save the time that is left for estimation of the remaining time
for init_D = init_Dvec % initial kernel width hyperparameter loop
    for m = masses % validation/test mass loop
        tic
        % Update waitbar
        x = k/trainingBouts;
        waitbar(x,wb,append(string(round(x*100,1)), "%, estimated time left: ", string(round((trainingBouts - k)*mean(timeLefts)/60,1)), " minutes..."))
        
        % Train a model
        learnLWPRfuncAverage(data, m, init_D, maxIter, minIter, epsilon) % models are saved within this function
        
        % Estimate time left
        timeElapsed = toc;
        k = k + 1;
        timeLefts = [timeLefts; timeElapsed]; % add to vector of time elapsed per model training
    end
end
close(wb)

%% Remove paths to avoid cluttering the matlab paths
rmpath("functions\")
rmpath("functions\LWPR\")