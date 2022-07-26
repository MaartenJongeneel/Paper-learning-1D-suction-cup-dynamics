function [AoB, dAoB, ddAoB] = SavitzkyGolay_on_R3(AoB_raw,n,p,freq)
%% Computed values
N = length(AoB_raw(1,:)); %Number of samples in the sequence    [-]
dt = 1/freq;              %Time step lower sampled              [s]
te = N*dt;                %Total lenght of the sequence         [s]
ts = (0:dt:te);           %Signal time vector                   [s]
w = -n:n;                 %Window for Golay                     [-]
I = eye(3);               %Short hand notation                  [-]
% tf = ts((n+1):(N-(n+1))); %Time vector filtered signal          [s]

%% Preallocate memory
AoB   = NaN(3,N-length(w));
dAoB  = NaN(3,N-length(w));
ddAoB = NaN(3,N-length(w));

%% Savitzky-Golay
%For each time step (where we can apply the window)
cnt = 1;
for ii = (n+1):(N-(n+1))
    %Build matrix A and vector b based on window size w
    row = 1;
    for jj = 1:length(w)
        %Time difference between 0^th element and w(jj)^th element
        Dt = (ts(ii+w(jj))-ts(ii));
        %Determine row of A matrix
        Ajj = I;
        for kk = 1:p
            Ajj = cat(2,Ajj,(1/kk)*Dt^kk*I); %Concatenation based on order n
        end
        A(row:row+length(I)-1,:) = Ajj;
        b(row:row+length(I)-1,:) = AoB_raw(:,ii+w(jj));%vee(logm(R(:,:,ii+w(jj))/R(:,:,ii)));
        row = row+length(I); %Update to next row
    end
    %Solve the LS problem
    rho = (A'*A)\A'*b;
    
    %Obtain the coefficients of rho
    rho0 = rho(1:3);  rho1 = rho(4:6);  rho2 = rho(7:9);
    
    %Compute analytically the rotation matrices, ang. vel., and ang. acc.
    AoB(:,cnt) = rho0;
    dAoB(:,cnt) = rho1;
    ddAoB(:,cnt) = rho2;
    
    %Update the index counter
    cnt = cnt+1;
end
end
