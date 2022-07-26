close all; clear; clc;

foldercontents = dir("LWPR models");
initHyperParGroupings = [];
for i = 3:length(foldercontents)
    initHyperParGroupings = [initHyperParGroupings; string(foldercontents(i).name)];
end



for i = 1:length(initHyperParGroupings) % looping over all init_D
    simulateFunc(initHyperParGroupings{i}, true);
end
