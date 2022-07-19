close all; clear; clc;

load("1DdataReduced.mat")
data = struct1Dreduced;
clear struct1Dreduced
exps = fieldnames(data);
%% Of all these booleans, only enable one!! (I should have used case, I know..)
plotEoB = false;
plotAoB = true;
plotAoE = false;
plotforce = false;

meanLineWidth = 2;
dataMarkerSize = 4;
Nsigma = 3; % The amount of standard deviations the upper and lower bounds areabove and below the mean curve


% Getting unique sorted list of masses
masses = [];
for i = 1:length(exps)
    masses = [masses, data.(exps{i}).mass];
end
masses = sort(unique(masses));


time = data.mass1experiment1.time*1000;
for m = masses
    EoB_zmat = [];
    EoB_zdmat = [];
    EoB_zddmat = [];

    AoB_zmat = [];
    AoB_zdmat = [];
    AoB_zddmat = [];

    AoE_zmat = [];
    AoE_zdmat = [];
    AoE_zddmat = [];

    Afscuppckgmat = [];

    for i = 1:length(exps)
        if data.(exps{i}).mass == m
            EoB_zmat = [EoB_zmat, data.(exps{i}).EoB_z];
            EoB_zdmat = [EoB_zdmat, data.(exps{i}).EoB_zd];
            EoB_zddmat = [EoB_zddmat, data.(exps{i}).EoB_zdd];

            AoB_zmat = [AoB_zmat, data.(exps{i}).AoB_z];
            AoB_zdmat = [AoB_zdmat, data.(exps{i}).AoB_zd];
            AoB_zddmat = [AoB_zddmat, data.(exps{i}).AoB_zdd];

            AoE_zmat = [AoE_zmat, data.(exps{i}).AoE_z];
            AoE_zdmat = [AoE_zdmat, data.(exps{i}).AoE_zd];
            AoE_zddmat = [AoE_zddmat, data.(exps{i}).AoE_zdd];

            Afscuppckgmat = [Afscuppckgmat, data.(exps{i}).Afscuppckg];
        end
    end
    % Calculate means
    EoB_zmean = mean(EoB_zmat,2);
    EoB_zdmean = mean(EoB_zdmat,2);
    EoB_zddmean = mean(EoB_zddmat,2);

    AoB_zmean = mean(AoB_zmat,2);
    AoB_zdmean = mean(AoB_zdmat,2);
    AoB_zddmean = mean(AoB_zddmat,2);

    AoE_zmean = mean(AoE_zmat,2);
    AoE_zdmean = mean(AoE_zdmat,2);
    AoE_zddmean = mean(AoE_zddmat,2);

    Afscuppckgmean = mean(Afscuppckgmat,2);

    % Calculate std
    EoB_zstd = std(EoB_zmat, 0, 2);
    EoB_zdstd = std(EoB_zdmat, 0, 2);
    EoB_zddstd = std(EoB_zddmat, 0, 2);

    AoB_zstd = std(AoB_zmat, 0, 2);
    AoB_zdstd = std(AoB_zdmat, 0, 2);
    AoB_zddstd = std(AoB_zddmat, 0, 2);

    AoE_zstd = std(AoE_zmat, 0, 2);
    AoE_zdstd = std(AoE_zdmat, 0, 2);
    AoE_zddstd = std(AoE_zddmat, 0, 2);

    Afscuppckgstd = std(Afscuppckgmat, 0, 2);

    baseStr = append("expStats.mass",string(find(masses == m)),".");

    execStr = append(baseStr, "AoE_zmean = AoE_zmean;");
    eval(execStr)
    execStr = append(baseStr, "AoE_zdmean = AoE_zdmean;");
    eval(execStr)
    execStr = append(baseStr, "AoE_zddmean = AoE_zddmean;");
    eval(execStr)

    execStr = append(baseStr, "AoE_zstd = AoE_zstd;");
    eval(execStr)
    execStr = append(baseStr, "AoE_zdstd = AoE_zdstd;");
    eval(execStr)
    execStr = append(baseStr, "AoE_zddstd = AoE_zddstd;");
    eval(execStr)

    execStr = append(baseStr, "AoB_zmean = AoB_zmean;");
    eval(execStr)
    execStr = append(baseStr, "AoB_zdmean = AoB_zdmean;");
    eval(execStr)
    execStr = append(baseStr, "AoB_zddmean = AoB_zddmean;");
    eval(execStr)

    execStr = append(baseStr, "AoB_zstd = AoB_zstd;");
    eval(execStr)
    execStr = append(baseStr, "AoB_zdstd = AoB_zdstd;");
    eval(execStr)
    execStr = append(baseStr, "AoB_zddstd = AoB_zddstd;");
    eval(execStr)

    execStr = append(baseStr, "EoB_zmean = EoB_zmean;");
    eval(execStr)
    execStr = append(baseStr, "EoB_zdmean = EoB_zdmean;");
    eval(execStr)
    execStr = append(baseStr, "EoB_zddmean = EoB_zddmean;");
    eval(execStr)

    execStr = append(baseStr, "EoB_zstd = EoB_zstd;");
    eval(execStr)
    execStr = append(baseStr, "EoB_zdstd = EoB_zdstd;");
    eval(execStr)
    execStr = append(baseStr, "EoB_zddstd = EoB_zddstd;");
    eval(execStr)

    execStr = append(baseStr, "Afscuppckgmean = Afscuppckgmean;");
    eval(execStr)

    execStr = append(baseStr, "Afscuppckgstd = Afscuppckgstd;");
    eval(execStr)
    
    execStr = append(baseStr, "mass = m;");
    eval(execStr)


    if plotEoB
        figure
        
        subplot(3,1,1)
        plot(time, EoB_zmat,'.b',"MarkerSize",dataMarkerSize)
        hold on
        plot(time, EoB_zmean, 'k','LineWidth',1.5)
        plot(time, EoB_zmean + EoB_zstd*Nsigma, 'r', "HandleVisibility","off")
        plot(time, EoB_zmean - EoB_zstd*Nsigma, 'r', "HandleVisibility", "off")
        grid on
        title(append("Mass: ", string(m), "kg"))
