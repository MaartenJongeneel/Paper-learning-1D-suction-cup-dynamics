function [] = learnLWPRfunc(data, testMass, init_D, maxIter, minIter, epsilon)
newFolder = append("init_D",string(init_D)); % folder to store the models for each mass in for this particular init kernel width


exps = fieldnames(data);
% Gather all relevant data for training in separate matrices for
% training and testing
Mtrain = [];
Mtest = [];
for i = 1:length(exps)
    z = data.(exps{i}).z_avg';
    dz = data.(exps{i}).dz_avg';
    time = ([0:length(z)-1]/360)';
    mass = data.(exps{i}).mass;
    f = data.(exps{i}).f_scuppckg';
    % Save the training and validation data in separate matrices.
    if mass == testMass
        Mtest = [Mtest; z*mass, dz*mass, time, f, mass*ones(length(time),1)]; % m z, m zd, t
%         Mtest = [Mtest; z, dz*mass, time, f, mass*ones(length(time),1)]; % z, m zd, t
    else
        Mtrain = [Mtrain; z*mass, dz*mass, time, f, mass*ones(length(time),1)]; % m z, m zd, t
%         Mtrain = [Mtrain; z, dz*mass, time, f, mass*ones(length(time),1)]; % z, m zd, t
    end
end

% Get the inputs and outputs from the relevant data and put in respective
% matrices
Xtrain = Mtrain(:,1:3);
Ytrain = Mtrain(:,4);

Xtest = Mtest(:,1:3);
Ytest = Mtest(:,4);

X = [Xtrain; Xtest]; % collect all data in one matrix to calculate the normalization factors
Y = [Ytrain; Ytest];
[~, inputdim] = size(X);

% Calculate normalization factors for model input
normalization = [max(X(:,1))-min(X(:,1)), max(X(:,2))-min(X(:,2)) max(X(:,3))-min(X(:,3))];

% Getting unique sorted list of masses
masses = [];
for i = 1:length(exps)
    masses = [masses, data.(exps{i}).mass];
end
masses = sort(unique(masses));
modelname = append("initD",string(init_D),"testmass",string(testMass));

% Initializing the LWPR model
model = lwpr_init(inputdim,1,'name',modelname);
LWPRsettings; % script to choose model parameters

%  Transfer model into mex-internal storage
model = lwpr_storage('Store',model);

% Train LWPR model
n = length(Ytrain); % amount of samples in training set
nMSEprevious = Inf; % initialize previous nMSE
stoppingCriterionCount = 0;
for j = 1:maxIter % loop maximal maxIter amount of times
    inds = randperm(n); % random permutation of indices as to present data in random order to model
    MSE = 0; % initialize mean squared error

    for i=1:n
        [model,yp,~] = lwpr_update(model,Xtrain(inds(i),:)',Ytrain(inds(i),:)'); % Train model on data
        MSE = MSE + (Ytrain(inds(i),:)-yp).^2; % update MSE
    end
    nMSE = MSE/n/var(Y,1); % normalize MSE

    nMSEdelta = nMSE - nMSEprevious; % calculate decrease in nMSE
    nMSEprevious = nMSE; % update previous nMSE with new value

    if nMSEdelta > -epsilon % if the nMSE decreases less than the criterion epsilon, plus one on the criterion count
        stoppingCriterionCount = stoppingCriterionCount + 1;
    end

    if stoppingCriterionCount >= 10 && j > minIter % stop learning if the criterion count is reached and at minimum of iterations
        fprintf("Convergence criterion reached. Saving model..\n")
        break
    end
    % Calculate nMSE on validation/test
    MSEtest = 0;

    for i = 1:length(Ytest)
        Yp = lwpr_predict(model, Xtest(i,:)');
        MSEtest = MSEtest + (Yp-Ytest(i)).^2;
        
    end
    nMSEtest = MSEtest/length(Ytest)/var(Y,1); % normalize MSEtest
    fprintf(append("Iteration ",string(j), ": nMSE training = ", string(round(nMSE,3)), ', nMSE test = ', string(round(nMSEtest,3)),'\n'))
end

%  Transfer model back from mex-internal storage
model = lwpr_storage('GetFree',model);

%% Save LWPR model
mkdir("LWPR models", newFolder);
save(append("LWPR models/init_D",string(init_D),"/LWPRmodel",string(find(masses == testMass)),".mat"),'model')
fprintf("Model saved.\n")
