close all; clear; clc;

foldercontents = dir("LWPR models");
initHyperParGroupings = [];
for i = 3:length(foldercontents)
    initHyperParGroupings = [initHyperParGroupings; string(foldercontents(i).name)];
end

for i = 1:length(initHyperParGroupings) % looping over all init_D
    simulations{i} = simulateFunc(initHyperParGroupings{i}, false);
end

%% plot error vs init_D
for i = 1:length(initHyperParGroupings)
    simulation = simulations{i};
    init_Dvec(i) = simulation.init_D;
    simulation = rmfield(simulation,"init_D");
    fn = fieldnames(simulation);
    e_h = []; e_dh = []; e_ddh = [];
    for j = 1:length(fn)
        if not(endsWith(fn{j}, "160") || endsWith(fn{j}, "2187"))
            e_h = [e_h, simulation.(fn{j}).errors.RMSE_h];
            e_dh = [e_dh, simulation.(fn{j}).errors.RMSE_dh];
            e_ddh = [e_ddh, simulation.(fn{j}).errors.RMSE_ddh];
        end
    end
    
    RMSE_h(i) = mean(e_h);
    RMSE_dh(i) = mean(e_dh);
    RMSE_ddh(i) = mean(e_ddh);

end

figure(100)
subplot(3,1,1)
plot(init_Dvec, RMSE_h*1000,'*')
ylabel("RMSE $h$ (mm)", Interpreter="latex")
grid on
title("Averaged RMSE (excluding edge cases)")

subplot(3,1,2)
plot(init_Dvec, RMSE_dh,'*')
ylabel("RMSE $\dot{h}$ (m/s)", Interpreter="latex")
grid on

subplot(3,1,3)
plot(init_Dvec, RMSE_ddh,'*')
ylabel("RMSE $\ddot{h}$ (m\textsuperscript{2}/s)", Interpreter="latex")
xlabel("init_D")
grid on

% fig = gcf;
%         fig.PaperPositionMode = 'auto';
%         fig_pos = fig.PaperPosition;
%         fig.PaperSize = [fig_pos(3) fig_pos(4)];
%         print(fig,'figures/ModelErrors.pdf','-dpdf','-painters')

%% Plot simulation results of best init_D
simulateFunc("init_D600", true);