% This script loads the 1D hdf5 file and extracts relevant data for 1D
% model and saves struct of h5 file to "1D Archive.mat" to
% and only relevant vertical data to "1DdataReduced.mat"

close all; clear; clc;

% if not(isfile("1D Archive.mat"))
    fprintf("Loading .h5 file... \n")
    struct1D = readH5("1D Archive.h5");
%     fprintf("Saving data in .mat file... \n")
%     save("1D Archive.mat", "struct1D",'-v7.3')
%     fprintf("Saved data to .mat file.")
% else
%     fprintf("Loading .mat file with data... \n")
%     load("1D Archive.mat")
%     fprintf("Loaded data from .mat file.\n")
% end

%% Everything but loading data

plotz = false;
plotAoE_z = false;
plotAoB_z = false;
plotforce = false;


dtMocap = 1/360;
g = 9.81;
tstart = 0.805;
duration = 0.14;
tend = tstart + duration;


framelen = 13;
order = 3;

addpath("functions\")
fn = fieldnames(struct1D);
exps = fn(startsWith(fn, "Rec"));
masses = [];
for i = 1:length(exps)
    m = str2double(struct1D.(exps{i}).OBJECT.PlasticPlate2.attr.mass);
    masses = [masses, m];
end

masses = sort(unique(masses));
k = 1;

for i = 1:length(masses)
    
    for ii = 1:length(exps)
        if str2double(struct1D.(exps{ii}).OBJECT.PlasticPlate2.attr.mass) == masses(i)
            m = masses(i);
            AHB = struct1D.(exps{ii}).SENSOR_MEASUREMENT.Mocap.POSTPROCESSING.PlasticPlate2.transforms.ds;
            AHE = struct1D.(exps{ii}).SENSOR_MEASUREMENT.Mocap.POSTPROCESSING.Gripper_B2.transforms.ds;
            AHS = struct1D.(exps{ii}).SENSOR_MEASUREMENT.Mocap.POSTPROCESSING.Suction_cup2.transforms.ds;
            N = length(AHS);
            time = [0:N-1]*dtMocap;

            % Preallocating
            EoB_raw = zeros(N,1);
            AoB_raw = EoB_raw;
            AoS_raw = EoB_raw;
            AoE_raw = EoB_raw;

            for j = 1:N
                AoB_raw(j) = AHB{j}(3,4);
                AoS_raw(j) = AHS{j}(3,4);
                AoE_raw(j) = AHE{j}(3,4);
            end
            % First subtract, then apply SG
            EoB_raw = AoB_raw - AoE_raw;


            % Savitzky-Golay
            [EoB_z, EoB_zd, EoB_zdd] = SGfunction(EoB_raw, order, framelen, dtMocap);
            [AoE_z, AoE_zd, AoE_zdd] = SGfunction(AoE_raw, order, framelen, dtMocap);
            [AoB_z, AoB_zd, AoB_zdd] = SGfunction(AoB_raw, order, framelen, dtMocap);
            [AoS_z, AoS_zd, AoS_zdd] = SGfunction(AoS_raw, order, framelen, dtMocap);

            % Cutting
            ixstart = find(time >= tstart, 1, 'first');
            ixend = find(time <= tend, 1, 'last');

            EoB_z = EoB_z(ixstart:ixend);
            EoB_zd = EoB_zd(ixstart:ixend);
            EoB_zdd = EoB_zdd(ixstart:ixend);

            AoE_z = AoE_z(ixstart:ixend);
            AoE_zd = AoE_zd(ixstart:ixend);
            AoE_zdd = AoE_zdd(ixstart:ixend);

            AoB_z = AoB_z(ixstart:ixend);
            AoB_zd = AoB_zd(ixstart:ixend);
            AoB_zdd = AoB_zdd(ixstart:ixend);

            AoS_z = AoS_z(ixstart:ixend);
            AoS_zd = AoS_zd(ixstart:ixend);
            AoS_zdd = AoS_zdd(ixstart:ixend);

            time = time(1:ixend-ixstart+1);

            Afscuppckg = masses(i)*AoB_zdd + masses(i)*g;

            % Save all data in new struct, excuse the unwieldy coding
            baseStr = append("struct1Dreduced.mass", string(i),"experiment",string(k));

            execStr = append(baseStr, '.mass = m;');
            eval(execStr)
            execStr = append(baseStr, '.time = time;');
            eval(execStr)
            execStr = append(baseStr, '.AoB_z = AoB_z;');
            eval(execStr)
            execStr = append(baseStr, '.AoB_zd = AoB_zd;');
            eval(execStr)
            execStr = append(baseStr, '.AoB_zdd = AoB_zdd;');
            eval(execStr)

            execStr = append(baseStr, '.AoE_z = AoE_z;');
            eval(execStr)
            execStr = append(baseStr, '.AoE_zd = AoE_zd;');
            eval(execStr)
            execStr = append(baseStr, '.AoE_zdd = AoE_zdd;');
            eval(execStr)

            execStr = append(baseStr, '.AoS_z = AoS_z;');
            eval(execStr)
            execStr = append(baseStr, '.AoS_zd = AoS_zd;');
            eval(execStr)
            execStr = append(baseStr, '.AoS_zdd = AoS_zdd;');
            eval(execStr)

            execStr = append(baseStr, '.EoB_z = EoB_z;');
            eval(execStr)
            execStr = append(baseStr, '.EoB_zd = EoB_zd;');
            eval(execStr)
            execStr = append(baseStr, '.EoB_zdd = EoB_zdd;');
            eval(execStr)

            execStr = append(baseStr, '.Afscuppckg = Afscuppckg;');
            eval(execStr)


            if plotz
                figure(i)
                subplot(3,1,1)
                plot(time,EoB_z)
                hold on
                grid on
                ylabel("$^Eo_B$ (m)","Interpreter","latex")
                title(append("Mass: ", string(masses(i)), "kg"))
                legend(string([1:11]))
                subplot(3,1,2)
                plot(time, EoB_zd)
                hold on
                grid on
                ylabel("$^E\dot{o}_B$ (m/s)","Interpreter","latex")


                subplot(3,1,3)
                plot(time, EoB_zdd)
                hold on
                grid on
                ylabel("$^E\ddot{o}_B$ (ms\textsuperscript{2})","Interpreter","latex")
                xlabel("Time (s)")

            elseif plotAoE_z
                figure(i)
                subplot(3,1,1)
                plot(time,AoE_z)
                hold on
                grid on
                ylabel("$^Ao_E$ (m)","Interpreter","latex")
                title(append("Mass: ", string(masses(i)), "kg"))

                subplot(3,1,2)
                plot(time, AoE_zd)
                hold on
                grid on
                ylabel("$^A\dot{o}_E$ (m/s)","Interpreter","latex")

                subplot(3,1,3)
                plot(time, AoE_zdd)
                hold on
                grid on
                ylabel("$^A\ddot{o}_E$ (ms\textsuperscript{-2})","Interpreter","latex")
                xlabel("Time (s)")

            elseif plotAoB_z
                figure(i)
                subplot(3,1,1)
                plot(time,AoB_z)
                hold on
                grid on
                ylabel("$^Ao_B$ (m)","Interpreter","latex")
                title(append("Mass: ", string(masses(i)), "kg"))

                subplot(3,1,2)
                plot(time, AoB_zd)
                hold on
                grid on
                ylabel("$^A\dot{o}_B$ (m/s)","Interpreter","latex")


                subplot(3,1,3)
                plot(time, AoE_zdd)
                hold on
                grid on
                ylabel("$^A\ddot{o}_B$ (ms\textsuperscript{-2})","Interpreter","latex")
                xlabel("Time (s)")

            elseif plotforce
                figure(i)
                plot(time, Afscuppckg)
                hold on
                title(append("Mass: ", string(masses(i)), "kg"))
                ylabel("Force (N)")
                xlabel("Time (s)")
                grid on
            end

            k = k + 1;
        end

    end
    k=1;
end


%% Removing outlier: mass 7 experiment 5 
struct1Dreduced = rmfield(struct1Dreduced, "mass7experiment5");

%% Saving data to 1DdataReduced.mat
disp("Done processing data.")
disp("Saving data to 1DdataReduced.mat..")
tic
save("1DdataReduced.mat", "struct1Dreduced")
toc
disp("Done saving reduced data.")

rmpath("functions\")