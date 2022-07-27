clearvars; clc; close all; addpath("data"); addpath("figures"); addpath("functions");
set(groot,'defaulttextinterpreter','latex'); set(groot,'defaultAxesTickLabelInterpreter','latex'); set(groot,'defaultLegendInterpreter','latex');
%% ---------------- learning 1D suction cup dynamics ----------------- %%
%% Constants and Settings
%Load the data
load('data/processedData.mat')
load("data/meanAndStdData.mat")
data = processedData; 
exps = fieldnames(expStats);
fn = fieldnames(data);

%Settings
lineWidth = 1.5;    % The linewidth 
Nsigma    = 3;    % the # of std the confidence interval is plotted at
doSave    = true;


% Colors used for the masses
colors = 1/255*...
[0   0   123
 93  85  0
 149 211 79
 162 129 0
 15  98  106
 201 169 128
 110 0   0
 246 169 1
 150 0   0
 25  85  60];


%Computations
for i = 109% 1:Nexps
    exp = data.(fn{i});

    fprintf(append("Used mass: ", string(exp.mass), " kilograms.\n"))

    t = exp.time*1000;
    h = exp.h;
    dh = exp.dh;
    ddh = exp.ddh;

    s = exp.s;
    ds = exp.ds;
    dds = exp.dds;

    a = exp.a;
    da = exp.da;
    dda = exp.dda;
end

masses = [];
z0s = [];
for i = 1:length(fn)
    z0 = data.(fn{i}).z(1)*1000;
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
mass_2 = [];
for i = 1:length(exps)
    mass_2 = [mass_2; expStats.(exps{i}).mass];
end
maxmass = max(mass_2);
minmass = min(mass_2);

for i = 1:length(exps)
    mass = expStats.(exps{i}).mass;
    position_obj(:,i) = expStats.(exps{i}).h_avg;
    velocity_obj(:,i) = expStats.(exps{i}).dh_avg;
    accelera_obj(:,i) = expStats.(exps{i}).ddh_avg;

    position_rel(:,i) = expStats.(exps{i}).z_avg;
    velocity_rel(:,i) = expStats.(exps{i}).dz_avg;
    accelera_rel(:,i) = expStats.(exps{i}).ddz_avg;

    position_arm(:,i) = expStats.(exps{i}).a_avg;
    velocity_arm(:,i) = expStats.(exps{i}).da_avg;
    accelera_arm(:,i) = expStats.(exps{i}).dda_avg;
end

time = [0:length(position_obj)-1]/360;
time = time*1000;


% Plot zm, zdm for all masses at same times
N = length(exps);
for ti = 1:length(time)
    for i = 1:N
        z(i,ti) = expStats.(exps{i}).z_avg(ti);
        zd(i,ti) = expStats.(exps{i}).dz_avg(ti);
        m(i) = expStats.(exps{i}).mass;
    end
end



%% Plot the figures
%Check if figures directory exists, if not, it will create one.
if ~isfolder('figures')
    mkdir('figures');
end

%Create a plot grid
sizex = 456;
sizey = 250;
px = (0:7)*(sizex+10)+10;
py = (0:4)*(sizey+40)+45;
for  ii = 1:length(px)
    for jj = 1:length(py)
        pp{jj,ii} = [px(ii) py(jj)];
    end
end
%%
figure('rend','painters','pos',[pp{1,1} sizex 1.8*sizey]);
    ha = tight_subplot(1,1,[.05 .04],[.1 .12],[0.04 0.03]);  %[gap_h gap_w] [lower upper] [left right] 
    axes(ha(1));
    for ti=1:length(time); plot3(m'.*z(:,ti)*1000, m'.*zd(:,ti), time(ti)*ones(1,N),'color',[.4, .4, .4],'HandleVisibility','off'); hold on; end; hold on;
    for ii=1:N; plot3(m(ii)*z(ii,:)*1000, m(ii)*zd(ii,:), time, 'LineWidth',lineWidth,'color',colors(ii,:)); hold on; end;
    grid on
    axis square
    L1 = legend({"0.16kg","0.306kg","0.452kg",'0.642kg',"0.714kg","0.784kg","0.974kg","1.181kg","1.581kg","2.187kg"},'NumColumns',5,'location','northeast');
    L1.Position(2) = 0.90;
    L1.Position(1) = 0.5-(L1.Position(3)/2);
    L1.FontSize = 9;
    xlabel("$mz$ (kg mm)")
    ylabel("$m\dot{z}$ (kg m/s)")
    zlabel("Time (ms)")
    view(205,25) 
    if doSave
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(fig,'figures/mz-mzd-t-expmean.pdf','-dpdf','-painters')
    end

figure('rend','painters','pos',[pp{1,2} sizex 1.8*sizey]);
    ha = tight_subplot(1,1,[.05 .04],[.1 .12],[0.04 0.03]);  %[gap_h gap_w] [lower upper] [left right] 
    axes(ha(1));
    for ti=1:length(time); plot3(z(:,ti)*1000, zd(:,ti), time(ti)*ones(1,N),'color',[.4, .4, .4],'HandleVisibility','off'); hold on; end; hold on;
    for ii=1:N; plot3(z(ii,:)*1000, zd(ii,:), time, 'LineWidth',lineWidth,'color',colors(ii,:)); hold on; end;
    grid on
    axis square
    L1 = legend({"0.16kg","0.306kg","0.452kg",'0.642kg',"0.714kg","0.784kg","0.974kg","1.181kg","1.581kg","2.187kg"},'NumColumns',5,'location','northeast');
    L1.Position(2) = 0.90;
    L1.Position(1) = 0.5-(L1.Position(3)/2);
    L1.FontSize = 9;
    xlabel("$z$ (mm)")
    ylabel("$\dot{z}$ (m/s)")
    zlabel("Time (ms)")
    view(205,25)
    if doSave
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(fig,'figures/z-zd-t-expmean.pdf','-dpdf','-painters')
    end



