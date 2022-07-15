function [RMSE_AoB_z,RMSE_AoB_zd,RMSE_AoB_zdd,MAE_AoB_z,MAE_AoB_zd,MAE_AoB_zdd] = simulateAverageFunc(ix, coordinateFrame, plotBool)
addpath("functions\LWPR\")
load("meanAndStdData.mat")
fnStats = fieldnames(expStats);
g = 9.81;
foldercontents = dir("LWPR models average");
initHyperParGroupings = [];
for i = 3:length(foldercontents)
    initHyperParGroupings = [initHyperParGroupings; string(foldercontents(i).name)];
end
Nsigma = 3;
fontSize = 14;
% for i = 1:length(initHyperParGroupings) % looping over all hyperparameter settings to evaluate performance
% RMSE_AoB_z = []; % empty the mse vector of position
% RMSE_AoB_zd = []; % empty the mse vector of velocity
% RMSE_AoB_zdd = []; % empty the mse vector of acceleration
e_h = [];
e_hd = [];
e_hdd = [];
for testMass = 1:10
    %     load(append("LWPR models\LWPRmodel", string(testMass),".mat"))
    load(append("LWPR models average/",initHyperParGroupings(ix),"/LWPRmodel", string(testMass),".mat"))
    % Loading mean experimental data, so the initial condition will be the
    % average measured initial condition for this mass

    AoB_z_exp = expStats.(fnStats{testMass}).AoB_zmean;
    AoB_zd_exp = expStats.(fnStats{testMass}).AoB_zdmean;
    AoB_zdd_exp = expStats.(fnStats{testMass}).AoB_zddmean;

    AoB_z_exp_std = expStats.(fnStats{testMass}).AoB_zstd;
    AoB_zd_exp_std = expStats.(fnStats{testMass}).AoB_zdstd;
    AoB_zdd_exp_std = expStats.(fnStats{testMass}).AoB_zddstd;

    EoB_z_exp = expStats.(fnStats{testMass}).EoB_zmean;
    EoB_zd_exp = expStats.(fnStats{testMass}).EoB_zdmean;
    EoB_zdd_exp = expStats.(fnStats{testMass}).EoB_zddmean;

    EoB_z_exp_std = expStats.(fnStats{testMass}).EoB_zstd;
    EoB_zd_exp_std = expStats.(fnStats{testMass}).EoB_zdstd;
    EoB_zdd_exp_std = expStats.(fnStats{testMass}).EoB_zddstd;

    Afscup_pckg_exp = expStats.(fnStats{testMass}).Afscuppckgmean;

    Afscup_pckg_exp_std = expStats.(fnStats{testMass}).Afscuppckgstd;

    % Tool arm motion is loaded from the average data
    AoE_z_exp = expStats.(fnStats{testMass}).AoE_zmean;
    AoE_zd_exp = expStats.(fnStats{testMass}).AoE_zdmean;
    AoE_zdd_exp = expStats.(fnStats{testMass}).AoE_zddmean;
    

    time_exp = [0:length(AoE_z_exp)-1]*(1/360); % doesn't matter, time is always the same
    dt = time_exp(2);
    m = expStats.(fnStats{testMass}).mass;

    % load initial conditions
    AoB_z0 = AoB_z_exp(1);
    AoB_zd0 = AoB_zd_exp(1);

    % Preallocate
    AoB_z_sim = zeros(length(time_exp),1);
    AoB_zd_sim = zeros(length(time_exp),1);
    AoB_zdd_sim = zeros(length(time_exp),1);
    EoB_z_sim = zeros(length(time_exp),1);
    EoB_zd_sim = zeros(length(time_exp),1);
    Afscup_pckg_sim = zeros(length(time_exp),1);

    % Initialize
    AoB_z_sim(1) = AoB_z0;
    AoB_zd_sim(1) = AoB_zd0;

    % Simulate
    for ii = 1:length(time_exp)-1
        EoB_z_sim(ii) = AoB_z_sim(ii) - AoE_z_exp(ii);
        EoB_zd_sim(ii) = AoB_zd_sim(ii) - AoE_zd_exp(ii);
        zeta = [EoB_z_sim(ii)*m, EoB_zd_sim(ii)*m];
%         zeta = [EoB_z_sim(ii), EoB_zd_sim(ii)];
        t = time_exp(ii);
        
        Afscup_pckg_sim(ii) = lwpr_predict(model, [zeta,t]'); % predict the force
%         Afscup_pckg_sim(ii) = lwpr_predict(model, [zeta,t,m]'); % predict the force
        AoB_zdd_sim(ii) = 1/m*(-m*g + Afscup_pckg_sim(ii)) ; % determine acceleration
        AoB_zd_sim(ii+1) = AoB_zd_sim(ii) + AoB_zdd_sim(ii)*dt;
        %         AoB_z_sim(ii+1) = AoB_z_sim(ii) + AoB_zd_sim(ii)*dt;
        AoB_z_sim(ii+1) = AoB_z_sim(ii) + AoB_zd_sim(ii)*dt + 1/2*AoB_zdd_sim(ii)*dt*dt; %AS Feb 17, 2022
    end
%     AoB_zdd_sim(end) = -g; % Set last acceleration to only gravity as this element is not used in integration and the assumption is that only gravity acts now
    ii = length(time_exp);
    Afscup_pckg_sim(ii) = lwpr_predict(model, [zeta,t]'); % predict the force
%     Afscup_pckg_sim(ii) = lwpr_predict(model, [zeta,t,m]'); % predict the force
    AoB_zdd_sim(ii) = 1/m*(-m*g + Afscup_pckg_sim(ii)) ; % determine acceleration
    EoB_z_sim(end) = AoB_z_sim(end) - AoE_z_exp(end);
    EoB_zd_sim(end) = AoB_zd_sim(end) - AoE_zd_exp(end);
    EoB_zdd_sim = AoB_zdd_sim - AoE_zdd_exp;

    % Calculate MSE
%     RMSE_AoB_z = [RMSE_AoB_z; sqrt(mean((AoB_z_sim*1000 - AoB_z_exp*1000).^2))];
%     RMSE_AoB_zd = [RMSE_AoB_zd; sqrt(mean((AoB_zd_sim*1000 - AoB_zd_exp*1000).^2))];
%     RMSE_AoB_zdd = [RMSE_AoB_zdd; sqrt(mean((AoB_zdd_sim*1000 - AoB_zdd_exp*1000).^2))];
    if not(testMass == 1) && not(testMass == 10) % exclude first and last masses
        e_h = [e_h; (AoB_z_sim- AoB_z_exp)];
        e_hd = [e_hd; (AoB_zd_sim- AoB_zd_exp)];
        e_hdd = [e_hdd; (AoB_zdd_sim- AoB_zdd_exp)];
    end
    %         maxAbsError_AoB_z = [maxAbsError_AoB_z; max(abs(AoB_z_sim - AoB_z_exp))];\
    confidenceDisplayName = "3\sigma margin on experiments";
    if plotBool
        switch coordinateFrame
            case "absolute"
                execStr = append("f",string(m*1000),' = figure;');
                eval(execStr)
                subplot(3,1,1)
                plot(time_exp, AoB_z_exp*1000,'DisplayName',"Experiment mean")
                hold on
                plot(time_exp, AoB_z_sim*1000,'k',"DisplayName","Simulation",'LineWidth',1)
                plot(time_exp, (AoB_z_exp + Nsigma*AoB_z_exp_std)*1000, 'r--', "DisplayName",confidenceDisplayName)
                plot(time_exp, (AoB_z_exp - Nsigma*AoB_z_exp_std)*1000, 'r--', "HandleVisibility","off")
                grid on
%                 xlabel("Time (s)")
                ylabel("$(^Ao_B)_z$ (mm)","Interpreter","latex","FontSize",fontSize)
                title(append("Simulation versus experiment with mass of ",string(m), "kg. ", initHyperParGroupings{ix}))
                lgd = legend('Location', 'southwest','FontSize',fontSize*.7);
                title("")

                subplot(3,1,2)
                plot(time_exp, AoB_zd_exp)
                hold on
                plot(time_exp, AoB_zd_sim,'k','LineWidth',1)
                plot(time_exp, AoB_zd_exp + Nsigma*AoB_zd_exp_std, 'r--', "DisplayName",confidenceDisplayName)
                plot(time_exp, AoB_zd_exp - Nsigma*AoB_zd_exp_std, 'r--', "HandleVisibility","off")
                grid on
%                 xlabel("Time (s)")
                ylabel("$(^A\dot{o}_B)_z$ (m/s)","Interpreter","latex","FontSize",fontSize)

                subplot(3,1,3)
                plot(time_exp, AoB_zdd_exp)
                hold on
                plot(time_exp, AoB_zdd_sim,'k','LineWidth',1)
                plot(time_exp, AoB_zdd_exp + Nsigma*AoB_zdd_exp_std, 'r--', "DisplayName",confidenceDisplayName)
                plot(time_exp, AoB_zdd_exp - Nsigma*AoB_zdd_exp_std, 'r--', "HandleVisibility","off")
                grid on
                ylabel("$(^A\ddot{o}_B)_z$ (m/s \textsuperscript{2})","Interpreter","latex","FontSize",fontSize)
                xlabel("Time (s)", "Interpreter","latex",FontSize=fontSize)
                
                execStr = append("saveas(f",string(m*1000),", '",string(m*1000),"gram.eps', 'epsc')");
                eval(execStr)


            case "relative"
                figure
                subplot(3,1,1)
                plot(time_exp, EoB_z_exp*1000,'DisplayName',"Experiment mean")
                hold on
                plot(time_exp, EoB_z_sim*1000,'k',"DisplayName","Simulation",'LineWidth',1)
                plot(time_exp, (EoB_z_exp + Nsigma*EoB_z_exp_std)*1000, 'r--', "DisplayName",confidenceDisplayName)
                plot(time_exp, (EoB_z_exp - Nsigma*EoB_z_exp_std)*1000, 'r--', "HandleVisibility","off")
                grid on
%                 xlabel("Time (s)")
%                 ylabel("$(^Eo_B)_z$ (mm)","Interpreter","latex","FontSize",13)
                ylabel("$z$ (mm)","Interpreter","latex","FontSize",fontSize)
                title(append("Simulation versus experiment with mass of ",string(m), "kg. ", initHyperParGroupings{ix}))
                lgd = legend;
                lgd.Location = 'southwest';

                subplot(3,1,2)
                plot(time_exp, EoB_zd_exp)
                hold on
                plot(time_exp, EoB_zd_sim,'k','LineWidth',1)
                plot(time_exp, EoB_zd_exp + Nsigma*EoB_zd_exp_std, 'r--', "DisplayName",confidenceDisplayName)
                plot(time_exp, EoB_zd_exp - Nsigma*EoB_zd_exp_std, 'r--', "HandleVisibility","off")
                grid on
%                 xlabel("Time (s)")
%                 ylabel("$(^E\dot{o}_B)_z$ (m/s)","Interpreter","latex","FontSize",13)
                ylabel("$\dot{z}$ (m/s)","Interpreter","latex","FontSize",fontSize)

                subplot(3,1,3)
                plot(time_exp, EoB_zdd_exp)
                hold on
                plot(time_exp, EoB_zdd_sim,'k','LineWidth',1)
                plot(time_exp, EoB_zdd_exp + Nsigma*EoB_zdd_exp_std, 'r--', "DisplayName",confidenceDisplayName)
                plot(time_exp, EoB_zdd_exp - Nsigma*EoB_zdd_exp_std, 'r--', "HandleVisibility","off")
                grid on
%                 ylabel("$(^E\ddot{o}_B)_z$ (m/s\textsuperscript{2})","Interpreter","latex","FontSize",13)
                ylabel("$\ddot{z}$ (m/s \textsuperscript{2})","Interpreter","latex","FontSize",fontSize)
                xlabel("Time (s)")
        end

    end
end
% execStr = append("MSE_AoB_z_table.", initHyperParGroupings(i), " = MSE_AoB_z;");
% eval(execStr)
% execStr = append("MSE_AoB_zd_table.", initHyperParGroupings(i), " = MSE_AoB_zd;");
% eval(execStr)
% execStr = append("MSE_AoB_zdd_table.", initHyperParGroupings(i), " = MSE_AoB_zdd;");
% eval(execStr)
% end

% Calculate root-mean-square error
RMSE_AoB_z = sqrt(mean(e_h.^2));
RMSE_AoB_zd = sqrt(mean(e_hd.^2));
RMSE_AoB_zdd = sqrt(mean(e_hdd.^2));

% Cacluate max absolute error
MAE_AoB_z= max(abs(e_h));
MAE_AoB_zd= max(abs(e_hd));
MAE_AoB_zdd= max(abs(e_hdd));

end