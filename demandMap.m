function D = demandMap(XY, t)
%DEMANDMAP  Time-varying demand field on graph nodes.
%
% Inputs
%   XY - N x 2 matrix, XY(v,:) = [x_v, y_v]
%   t  - current time step (scalar)
%
% Output
%   D  - N x 1 density vector (nonnegative)

    x = XY(:,1);
    y = XY(:,2);

    % Map centre
    cx = mean(x);
    cy = mean(y);
    R  = max(x) - min(x);  % rough size of map

    % --- Static spatial shapes ------------------------------------------
    % Downtown blob
    mu1    = [cx, cy];
    sigma1 = R / 4;
    r1sq   = (x - mu1(1)).^2 + (y - mu1(2)).^2;
    D1     = exp(-r1sq / (2*sigma1^2));

    % Nightlife blob
    mu2    = [min(x) + 0.25*(max(x)-min(x)), ...
              min(y) + 0.7 *(max(y)-min(y))];
    sigma2 = R / 6;
    r2sq   = (x - mu2(1)).^2 + (y - mu2(2)).^2;
    D2     = exp(-r2sq / (2*sigma2^2));

    % Moving "event" hotspot that orbits the centre
    Torbit = 32;                   % how long it takes to circle once
    orbitR = 0.3 * R;              % orbit radius
    mu3    = [cx + orbitR * cos(2*pi*t/Torbit), ...
              cy + orbitR * sin(2*pi*t/Torbit)];
    sigma3 = R / 10;
    r3sq   = (x - mu3(1)).^2 + (y - mu3(2)).^2;
    D3     = exp(-r3sq / (2*sigma3^2));

    % --- Time dynamics for weights --------------------------------------
    Tday   = 24;     % slow daily cycle
    Tfast  = 6;      % faster wiggle to make it livelier

    % Downtown: strong during "day", with faster fluctuations
    w1 = 0.5 ...
         + 0.3 * cos(2*pi*t/Tday) ...
         + 0.2 * cos(2*pi*t/Tfast);

    % Nightlife: out of phase with downtown, also with fast wiggle
    w2 = 0.5 ...
         + 0.3 * cos(2*pi*(t - Tday/2)/Tday) ...
         + 0.2 * cos(2*pi*(t - 1)/Tfast);

    % Clamp to [0,1] so weights don’t go negative or above 1
    w1 = max(0, min(1, w1));
    w2 = max(0, min(1, w2));

    % Event hotspot pulses on/off faster
    Tevent = 10;
    w3 = 0.3 + 0.7 * (0.5 + 0.5 * sin(2*pi*t/Tevent));  % in [0.3, 1.0]

    % --- Combine everything ---------------------------------------------
    D = 0.1 ...
        + 1.0 * w1 .* D1 ...
        + 0.8 * w2 .* D2 ...
        + 0.6 * w3 .* D3;

    % Optional: normalize if you ever need fixed total mass
    % D = D / sum(D);
end
