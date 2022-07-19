close all; clear; clc;


load("1DdataReduced.mat")
data = struct1Dreduced;
clear struct1Dreduced

exps = fieldnames(data);
figure
for i = 1:length(exps)
    m = data.(exps{i}).mass;
    plot3(data.(exps{i}).EoB_z, data.(exps{i}).EoB_zd*m, data.(exps{i}).time)
    hold on
    
end
grid on 
axis square
xlabel("z")
ylabel("zd")
zlabel("time")