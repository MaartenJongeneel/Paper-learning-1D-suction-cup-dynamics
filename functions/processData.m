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
    AHB_raw = exp.SENSOR_MEASUREMENT.Mocap.POSTPROCESSING.PlasticPlate002.transforms.ds;
    AHE_raw = exp.SENSOR_MEASUREMENT.Mocap.POSTPROCESSING.GripperB002.transforms.ds;
    AHS_raw = exp.SENSOR_MEASUREMENT.Mocap.POSTPROCESSING.SuctionCup002.transforms.ds;
    for j = 1:length(AHB_raw)
        AoB_raw(:,j) = AHB_raw{j}(1:3,4);
        AoE_raw(:,j) = AHE_raw{j}(1:3,4);
        AoS_raw(:,j) = AHS_raw{j}(1:3,4);
    end

    [AoB, dAoB, ddAoB] = SavitzkyGolay_on_R3(AoB_raw, n_linear, p_linear, 360);
    [AoE, dAoE, ddAoE] = SavitzkyGolay_on_R3(AoE_raw, n_linear, p_linear, 360);
    [AoS, dAoS, ddAoS] = SavitzkyGolay_on_R3(AoS_raw, n_linear, p_linear, 360);
    
    % Sync Mocap with UR10 data
    timeFromMotiveStart2Release = .8;
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
    
    % z = a - h
    z = a - h;
    dz = da - dh;
    ddz = dda - ddh;

    s = AoS(3,samplesfromfilteredMotive2release:ixend);
    ds = dAoS(3,samplesfromfilteredMotive2release:ixend);
    dds = ddAoS(3,samplesfromfilteredMotive2release:ixend);
    
    processedData.(append("experiment",string(i))).h = h;
    processedData.(append("experiment",string(i))).dh = dh;
    processedData.(append("experiment",string(i))).ddh = ddh;
    
    mass = str2double(exp.OBJECT.PlasticPlate002.attr.mass);
    g = 9.81;
    f_scuppckg = mass*ddh + mass*g;
    processedData.(append("experiment",string(i))).f_scuppckg = f_scuppckg;

    processedData.(append("experiment",string(i))).a = a;
    processedData.(append("experiment",string(i))).da = da;
    processedData.(append("experiment",string(i))).dda = dda;

    processedData.(append("experiment",string(i))).z = z;
    processedData.(append("experiment",string(i))).dz = dz;
    processedData.(append("experiment",string(i))).ddz = ddz;

    processedData.(append("experiment",string(i))).s = s;
    processedData.(append("experiment",string(i))).ds = ds;
    processedData.(append("experiment",string(i))).dds = dds;    

    processedData.(append("experiment",string(i))).mass = mass;
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