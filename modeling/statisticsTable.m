close all; clear; clc;

load meanAndStdData.mat
Nsigma = 3;
mass9 = expStats.mass9;

maxVariancePosition = max(sqrt(mass9.AoB_zstd))*1e3
maxVarianceVelocity = max(sqrt(mass9.AoB_zdstd))
maxvarianceAcceleration = max(sqrt(mass9.AoB_zddstd))

figure
plot(mass9.AoB_zddmean)
hold on
plot(mass9.AoB_zddmean+Nsigma*mass9.AoB_zddstd)
plot(mass9.AoB_zddmean-Nsigma*mass9.AoB_zddstd)