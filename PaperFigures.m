%Paper Figures
close all; clearvars; clc;
addpath("data"); addpath("figures"); addpath("functions")
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

colors = [0    0.5172    0.5862
         0         0    0.4828
    0.5862    0.8276    0.3103
    0.9655    0.6207    0.8621
    0.8276    0.0690    1.0000
    0.4828    0.1034    0.4138
    0.9655    0.0690    0.3793
    1.0000    0.7586    0.5172
    0.1379    0.1379    0.0345
    0.5517    0.6552    0.4828];

lineWidth = 2;
Nsigma = 3; % the # of std the confidence interval is plotted at
doSave = false;

load '1DdataReduced.mat'
data = struct1Dreduced; 

fn = fieldnames(data);
Nexps = length(fn);

for i = 109% 1:Nexps
    exp = struct1Dreduced.(fn{i});

    fprintf(append("Used mass: ", string(exp.mass), " kilograms.\n"))

    t = exp.time*1000;
    h = exp.AoB_z;
    hd = exp.AoB_zd;
    hdd = exp.AoB_zdd;

    s = exp.AoS_z;
    sd = exp.AoS_zd;
    sdd = exp.AoS_zdd;

    a = exp.AoE_z;
    ad = exp.AoE_zd;
    add = exp.AoE_zdd;
end

masses = [];
z0s = [];
for i = 1:length(fn)
    z0 = data.(fn{i}).EoB_z(1)*1000;
    z0s = [z0s;z0];
    m = data.(fn{i}).mass;
    masses = [masses; m];
end

massesSorted = sort(unique(masses));
z0mean = [];
z0std = [];
for m = massesSorted'
    ix = find(masses == m);
    z0mean = [z0mean; mean(z0s(ix))];
    z0std = [z0std; std(z0s(ix))];
end


%For the releases
load("meanAndStdData.mat")
exps = fieldnames(expStats);
mass_2 = [];
for i = 1:length(exps)
    mass_2 = [mass_2; expStats.(exps{i}).mass];
end
maxmass = max(mass_2);
minmass = min(mass_2);

for i = 1:length(exps)
    mass = expStats.(exps{i}).mass;
    position_obj(:,i) = expStats.(exps{i}).AoB_zmean;
    velocity_obj(:,i) = expStats.(exps{i}).AoB_zdmean;
    accelera_obj(:,i) = expStats.(exps{i}).AoB_zddmean;

    position_rel(:,i) = expStats.(exps{i}).EoB_zmean;
    velocity_rel(:,i) = expStats.(exps{i}).EoB_zdmean;
    accelera_rel(:,i) = expStats.(exps{i}).EoB_zddmean;

    position_arm(:,i) = expStats.(exps{i}).AoE_zmean;
    velocity_arm(:,i) = expStats.(exps{i}).AoE_zdmean;
    accelera_arm(:,i) = expStats.(exps{i}).AoE_zddmean;
end

time = [0:length(position_obj)-1]/360;
time = time*1000;

%% Plot the figures
%Check if figures directory exists, if not, it will create one.
if ~isfolder('figures')
    mkdir('figures');
end

%Create a plot grid
sizex = 380;
sizey = 250;
px = (0:7)*(sizex+10)+10;
py = (0:4)*(sizey+40)+45;
for  ii = 1:length(px)
    for jj = 1:length(py)
        pp{jj,ii} = [px(ii) py(jj)];
    end
end

% Plot typical release
figure('rend','painters','pos',[pp{1,1} sizex 1.5*sizey]);
    ha = tight_subplot(3,1,[.05 .04],[.08 .08],[0.1 0.03]);  %[gap_h gap_w] [lower upper] [left right] 
    axes(ha(1));
    plot(t, h*1e3, "LineWidth", lineWidth, "DisplayName","suction cup"); hold on; grid on;
    plot(t, s*1e3, "LineWidth", lineWidth, 'DisplayName','package')
    ylabel("Height (mm)")
    xlim([0 140]);
    ylim([50 130])
    yticks(linspace(50,130,5))
    
    axes(ha(2));
    plot(t, hd, "LineWidth", lineWidth, "DisplayName","$\left( ^A \dot{\mathbf{o}}_B\right)_z$"); hold on;
    plot(t, sd, "LineWidth", lineWidth, 'DisplayName','$\left( ^A \dot{\mathbf{o}}_S\right)_z$'); grid on;
    ylabel("Velocity (m/s)")
    xlim([0 140]);
    ylim([-1.5 0.5])
    yticks(linspace(-1.5,0.5,5))

    axes(ha(3));
    plot(t, hdd, "LineWidth", lineWidth, "DisplayName","$\left( ^A \ddot{\mathbf{o}}_B\right)_z$"); hold on;
    plot(t, sdd, "LineWidth", lineWidth, 'DisplayName','$\left( ^A \ddot{\mathbf{o}}_S\right)_z$'); grid on;
    ylabel("Acceleration (m/s$^2$)")
    xlabel("Time (ms)")
    xlim([0 140]);
    ylim([-15 45])
    yticks(linspace(-15,45,5))

    L1 = legend({'suction cup','package'},'NumColumns',2,'location','northeast');
    L1.Position(2) = 0.94;
    L1.Position(1) = 0.5-(L1.Position(3)/2);
    L1.FontSize = 9;    
    
    if doSave
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(fig,'figures/typicalrelease.pdf','-dpdf','-painters')
    end

