close all; clear; clc;
% addpath("functions\LWPR\")
load("1DdataReduced.mat") % load the 1D data
data = struct1Dreduced;
clear struct1Dreduced
exps = fieldnames(data);

load("meanAndStdData.mat")
fnStats = fieldnames(expStats);

% Getting unique sorted list of masses
masses = [];
for i = 1:length(exps)
    masses = [masses, data.(exps{i}).mass];
end
masses = sort(unique(masses));

Nsigma = 3; % the # of std the confidence interval is plotted at

%%
g = 9.81;
MSE_EoB_z_table = table;
MSE_EoB_zd_table = table;
MSE_EoB_zdd_table = table;

MAE_EoB_z_table = table;
MAE_EoB_zd_table = table;
MAE_EoB_zdd_table = table;




foldercontents = dir("LWPR models average");
initHyperParGroupings = [];
for i = 3:length(foldercontents)
    initHyperParGroupings = [initHyperParGroupings; string(foldercontents(i).name)];
end




%%
RMSE_AoB_zvec = zeros(length(initHyperParGroupings),1);
RMSE_AoB_zdvec = zeros(length(initHyperParGroupings),1);
RMSE_AoB_zddvec = zeros(length(initHyperParGroupings),1);

MAE_AoB_zvec = zeros(length(initHyperParGroupings),1);
MAE_AoB_zdvec = zeros(length(initHyperParGroupings),1);
MAE_AoB_zddvec = zeros(length(initHyperParGroupings),1);
% simulateAverageFunc(11, 'absolute', true);

% for i = 1:length(initHyperParGroupings) % looping over all hyperparameter settings to evaluate performance
%     [RMSE_AoB_z,RMSE_AoB_zd,RMSE_AoB_zdd,MAE_AoB_z,MAE_AoB_zd,MAE_AoB_zdd] = simulateAverageFunc(i, 'absolute', false);
%     RMSE_AoB_zvec(i) = RMSE_AoB_z;
%     RMSE_AoB_zdvec(i) = RMSE_AoB_zd;
%     RMSE_AoB_zddvec(i) = RMSE_AoB_zdd;
% 
%     MAE_AoB_zvec(i) = MAE_AoB_z;
%     MAE_AoB_zdvec(i) = MAE_AoB_zd;
%     MAE_AoB_zddvec(i) = MAE_AoB_zdd;
% end


%% Plot the initial kernel width against MSE and MAE
init_Dvec = zeros(length(initHyperParGroupings),1);
% for i = 1:length(initHyperParGroupings)
%     temp = char(initHyperParGroupings(i));
%     init_Dvec(i) = str2double(temp(7:end));
% end
% 
% figure(100)
% subplot(2,3,1)
% plot(init_Dvec, RMSE_AoB_zvec,'x')
% grid on
% hold on
% xlabel("init\_D")
% ylabel("RMSE\_z")
% 
% subplot(2,3,4)
% plot(init_Dvec, MAE_AoB_zvec,'x')
% grid
% xlabel("init\_D")
% ylabel("MAE\_z")
% 
% 
% 
% subplot(2,3,2)
% plot(init_Dvec, RMSE_AoB_zdvec,'x')
% grid
% hold on
% xlabel("init\_D")
% ylabel("RMSE\_zd")
% 
% subplot(2,3,5)
% plot(init_Dvec, MAE_AoB_zdvec,'x')
% grid
% xlabel("init\_D")
% ylabel("MAE\_zd")
% 
% 
% subplot(2,3,3)
% plot(init_Dvec, RMSE_AoB_zddvec,'x')
% grid
% hold on
% xlabel("init\_D")
% ylabel("RMSE\_zdd")
% 
% subplot(2,3,6)
% plot(init_Dvec, MAE_AoB_zddvec,'x')
% grid
% xlabel("init\_D")
% ylabel("MAE\_zdd")
% 
% %%
% figure(200)
% plot(init_Dvec, RMSE_AoB_zddvec,'x')
% % plot(init_Dvec, RMSE_AoB_zvec*1000,'x')
% grid on
% xlabel("init\_D")
% ylabel("RMSE $\ddot{z}$ (m/s\textsuperscript{2})","Interpreter","latex","FontSize",12)
% saveas(figure(200), "init_D.eps", "epsc")
%%
% close all
% simulateAverageFunc(find(MAE_accinit == min(MAE_accinit)), 'relative', true)
[RMSE_AoB_z,RMSE_AoB_zd,RMSE_AoB_zdd,MAE_AoB_z,MAE_AoB_zd,MAE_AoB_zdd] = ...
    simulateAverageFunc(find(init_Dvec== 300), 'absolute', true)
% [RMSE_AoB_z,RMSE_AoB_zd,RMSE_AoB_zdd,MAE_AoB_z,MAE_AoB_zd,MAE_AoB_zdd] = simulateAverageFunc(find(MAE_accinit == min(MAE_accinit)), 'absolute', true)
%% Save simulation figures
for i = 1:length(masses)
    mass = masses(i)*1000;
%     saveas(figure(i), append("mass", string(i), ".pdf"))
    gcf = figure(i);
    set(gcf,'Units','inches');
    screenposition = get(gcf,'Position');
    set(gcf,...
        'PaperPosition',[0 0 screenposition(3)-.7 screenposition(4)],...
        'PaperSize',[screenposition(3:4)]-[1 .15]);
%     print -dpdf -painters epsFig
    print(gcf, '-dpdf', append(string(mass),"grams.pdf"))
end

% rmpath("functions\LWPR\")