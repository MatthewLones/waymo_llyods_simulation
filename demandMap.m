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

    % Two Gaussian hotspots in space
    mu1 = [cx, cy];   % "downtown"
    sigma1 = (max(x) - min(x)) / 4;

    mu2 = [min(x) + 0.25*(max(x)-min(x)), ...
           min(y) + 0.7*(max(y)-min(y))];  % "nightlife district"
    sigma2 = (max(x) - min(x)) / 6;

    r1sq = (x - mu1(1)).^2 + (y - mu1(2)).^2;
    r2sq = (x - mu2(1)).^2 + (y - mu2(2)).^2;

    % Base shapes
    D1 = exp(-r1sq / (2*sigma1^2));
    D2 = exp(-r2sq / (2*sigma2^2));

    % Simple daily cycle: D1 strong early, D2 strong later
    Tperiod = 24;   % interpret t modulo 24 as "hour of day"

    w1 = 0.5 + 0.5 * cos(2*pi*(t      )/Tperiod);   % peaks at t ≡ 0
    w2 = 0.5 + 0.5 * cos(2*pi*(t - Tperiod/2)/Tperiod); % peaks at t ≡ 12

    D = 0.1 + 1.0 * w1 .* D1 + 0.8 * w2 .* D2;

    % Optional: normalize total mass if you care
    % D = D / sum(D);
end