%% Plot masses vs elongation
figure('rend','painters','pos',[pp{1,2} sizex sizey]);
    ha = tight_subplot(1,1,[.05 .04],[.18 .12],[0.15 0.03]);  %[gap_h gap_w] [lower upper] [left right] 
    axes(ha(1));
    plot(masses,z0s,'k.'); hold on; grid on;    
    plot(massesSorted, z0mean,'color',[0 0.4470 0.7410])
    plot(massesSorted, z0mean + Nsigma*z0std,'color',[0.8500 0.3250 0.0980])
    plot(massesSorted, z0mean - Nsigma*z0std,'color',[0.8500 0.3250 0.0980])
    xlabel("Object mass (kg)")
    ylabel("$z(t_0)$ (mm)")
    ylim([-54,-49]);
    xlim([0 2.3]);
    yticks([-54 -53.5 -53 -52.5 -52 -51.5 -51 -50.5 -50 -49.5 -49])
    yticklabels({'-54','-53.5','-53','-52.5','-52','-51.5','-51','-50.5','-50','-49.5','-49'})
    L1 = legend({'datapoints','mean','3$\sigma$ interval'},'NumColumns',3,'location','northeast');
    L1.Position(2) = 0.92;
    L1.Position(1) = 0.5-(L1.Position(3)/2)+0.06;
    L1.FontSize = 9; 

    if doSave
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(fig,'figures/SCrestLength.pdf','-dpdf','-painters')
    end

%% Plot the position velocity and acceleration of object and tool  arm
figure('rend','painters','pos',[pp{1,3} 2.2*sizex 1.3*sizey]);
    ha = tight_subplot(3,2,[.05 .07],[.1 .14],[0.06 0.03]);  %[gap_h gap_w] [lower upper] [left right] 
    axes(ha(1));    
    for ii = 1:width(position_obj); plot(time, position_obj(:,ii)*1000,'LineWidth',1,'color',colors(ii,:)); hold on; drawnow; end
    hold on
    grid on
    ylabel('$h$ (mm)')

    axes(ha(3)); 
    for ii = 1:width(position_obj); plot(time, velocity_obj(:,ii),'LineWidth',1,'color',colors(ii,:)); hold on; drawnow; end
    hold on
    grid on
    ylabel('$\dot{h}$ (m/s)')
    
    axes(ha(5)); 
    for ii = 1:width(position_obj); plot(time, accelera_obj(:,ii),'LineWidth',1,'color',colors(ii,:)); hold on; drawnow; end
    hold on
    grid on
    ylabel('$\ddot{h}$ (m/s$^2$)')
    xlabel("Time (ms)")

    axes(ha(2));    
    for ii = 1:width(position_obj); plot(time, position_arm(:,ii)*1000,'LineWidth',1,'color',colors(ii,:)); hold on; drawnow; end
    hold on
    grid on
    ylabel('$a$ (mm)')

    axes(ha(4)); 
    for ii = 1:width(position_obj); plot(time, velocity_arm(:,ii),'LineWidth',1,'color',colors(ii,:)); hold on; drawnow; end
    hold on
    grid on
    ylabel('$\dot{a}$ (m/s)')
    
    axes(ha(6)); 
    for ii = 1:width(position_obj); plot(time, accelera_arm(:,ii),'LineWidth',1,'color',colors(ii,:)); hold on; drawnow; end
    hold on
    grid on
    ylabel('$\ddot{a}$ (m/s$^2$)')
    xlabel("Time (ms)")

    L1 = legend({"0.16kg","0.306kg","0.452kg",'0.642kg',"0.714kg","0.784kg","0.974kg","1.181kg","1.581kg","2.187kg"},'NumColumns',5,'location','northeast');
    L1.Position(2) = 0.90;
    L1.Position(1) = 0.5-(L1.Position(3)/2)+0.06;
    L1.FontSize = 9; 

    if doSave
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(fig,'figures/ReleaseResults.pdf','-dpdf','-painters')
    end