function [] = learnLWPRfuncAverage(data, testMass, init_D, maxIter, minIter, epsilon)
newFolder = append("init_D",string(init_D)); % folder to store the models for each mass in for this particular init kernel width

exps = fieldnames(data);
% Gather all relevant data for training in separate matrices for
% training and testing
Mtrain = [];
Mtest = [];
for i = 1:length(exps)
    EoB_z = data.(exps{i}).EoB_zmean;
    EoB_zd = data.(exps{i}).EoB_zdmean;
    time = ([0:length(EoB_z)-1]/360)';
    mass = data.(exps{i}).mass;
    f = data.(exps{i}).Afscuppckgmean;
    % Save the training and validation data in separate matrices.
    % (Un)comment lines below to choose the input space to learn in
    if mass == testMass
%         Mtest = [Mtest; EoB_z, EoB_zd*mass, time, f, mass*ones(length(time),1)]; % z, m zd, t
        Mtest = [Mtest; EoB_z*mass, EoB_zd*mass, time, f, mass*ones(length(time),1)]; % m z, m zd, t
%         Mtest = [Mtest; EoB_z, EoB_zd, time, mass*ones(length(time),1), f, mass*ones(length(time),1)]; % z, zd, t, m
    else
%         Mtrain = [Mtrain; EoB_z, EoB_zd*mass, time, f, mass*ones(length(time),1)]; % z, m zd, t
        Mtrain = [Mtrain; EoB_z*mass, EoB_zd*mass, time, f, mass*ones(length(time),1)]; % m z, m zd, t
%         Mtrain = [Mtrain; EoB_z, EoB_zd, time, mass*ones(length(time),1), f, mass*ones(length(time),1)]; % z, zd, t, m
    end
end

% Get the inputs and outputs from the relevant data and put in respective
% matrices
Xtrain = Mtrain(:,1:3);
% Xtrain = Mtrain(:,1:4);
Ytrain = Mtrain(:,4);
% Ytrain = Mtrain(:,5);

Xtest = Mtest(:,1:3);
% Xtest = Mtest(:,1:4);
Ytest = Mtest(:,4);
% Ytest = Mtest(:,5);

X = [Xtrain; Xtest]; % collect all data in one matrix to calculate the normalization factors
Y = [Ytrain; Ytest];
[~, inputdim] = size(X);
% Calculate normalization factors for model input
normalization = [max(X(:,1))-min(X(:,1)), max(X(:,2))-min(X(:,2)) max(X(:,3))-min(X(:,3))];
% normalization = [max(X(:,1))-min(X(:,1)), max(X(:,2))-min(X(:,2)), max(X(:,3))-min(X(:,3)) max(X(:,4))-min(X(:,4))];
% 

% Getting unique sorted list of masses
masses = [];
for i = 1:length(exps)
    masses = [masses, data.(exps{i}).mass];
end
masses = sort(unique(masses));

% Initializing the LWPR model
model = lwpr_init(inputdim,1,'name','lwpr_test');
model = lwpr_set(model, 'norm_in', normalization');
model = lwpr_set(model,'init_D',init_D);
model = lwpr_set(model, 'update_D', 1);
model = lwpr_set(model,'init_alpha',250);
model = lwpr_set(model,'w_gen',0.2);
model = lwpr_set(model,'diag_only',0);
model = lwpr_set(model,'meta',1);
model = lwpr_set(model,'meta_rate',250);
model = lwpr_set(model,'kernel','Gaussian');
model = lwpr_set(model, 'init_lambda', 1);

%%%%%%%%%%%%%%%%%%%%%%%%
%  Transfer model into mex-internal storage
model = lwpr_storage('Store',model);
%%%%%%%%%%%%%%%%%%%%%%%%

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
    %     fprintf(1,'#Data=%d #rfs=%d nMSE=%5.3f\n',lwpr_num_data(model),lwpr_num_rfs(model),nMSE);
    fprintf(append("Iteration ",string(j), ": nMSE training = ", string(round(nMSE,3)), ', nMSE test = ', string(round(nMSEtest,3)),'\n'))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Transfer model back from mex-internal storage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model = lwpr_storage('GetFree',model);

%% Save LWPR model

mkdir("LWPR models average", newFolder);
save(append("LWPR models average/init_D",string(init_D),"/LWPRmodel",string(find(masses == testMass)),".mat"),'model')
fprintf("Model saved.\n")
