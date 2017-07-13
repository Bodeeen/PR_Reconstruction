function [Act_V, RO_B, OP_B] = Make_simulated_data( WF_R, OP_p )
% Make simulated RESOLFT data, input variable WF_R determines WF-RESOLFT
% mode (true) or MF/SP-RESOLFT mode (false). OP_p determines Off-pattern
% periodicity

%% Set parameters of simulation
size_x = 50000;
size_y = 50000;
vx_size = 20; %Voxel side of the initial data volume 

step_size = 25; %Step size of scan
uL_p = 500; % uLens periodicity
zp = 500; %Z-repetition of fourier planes

px_size_out = 65;

%Define the amount of energy (arbitrary units) delivered to the sample with
%each pulse. Also the bg level of off-switching and bg-fluorescence.
act_E = 2; %2 here Gives 86% activation
off_E = 10;
bg = 0.05;
ro_E = 2;% 2 here Gives 86% read_out
bg_fluorescence = 0.01; %Bg fluorescence is 10% of "structure fluorescence"

%% Make ndgrids, x-1 and y-1 is used to ease later construction of rec matrix
%z-1 is not used because we want a true z = 0 plane.
[yi, xi] = ndgrid(-(size_x-1)/2:vx_size:(size_x-1)/2, -(size_y-1)/2:vx_size:(size_y-1)/2);

s0xy = 185/2.355; %Sigma of excitation PSF in xy where z = 0
s0z = 460/2.355;    % Sigma of excitation PSF in z where x=y=0
detPSFxy0 = 220/2.355; %Sigma of detection PSF in xy where z = 0
detPSFz0 = 520/2.355; %Sigma of detection PSF in z where x=y=0

if WF_R
    scan_size = OP_p; % In WF-RESOLFT mode, scan_size equals Off-pattern periodicity.
else
    scan_size = uL_p; % In MF/SP-RESOLFT mode, scan_size equals uL-pattern periodicity.
    assert(mod(uL_p, OP_p) == 0, 'Off pattern and microlens pattern does not match!')
end

%Correct so that scan_size is a multiple of step_size
if(round(scan_size/step_size) ~= scan_size/step_size)
       warning('Step size corrected!')
       steps = round(OP_p/step_size);
       step_size = OP_p / steps;
end

%Make activation pattern
if WF_R
    Act = ones(size(xi));
else
    Act = zeros(size(xi));

    xyshift = 0;

    s = s0xy
    for dx = -size_x:uL_p:size_x
        dx
        for dy = -size_y:uL_p:size_y
            Act = Act + exp(-((xi-dx-xyshift).^2 + (yi-dy-xyshift).^2)./(2*s.^2));
        end
    end
end

%Make Read out pattern
RO = Act;

% for x = -4000:750:4000
%     for y = -4000:750:4000
%         RO = RO + z_decay .* exp(-((xi-x).^2 + (yi-y).^2)./(2*s.^2));
%     end
% end

%Make OFF-switching pattern
OP = 0.5 + 0.25*(cos((xi-OP_p/2)/(OP_p/(2*pi))) + cos((yi-OP_p/2)/(OP_p/(2*pi))));

OP_B = cat(3, 0 * OP, 247*OP, 255*OP)./255;
Act_V = cat(3, 130*Act, 0*Act, 200*Act)./255;
RO_B = cat(3, 0 * RO, 247*RO, 255*RO)./255;


end