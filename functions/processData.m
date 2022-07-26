% This script loads a .mat file generated in h5tomat.m and applies
% Savitzky-Golay filtering to calculate the velocity and acceleration of
% the tool arm and VIO when released at zero tool arm velocity. It saves the filtered
% signals and its derivatives to the same .mat file to substructs. It also
% saves the cut raw data in order to assess the reconstruction error.
% This script also syncs the UR10 data with OptiTrack by using the
% Optitrack IO recorded from the UR10. Then using the IO data of the
% blowoff signal the start of the release is found. Using this information,
% the signals before the release is cut off, and given the variable "dur"
% in this script the duration from the start of the release is set by hand.

function processedData = processData(data, p_linear, n_linear, dur)

fn = fieldnames(data);
exps = fn(startsWith(fn, "Rec_"));
Nexps = length(exps);

%% Savitzky-Golay
freqMocap = 360;
freqUR10 = 125;
f = waitbar(0, "Applying Savitzky-Golay..");
for i = 1:Nexps
    tic
    exp = data.(exps{i});
    AHB_raw = exp.SENSOR_MEASUREMENT.Mocap.POSTPROCESSING.PlasticPlate2.transforms.ds;
    AHE_raw = exp.SENSOR_MEASUREMENT.Mocap.POSTPROCESSING.Gripper_B2.transforms.ds;
    for j = 1:length(AHB_raw)
        AoB_raw(:,j) = AHB_raw{j}(1:3,4);
        AoE_raw(:,j) = AHE_raw{j}(1:3,4);
    end

    [AoB, dAoB, ddAoB] = SavitzkyGolay_on_R3(AoB_raw, n_linear, p_linear, 360);
    [AoE, dAoE, ddAoE] = SavitzkyGolay_on_R3(AoE_raw, n_linear, p_linear, 360);
%     fprintf("Done with SG for this release.\n")
    
    % Sync Mocap with UR10 data
    ioTable = exp.SENSOR_MEASUREMENT.UR10_sensor.datalog.ds;
    ioOptiTrack = table2array(ioTable(:,18));
    ioBlowoff = table2array(ioTable(:,19));
    ixOptiTrack = find(ioOptiTrack == 1 , 1, 'first');
    ixReleaseCommand = find(ioBlowoff == 1, 1, 'first');

    
%     timeFromMotiveStart2Release = (ixReleaseCommand-ixOptiTrack-1)/freqUR10;
    timeFromMotiveStart2Release = .8;
%     fprintf(append("Release starts at t = ", string(timeFromMotiveStart2Release), " in Mocap time.\n"))
    ix_start_raw = ceil(timeFromMotiveStart2Release*freqMocap);
    ix_end_raw = ix_start_raw + ceil(dur*freqMocap);
    samplesfromfilteredMotive2release = ceil(timeFromMotiveStart2Release*freqMocap)-n_linear-1;
    ixend = samplesfromfilteredMotive2release + ceil(dur*freqMocap);

    % Cut off all unnecessary signal before release and after impact, and
    % only extract vertical data
    h = AoB(3,samplesfromfilteredMotive2release:ixend);
    dh = dAoB(3,samplesfromfilteredMotive2release:ixend);
    ddh = ddAoB(3,samplesfromfilteredMotive2release:ixend);

    a = AoE(3,samplesfromfilteredMotive2release:ixend);
    da = dAoE(3,samplesfromfilteredMotive2release:ixend);
    dda = ddAoE(3,samplesfromfilteredMotive2release:ixend);
    
    processedData.(append("experiment",string(i))).h = h;
    processedData.(append("experiment",string(i))).dh = dh;
    processedData.(append("experiment",string(i))).ddh = ddh;

    processedData.(append("experiment",string(i))).a = a;
    processedData.(append("experiment",string(i))).da = da;
    processedData.(append("experiment",string(i))).dda = dda;
    

    processedData.(append("experiment",string(i))).mass = str2double(exp.OBJECT.PlasticPlate2.attr.mass);
    processedData.(append("experiment",string(i))).time = [0:length(h)-1]/freqMocap;

    t = toc;
    timeleft = (Nexps-i)*t;
    if timeleft > 60
        waitbar(i/Nexps,f, append("Time left: ", string(ceil(timeleft/60)), " minutes."));
    else
        waitbar(i/Nexps,f, append("Time left: ", string(ceil(timeleft)), " seconds"));
    end
end
close(f)

end