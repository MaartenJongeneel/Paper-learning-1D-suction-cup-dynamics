close all; clear; clc;
addpath('functions'); addpath('modeling'); addpath('data'); 
% This script loads the 1D archive HDF5 file, finds t_0, performs
% Savitzky-Golay on the 3D motion, and consequently extracts the vertical
% motion and saves them to the .mat file data1D.mat. Run this script from
% main directory.

%% Some settings
Nsigma = 3;
plotting = false;

%% Constants
g = 9.81;

%% Read .h5 file if the .mat version is not available
if not(isfile("data/1D Archive.mat")) % this generally takes a few minutes
    tic
    fprintf("Loading .h5 file... \n")
    struct1D = readH5("data/1D Archive.h5");
    dt = toc;
    fprintf(append("Reading .h5 file took ", string(dt), " seconds.\n"))
    fprintf("Saving data in .mat file... \n")
    save("data/1D Archive.mat", "struct1D",'-v7.3') % save .h5 data to mat for faster loading in future
    fprintf("Saved data to .mat file.\n")
else % if 1D Archive.mat is available, load that instead as its faster
    tic
    fprintf("Loading .mat file with data... \n")
    load("data/1D Archive.mat")
    fprintf("Loaded data from 1D Archive.mat file.\n")
    dt = toc;
    fprintf(append("Loading 1D Archive.mat took ", string(dt), " seconds.\n"))
end

%% Process data: Savitzky-Golay and cutting to obtain relevant data
close all
% Savitzky-Golay parameters
p_linear = 3;
n_linear = 9;
processedData = processData(struct1D, p_linear, n_linear, 0.14);
save("data\processedData.mat", "processedData") % save processed data of individual experiments

%% Average data
exps = fieldnames(processedData);
Nexps = length(exps);
masses = [];
for i = 1:Nexps
    masses = [masses, processedData.(exps{i}).mass];
end
masses = sort(unique(masses));

for m = masses
    h_mat = [];
    dh_mat = [];
    ddh_mat = [];

    a_mat = [];
    da_mat = [];
    dda_mat = [];

    for i = 1:Nexps
        exp = processedData.(exps{i});
        if exp.mass == m
            h_curr = exp.h;
            dh_curr = exp.dh;
            ddh_curr = exp.ddh;

            h_mat = [h_mat; h_curr];
            dh_mat = [dh_mat; dh_curr];
            ddh_mat = [ddh_mat; ddh_curr];

            a_curr = exp.a;
            da_curr = exp.da;
            dda_curr = exp.dda;

            a_mat = [a_mat; a_curr];
            da_mat = [da_mat; da_curr];
            dda_mat = [dda_mat; dda_curr];
            
        end
    end
    h_avg(masses==m,:) = mean(h_mat, 1);
    h_std(masses==m,:) = std(h_mat, 1);

    dh_avg(masses==m,:) = mean(dh_mat, 1);
    dh_std(masses==m,:) = std(dh_mat, 1);

    ddh_avg(masses==m,:) = mean(ddh_mat, 1);
    ddh_std(masses==m,:) = std(ddh_mat, 1);

    a_avg(masses==m,:) = mean(a_mat, 1);
    a_std(masses==m,:) = std(a_mat, 1);

    da_avg(masses==m,:) = mean(da_mat, 1);
    da_std(masses==m,:) = std(da_mat, 1);

    dda_avg(masses==m,:) = mean(dda_mat, 1);
    dda_std(masses==m,:) = std(dda_mat, 1);

    z_avg(masses==m,:) = a_avg(masses==m,:) - h_avg(masses==m,:);
    dz_avg(masses==m,:) = da_avg(masses==m,:) - dh_avg(masses==m,:);
    ddz_avg(masses==m,:) = dda_avg(masses==m,:) - ddh_avg(masses==m,:);

    f_scuppckg = m*ddh_avg(masses==m,:) + m*g;

    % Save trajectory statistics
    expStats.(append("mass",string(m*1000))).h_avg = h_avg(masses==m,:);
    expStats.(append("mass",string(m*1000))).dh_avg = dh_avg(masses==m,:);
    expStats.(append("mass",string(m*1000))).ddh_avg = ddh_avg(masses==m,:);

    expStats.(append("mass",string(m*1000))).h_std = h_std(masses==m,:);
    expStats.(append("mass",string(m*1000))).dh_std = dh_std(masses==m,:);
    expStats.(append("mass",string(m*1000))).ddh_std = ddh_std(masses==m,:);

    expStats.(append("mass",string(m*1000))).a_avg = a_avg(masses==m,:);
    expStats.(append("mass",string(m*1000))).da_avg = da_avg(masses==m,:);
    expStats.(append("mass",string(m*1000))).dda_avg = dda_avg(masses==m,:);
    
    expStats.(append("mass",string(m*1000))).a_std = h_std(masses==m,:);
    expStats.(append("mass",string(m*1000))).da_std = dh_std(masses==m,:);
    expStats.(append("mass",string(m*1000))).dda_std = ddh_std(masses==m,:);

    expStats.(append("mass",string(m*1000))).z_avg = z_avg(masses==m,:);
    expStats.(append("mass",string(m*1000))).dz_avg = dz_avg(masses==m,:);
    expStats.(append("mass",string(m*1000))).ddz_avg = ddz_avg(masses==m,:);
    
    expStats.(append("mass",string(m*1000))).mass = m;
    expStats.(append("mass",string(m*1000))).time = exp.time;
    
    expStats.(append("mass",string(m*1000))).f_scuppckg = f_scuppckg;

    if plotting %plotting if desired
        figure(find(masses == m))
        subplot(3,1,1)
        plot(exp.time, h_avg(masses==m,:),'k')
        hold on
        plot(exp.time, h_avg(masses==m,:) + Nsigma*h_std(masses==m,:),'r')
        plot(exp.time, h_avg(masses==m,:) - Nsigma*h_std(masses==m,:),'r')
        grid on
    
        subplot(3,1,2)
        plot(exp.time, dh_avg(masses==m,:),'k')
        hold on
        plot(exp.time, dh_avg(masses == m,:) + Nsigma*dh_std(masses==m,:), 'r')
        plot(exp.time, dh_avg(masses == m,:) - Nsigma*dh_std(masses==m,:), 'r')
        grid on
    
        subplot(3,1,3)
        plot(exp.time, ddh_avg(masses==m,:),'k')
        hold on
        plot(exp.time, ddh_avg(masses==m,:) + Nsigma*ddh_std(masses==m,:),'r')
        plot(exp.time, ddh_avg(masses==m,:) - Nsigma*ddh_std(masses==m,:),'r')
        grid on
    end
end

save("data\meanAndStdData.mat","expStats") % save experiment mean and stds
fprintf("Saved experiment statistics to 'meanAndStdData.mat'.\n")

