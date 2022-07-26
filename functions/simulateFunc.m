function [] = simulateFunc(initHyperParGrouping, plotBool)
load("meanAndStdData.mat")
fnStats = fieldnames(expStats);
g = 9.81;
foldercontents = dir("LWPR models");
initHyperParGroupings = [];
for i = 3:length(foldercontents)
    initHyperParGroupings = [initHyperParGroupings; string(foldercontents(i).name)];
end
Nsigma = 3;
fontSize = 14;

e_h = [];
e_hd = [];
e_hdd = [];

for testMass = 1:10
    load(append("LWPR models/",initHyperParGrouping,"/LWPRmodel", string(testMass),".mat"))
    % Loading averaged experimental data
    h_exp = expStats.(fnStats{testMass}).h_avg;
    dh_exp = expStats.(fnStats{testMass}).dh_avg;
    ddh_exp = expStats.(fnStats{testMass}).ddh_avg;

    h_exp_std = expStats.(fnStats{testMass}).h_std;
    dh_exp_std = expStats.(fnStats{testMass}).dh_std;
    ddh_exp_std = expStats.(fnStats{testMass}).ddh_std;

    % Tool arm motion is loaded from the average data
    a_exp = expStats.(fnStats{testMass}).a_avg;
    da_exp = expStats.(fnStats{testMass}).da_avg;
    dda_exp = expStats.(fnStats{testMass}).dda_avg;

    time_exp = [0:length(a_exp)-1]*(1/360); % doesn't matter, time is always the same
    dt = time_exp(2);
    m = expStats.(fnStats{testMass}).mass;

    % load initial conditions
    h_0 = h_exp(1);
    dh_0 = dh_exp(1);

    % Preallocate
    h_sim = zeros(length(time_exp),1);
    dh_sim = zeros(length(time_exp),1);
    ddh_sim = zeros(length(time_exp),1);
    z_sim = zeros(length(time_exp),1);
    dz_sim = zeros(length(time_exp),1);
    f_scuppcg_sim = zeros(length(time_exp),1);

    % Initialize
    h_sim(1) = h_0;
    dh_sim(1) = dh_0;

    % Simulate
    for ii = 1:length(time_exp)-1
        z_sim(ii) = a_exp(ii) - h_sim(ii);
        dz_sim(ii) = da_exp(ii) - dh_sim(ii);
        t = time_exp(ii);
        zeta = [z_sim(ii)*m, dz_sim(ii)*m, t];


        f_scuppcg_sim(ii) = lwpr_predict(model, zeta'); % predict the force

        ddh_sim(ii) = 1/m*(-m*g + f_scuppcg_sim(ii)) ; % determine acceleration
        dh_sim(ii+1) = dh_sim(ii) + ddh_sim(ii)*dt;
        %         AoB_z_sim(ii+1) = AoB_z_sim(ii) + AoB_zd_sim(ii)*dt;
        h_sim(ii+1) = h_sim(ii) + dh_sim(ii)*dt + 1/2*ddh_sim(ii)*dt*dt; %AS Feb 17, 2022
    end
    % Calculate acceleration at last instance
    ii = length(time_exp);
    f_scuppcg_sim(ii) = lwpr_predict(model, zeta'); % predict the force
    ddh_sim(ii) = 1/m*(-m*g + f_scuppcg_sim(ii)) ; % determine acceleration
    z_sim(end) = h_sim(end) - a_exp(end);
    dz_sim(end) = dh_sim(end) - da_exp(end);
    EoB_zdd_sim = ddh_sim - dda_exp;

    confidenceDisplayName = "3\sigma margin on experiments";
    if plotBool
        execStr = append("f",string(m*1000),' = figure;');
        eval(execStr)
        subplot(3,1,1)
        plot(time_exp, h_exp*1000,'DisplayName',"Experiment mean")
        hold on
        plot(time_exp, h_sim*1000,'k',"DisplayName","Simulation",'LineWidth',1)
        plot(time_exp, (h_exp + Nsigma*h_exp_std)*1000, 'r--', "DisplayName",confidenceDisplayName)
        plot(time_exp, (h_exp - Nsigma*h_exp_std)*1000, 'r--', "HandleVisibility","off")
        grid on
        ylabel("$h$ (mm)","Interpreter","latex","FontSize",fontSize)
        title(append("Simulation versus experiment with mass of ",string(m), "kg. ", initHyperParGrouping))
        lgd = legend('Location', 'southwest','FontSize',fontSize*.7);

        subplot(3,1,2)
        plot(time_exp, dh_exp)
        hold on
        plot(time_exp, dh_sim,'k','LineWidth',1)
        plot(time_exp, dh_exp + Nsigma*dh_exp_std, 'r--', "DisplayName",confidenceDisplayName)
        plot(time_exp, dh_exp - Nsigma*dh_exp_std, 'r--', "HandleVisibility","off")
        grid on
        ylabel("$dot{h}$ (m/s)","Interpreter","latex","FontSize",fontSize)

        subplot(3,1,3)
        plot(time_exp, ddh_exp)
        hold on
        plot(time_exp, ddh_sim,'k','LineWidth',1)
        plot(time_exp, ddh_exp + Nsigma*ddh_exp_std, 'r--', "DisplayName",confidenceDisplayName)
        plot(time_exp, ddh_exp - Nsigma*ddh_exp_std, 'r--', "HandleVisibility","off")
        grid on
        ylabel("$\ddot{h}$ (m/s \textsuperscript{2})","Interpreter","latex","FontSize",fontSize)
        xlabel("Time (s)", "Interpreter","latex",FontSize=fontSize)
    end
end



end