% Plot typical release
figure('rend','painters','pos',[pp{1,3} 0.8333*sizex 1.5*sizey]);
    ha = tight_subplot(3,1,[.05 .04],[.08 .08],[0.1 0.03]);  %[gap_h gap_w] [lower upper] [left right] 
    axes(ha(1));
    plot(t, h*1e3, "LineWidth", lineWidth, "DisplayName","package"); hold on; grid on;
    plot(t, s*1e3, "LineWidth", lineWidth, 'DisplayName','suction cup')
    ylabel("Height (mm)")
    xlim([0 140]);
    ylim([50 130])
    yticks(linspace(50,130,5))
    
    axes(ha(2));
    plot(t, dh, "LineWidth", lineWidth); hold on;
    plot(t, ds, "LineWidth", lineWidth); grid on;
    ylabel("Velocity (m/s)")
    xlim([0 140]);
    ylim([-1.5 0.5])
    yticks(linspace(-1.5,0.5,5))

    axes(ha(3));
    plot(t, ddh, "LineWidth", lineWidth); hold on;
    plot(t, dds, "LineWidth", lineWidth); grid on;
    ylabel("Acceleration (m/s$^2$)")
    xlabel("Time (ms)")
    xlim([0 140]);
    ylim([-15 45])
    yticks(linspace(-15,45,5))

    L1 = legend({'package','suction cup'},'NumColumns',2,'location','northeast');
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
figure('rend','painters','pos',[pp{1,4} 0.8333*sizex sizey]);
    ha = tight_subplot(1,1,[.05 .04],[.18 .12],[0.15 0.03]);  %[gap_h gap_w] [lower upper] [left right] 
    axes(ha(1));
    plot(masses,z0s,'k.'); hold on; grid on;    
    plot(massesSorted, z0mean,'color',[0 0.4470 0.7410])
    plot(massesSorted, z0mean + Nsigma*z0std,'color',[0.8500 0.3250 0.0980])
    plot(massesSorted, z0mean - Nsigma*z0std,'color',[0.8500 0.3250 0.0980])
    xlabel("Object mass (kg)")
    ylabel("$z(t_0)$ (mm)")
    ylim([49, 54]);
    xlim([0 2.3]);
    xticks([0 0.25 0.5 0.75 1 1.25 1.5 1.75 2 2.25])
    yticks(-flip([-54 -53.5 -53 -52.5 -52 -51.5 -51 -50.5 -50 -49.5 -49]))
    yticklabels({'49','49,5','50','50,5', '51', '51,5', '52', '52,5', '53', '53,5', '54'})
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
figure('rend','painters','pos',[pp{2,1}+[0 250] 2.2*sizex 1.3*sizey]);
    ha = tight_subplot(3,2,[.05 .07],[.09 .11],[0.04 0.03]);  %[gap_h gap_w] [lower upper] [left right] 
    axes(ha(1));    
    for ii = 1:width(position_obj); plot(time, position_obj(:,ii)*1000,'LineWidth',lineWidth,'color',colors(ii,:)); hold on; drawnow; end
    hold on
    grid on
    xlim([0 142]);
    ylabel('$h$ (mm)')

    axes(ha(3)); 
    for ii = 1:width(position_obj); plot(time, velocity_obj(:,ii),'LineWidth',lineWidth,'color',colors(ii,:)); hold on; drawnow; end
    hold on
    grid on
    xlim([0 142]);
    ylabel('$\dot{h}$ (m/s)')
    
    axes(ha(5)); 
    for ii = 1:width(position_obj); plot(time, accelera_obj(:,ii),'LineWidth',lineWidth,'color',colors(ii,:)); hold on; drawnow; end
    hold on
    grid on
    xlim([0 142]);
    ylabel('$\ddot{h}$ (m/s$^2$)')
    xlabel("Time (ms)")

    axes(ha(2));    
    for ii = 1:width(position_obj); plot(time, position_arm(:,ii)*1000,'LineWidth',lineWidth,'color',colors(ii,:)); hold on; drawnow; end
    hold on
    grid on
    xlim([0 142]);
    ylabel('$a$ (mm)')

    axes(ha(4)); 
    for ii = 1:width(position_obj); plot(time, velocity_arm(:,ii),'LineWidth',lineWidth,'color',colors(ii,:)); hold on; drawnow; end
    hold on
    grid on
    xlim([0 142]);
    ylabel('$\dot{a}$ (m/s)')
    
    axes(ha(6)); 
    for ii = 1:width(position_obj); plot(time, accelera_arm(:,ii),'LineWidth',lineWidth,'color',colors(ii,:)); hold on; drawnow; end
    hold on
    grid on
    xlim([0 142]);
    ylabel('$\ddot{a}$ (m/s$^2$)')
    xlabel("Time (ms)")

    L1 = legend({"0.16kg","0.306kg","0.452kg",'0.642kg',"0.714kg","0.784kg","0.974kg","1.181kg","1.581kg","2.187kg"},'NumColumns',10,'location','northeast');
    L1.Position(2) = 0.93;
    L1.Position(1) = 0.5-(L1.Position(3)/2);
    L1.FontSize = 9; 

    if doSave
        fig = gcf;
        fig.PaperPositionMode = 'auto';
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        print(fig,'figures/ReleaseResults.pdf','-dpdf','-painters')
    end