%         ylabel("$(^Eo_B)_z$","Interpreter","latex",'FontSize',12)
        ylabel("$z$","Interpreter","latex",'FontSize',15)

        subplot(3,1,2)
        title(append("Mass: ", string(m), "kg"))
        plot(time, EoB_zdmat,'.b',"MarkerSize",dataMarkerSize)
        hold on
        plot(time, EoB_zdmean, 'k','LineWidth',1.5)
        plot(time, EoB_zdmean + EoB_zdstd*Nsigma, 'r', "HandleVisibility","off")
        plot(time, EoB_zdmean - EoB_zdstd*Nsigma, 'r', "HandleVisibility", "off")
        grid on
%         ylabel("$(^E\dot{o}_B)_z$","Interpreter","latex",'FontSize',12)
        ylabel("$\dot{z}$","Interpreter","latex",'FontSize',15)

        subplot(3,1,3)
        title(append("Mass: ", string(m), "kg"))
        plot(time, EoB_zddmat,'.b')
        hold on
        plot(time, EoB_zddmean, 'k','LineWidth',1.5)
        plot(time, EoB_zddmean + EoB_zddstd*Nsigma, 'r', "HandleVisibility","off")
        plot(time, EoB_zddmean - EoB_zddstd*Nsigma, 'r', "HandleVisibility", "off")
        grid on
%         ylabel("$(^E\ddot{o}_B)_z$","Interpreter","latex",'FontSize',12)
        ylabel("$\ddot{z}$","Interpreter","latex",'FontSize',15)
        xlabel("Time (ms)")

    elseif plotAoB
        
        figure
        
        subplot(3,1,1)
        plot(time, AoB_zmat(:,1)*1e3,'.b', "DisplayName","Data","MarkerSize",dataMarkerSize)
        hold on
        plot(time, AoB_zmat(:,2:end)*1e3,'.b','MarkerSize',dataMarkerSize, "HandleVisibility","off")
        plot(time, AoB_zmean*1e3,'k','LineWidth',meanLineWidth ,"DisplayName","Average")
        plot(time, AoB_zmean*1e3 + AoB_zstd*Nsigma*1e3, 'r', "DisplayName","3\sigma interval")
        plot(time, AoB_zmean*1e3 - AoB_zstd*Nsigma*1e3, 'r', "HandleVisibility", "off")
        grid on
        title(append("Mass: ", string(m), "kg"))
        ylabel("$(^A\mathbf{o}_B)_z$ (mm)","Interpreter","latex",'FontSize',12)
        legend("Location","southwest")

        subplot(3,1,2)
        title(append("Mass: ", string(m), "kg"))
        plot(time, AoB_zdmat,'.b',"MarkerSize",dataMarkerSize)
        hold on
        plot(time, AoB_zdmean, 'k','LineWidth',meanLineWidth)
        plot(time, AoB_zdmean + AoB_zdstd*Nsigma, 'r', "HandleVisibility","off")
        plot(time, AoB_zdmean - AoB_zdstd*Nsigma, 'r', "HandleVisibility", "off")
        grid on
        ylabel("$(^A\dot{\mathbf{o}}_B)_z$ (m/s)","Interpreter","latex",'FontSize',12)

        subplot(3,1,3)

        plot(time, AoB_zddmat,'.b',"MarkerSize",dataMarkerSize)
