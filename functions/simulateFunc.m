function [sim_result] = simulateFunc(initHyperParGrouping, plotBool)
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
%         zeta = [z_sim(ii), dz_sim(ii)*m, t];

        f_scuppcg_sim(ii) = lwpr_predict(model, zeta'); % predict the force
        ddh_sim(ii) = 1/m*(-m*g + f_scuppcg_sim(ii)) ; % determine acceleration
        dh_sim(ii+1) = dh_sim(ii) + ddh_sim(ii)*dt;
        h_sim(ii+1) = h_sim(ii) + dh_sim(ii)*dt + 1/2*ddh_sim(ii)*dt*dt; %AS Feb 17, 2022
    end

    % Calculate acceleration at last instance
    ii = length(time_exp);
    f_scuppcg_sim(ii) = lwpr_predict(model, zeta'); % predict the force
    ddh_sim(ii) = 1/m*(-m*g + f_scuppcg_sim(ii)) ; % determine acceleration
    z_sim(end) = h_sim(end) - a_exp(end);
    dz_sim(end) = dh_sim(end) - da_exp(end);
    EoB_zdd_sim = ddh_sim - dda_exp;

  
    RMSE_h = sqrt(mean((h_sim-h_exp').^2));
    RMSE_dh = sqrt(mean((dh_sim-dh_exp').^2));
    RMSE_ddh = sqrt(mean((ddh_sim-ddh_exp').^2));

    MAE_h = max(abs(h_sim-h_exp'));
    MAE_dh = max(abs(dh_sim-dh_exp'));
    MAE_ddh = max(abs(ddh_sim-ddh_exp'));

    errors.RMSE_h = RMSE_h;
    errors.RMSE_dh = RMSE_dh;
    errors.RMSE_ddh = RMSE_ddh;
    errors.MAE_h = MAE_h;
    errors.MAE_dh = MAE_dh;
    errors.MAE_ddh = MAE_ddh;

    %Save the data to a struct
    fld = append("mass",string(expStats.(fnStats{testMass}).mass*1000));
    sim_result.(fld).h_sim = h_sim;
    sim_result.(fld).dh_sim = dh_sim;
    sim_result.(fld).ddh_sim = ddh_sim;
    sim_result.(fld).h_exp = h_exp;
    sim_result.(fld).dh_exp = dh_exp;
    sim_result.(fld).ddh_exp = ddh_exp;
    sim_result.(fld).errors = errors;
    sim_result.(fld).Nsigma = Nsigma;
    sim_result.(fld).time_exp = time_exp;
    sim_result.(fld).h_exp_std = h_exp_std;
    sim_result.(fld).dh_exp_std = dh_exp_std;
    sim_result.(fld).ddh_exp_std = ddh_exp_std;
    sim_result.(fld).m = m;
%     sim_result.init_D = str2double(initHyperParGrouping(7:end));
end



end