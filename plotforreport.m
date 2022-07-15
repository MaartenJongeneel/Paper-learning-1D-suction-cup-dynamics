close all; clear; clc;

fontSize = 14;

%% Plotting all experiments in z zdm t space
load("meanAndStdData.mat")
data = expStats;
clear expStats

exps = fieldnames(data);
masses = [];

for i = 1:length(exps)
    masses = [masses; data.(exps{i}).mass];
end
masses = sort(unique(masses));

time = [0:length(data.mass1.AoB_zddmean)-1]/360;
%% Plot mz, mzd for all masses at same times
submersion = figure(1);
for t = 1:length(time)
    N = length(exps);
    z = zeros(N,1);
    zd = zeros(N,1);
    m = zeros(N,1);
    for i = 1:N
        z(i) = data.(exps{i}).EoB_zmean(t);
        zd(i) = data.(exps{i}).EoB_zdmean(t);
        m(i) = data.(exps{i}).mass;
    end
    plot3(z.*m, zd.*m, time(t)*ones(N,1)*1000,'color',[.4, .4, .4],'HandleVisibility','off')
    hold on
end


for i = 1:length(exps)

    m = data.(exps{i}).mass;
    switch m
        case masses(1)
            linespec = 'r';
        case masses(2)
            linespec = 'g';
        case masses(3)
            linespec = 'b';
        case masses(4)
            linespec = 'c';
        case masses(5)
            linespec = 'm';
        case masses(6)
            linespec = 'y';
        case masses(7)
            linespec = 'k';
        case masses(8)
            linespec = 'r--';
        case masses(9)
            linespec = 'g--';
        case masses(10)
            linespec = 'b--';
    end
    time = [0:length(data.(exps{i}).EoB_zmean)-1]/360;
    plot3(data.(exps{i}).EoB_zmean*data.(exps{i}).mass, data.(exps{i}).EoB_zdmean*data.(exps{i}).mass, time*1000, linespec,'LineWidth',1,'DisplayName',append(string(m), 'kg'))
    hold on
    
end

grid on
axis square
% legend("FontSize",fontSize*.7,'Location','none')
legend("FontSize",fontSize*.7, "NumColumns",2,'Location', 'best')

xlabel("$zm$ (kg m)",'Interpreter','latex','FontSize',fontSize)
ylabel("$\dot{z}m$ (kgm/s)",'Interpreter','latex','FontSize',fontSize)
zlabel("Time (ms)",'Interpreter','latex','FontSize',fontSize)
view(25,25)



%% Plot z, zd for all masses at same times
simpleinputspace = figure(2);
for t = 1:length(time)
    N = length(exps);
    z = zeros(N,1);
    zd = zeros(N,1);
    m = zeros(N,1);
    for i = 1:N
        z(i) = data.(exps{i}).EoB_zmean(t);
        zd(i) = data.(exps{i}).EoB_zdmean(t);
        m(i) = data.(exps{i}).mass;
    end
    plot3(z*1000, zd, time(t)*ones(N,1)*1000,'color',[.4, .4, .4],'HandleVisibility','off')
    hold on
end


for i = 1:length(exps)

    m = data.(exps{i}).mass;
    switch m
        case masses(1)
            linespec = 'r';
        case masses(2)
            linespec = 'g';
        case masses(3)
            linespec = 'b';
        case masses(4)
            linespec = 'c';
        case masses(5)
            linespec = 'm';
        case masses(6)
            linespec = 'y';
        case masses(7)
            linespec = 'k';
        case masses(8)
            linespec = 'r--';
        case masses(9)
            linespec = 'g--';
        case masses(10)
            linespec = 'b--';
    end
    time = [0:length(data.(exps{i}).EoB_zmean)-1]/360;
    plot3(data.(exps{i}).EoB_zmean*1000, data.(exps{i}).EoB_zdmean, time*1000, linespec,'LineWidth',1,'DisplayName',append(string(m), 'kg'))
    hold on
    
end

grid on
axis square
legend("FontSize",fontSize*.7, "NumColumns",2,'Location', 'best')

xlabel("$z$ (mm)",'Interpreter','latex','FontSize',fontSize)
ylabel("$\dot{z}$ (m/s)",'Interpreter','latex','FontSize',fontSize)
zlabel("Time (ms)",'Interpreter','latex','FontSize',fontSize)

view(25,25) 

%% Save figures
saveas(submersion, 'submersion.eps', 'epsc')
saveas(simpleinputspace, 'unsubmerged.eps', 'epsc')