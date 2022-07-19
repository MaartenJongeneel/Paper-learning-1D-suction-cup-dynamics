close all; clear; clc;

load meanAndStdData.mat
load("LWPR models average/init_D1000/LWPRmodel5.mat") % choose a model with a validation mass that is in the middle

%% Plot the number of projection directions for each rf of the model
Nrfs = length(model.sub.rfs);
R = zeros(Nrfs,1);
for k = 1:Nrfs
    U_k = model.sub.rfs(k).U;
    [~,R(k)] = size(U_k);
    
end
figure
plot(R)
xlabel("model k")
ylabel("Number of projection directions of model k R_k")
grid on

%% Plot the trajectories through mz mzdot t
fn = fieldnames(expStats);

figure
for i = 1:length(fn)
    exp = expStats.(fn{i});
    m = exp.mass;
    z= exp.EoB_zmean;
    zd = exp.EoB_zdmean;
    t = [0:length(z)-1]/360;
    plot3(z*m, zd*m, t*1000,'k')
    hold on
    grid on
end

for j = 1:length(t)
    for i = 1:length(fn)
        exp = expStats.(fn{i});
        m = exp.mass;
        zm(i) = exp.EoB_zmean(j)*m;
        zdm(i) = exp.EoB_zdmean(j)*m;
    end
    plot3(zm, zdm, t(j)*1000*ones(length(zm),1),'k--')
end

mean_x = model.mean_x;
norm_x = model.norm_in;
for k = 1:Nrfs
    c_k = model.sub.rfs(k).c.*norm_x; c_k(3) = c_k(3)*1000;
    plot3(c_k(1), c_k(2), c_k(3), 'xr')

    U_k = model.sub.rfs(k).U;
    U_k(:,1) = U_k(:,1)./norm_x./[1';1;1000];
    U_k(:,2) = U_k(:,2)./norm_x./[1;1;1000];
    
    plot3([c_k(1), c_k(1) + U_k(1,1)], [c_k(2), c_k(2) + U_k(2,1)],[c_k(3), c_k(3) + U_k(3,1)], 'r')
    plot3([c_k(1), c_k(1) + U_k(1,2)], [c_k(2), c_k(2) + U_k(2,2)],[c_k(3), c_k(3) + U_k(3,2)], 'b')

end