%         title(append("Mass: ", string(m), "kg"))
        hold on
        plot(time, AoB_zddmean, 'k','LineWidth',meanLineWidth)
        plot(time, AoB_zddmean + AoB_zddstd*Nsigma, 'r', "HandleVisibility","off")
        plot(time, AoB_zddmean - AoB_zddstd*Nsigma, 'r', "HandleVisibility", "off")
        grid on
        ylabel("$(^A\ddot{\mathbf{o}}_B)_z$ (m/s\textsuperscript{2})","Interpreter","latex",'FontSize',12)
        xlabel("Time (ms)","FontSize",12)

    elseif plotforce
        figure
        plot(time, Afscuppckgmat(:,1), '.b',"MarkerSize",dataMarkerSize)
        title(append("Mass: ", string(m), "kg"))
        hold on
        plot(time, Afscuppckgmean,'k')

        plot(time, Afscuppckgmean + Afscuppckgstd*Nsigma, 'r')
        plot(time, Afscuppckgmean - Afscuppckgstd*Nsigma, 'r')
        ylabel("Force (N)")
        xlabel("Time (ms)")
        grid on
        
    elseif plotAoE
        figure

        subplot(3,1,1)
        plot(time, AoE_zmat(:,1)*1e3,'.b','DisplayName','data',"MarkerSize",dataMarkerSize)
        hold on
        plot(time, AoE_zmat(:,2:end)*1e3,'.b','HandleVisibility','off',"MarkerSize",dataMarkerSize)
        plot(time, AoE_zmean*1e3, 'k','LineWidth',meanLineWidth,'DisplayName',"Average")
        plot(time, AoE_zmean*1e3 + AoE_zstd*1e3*Nsigma, 'r', "DisplayName","3\sigma interval")
        plot(time, AoE_zmean*1e3 - AoE_zstd*1e3*Nsigma, 'r', "HandleVisibility", "off")
        grid on
%         title(append("Mass: ", string(m), "kg"))
        ylabel("$(^A\mathbf{o}_E)_z$ (mm)","Interpreter","latex",'FontSize',12)
%         ylabel("Tool arm height (mm)")%, "FontSize",12)
        legend("location","best")


        subplot(3,1,2)
%         title(append("Mass: ", string(m), "kg"))
        plot(time, AoE_zdmat,'.b',"MarkerSize",dataMarkerSize)
        hold on
        plot(time, AoE_zdmean, 'k','LineWidth',meanLineWidth)
        plot(time, AoE_zdmean + AoE_zdstd*Nsigma, 'r', "HandleVisibility","off")
        plot(time, AoE_zdmean - AoE_zdstd*Nsigma, 'r', "HandleVisibility", "off")
        grid on
        ylabel("$(^A\dot{\mathbf{o}}_E)_z$ (m/s)","Interpreter","latex",'FontSize',12)
%         ylabel("$\dot{a}$", "Interpreter","latex","FontSize",12)
%         ylabel("Tool arm velocity (m/s)")%, "FontSize", 12)
        subplot(3,1,3)

        plot(time, AoE_zddmat,'.b',"MarkerSize",dataMarkerSize)
%         title(append("Mass: ", string(m), "kg"))
        hold on
        plot(time, AoE_zddmean, 'k','LineWidth',meanLineWidth)
        plot(time, AoE_zddmean + AoE_zddstd*Nsigma, 'r', "HandleVisibility","off")
        plot(time, AoE_zddmean - AoE_zddstd*Nsigma, 'r', "HandleVisibility", "off")
        grid on
        ylabel("$(^A\ddot{\mathbf{o}}_E)_z$ (m/s\textsuperscript{2})","Interpreter","latex",'FontSize',12)
%         ylabel("$\ddot{a}$", "Interpreter","latex","FontSize",12)
%         ylabel("Tool arm velocity (m/s^2)")%,"FontSize",12)
        xlabel("Time (ms)", "FontSize",12)
    end
    

%     figure(masses == m)
%     subplot(3,1,1)
%     title("")
%     if plotAoE
%         saveas(figure(9), "toolArmStatsMass1581.eps","epsc")
%     elseif plotAoB
%         saveas(figure(9), "objectStatsMass1581.eps","epsc")
%     end
end

save("meanAndStdData.mat", "expStats")
figure(9)
subplot(3,1,1)
title("")
if plotAoE
    saveas(figure(9), "toolArmStatsMass1581.eps","epsc")
elseif plotAoB
    saveas(figure(9), "objectStatsMass1581.eps","epsc")
end