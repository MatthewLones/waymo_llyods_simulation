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

    % Base layout: two Gaussian hotspots like before
    mu1 = [mean(x), mean(y)];
    sigma1 = (max(x) - min(x)) / 4;

    mu2 = [min(x) + 0.25*(max(x)-min(x)), min(y) + 0.7*(max(y)-min(y))];
    sigma2 = (max(x) - min(x)) / 6;

    r1sq = (x - mu1(1)).^2 + (y - mu1(2)).^2;
    r2sq = (x - mu2(1)).^2 + (y - mu2(2)).^2;

    % Static components
    D1 = exp(-r1sq / (2*sigma1^2));   % "downtown"
    D2 = exp(-r2sq / (2*sigma2^2));   % "entertainment district"

    % Simple time pattern:
    % - D1 peaks at t ≡ 0 mod T1  (e.g. morning)
    % - D2 peaks at t ≡ T1/2      (e.g. evening)
    T1 = 24;                         % period in "time steps" (toy choice)

    w1 = 0.5 + 0.5 * cos(2*pi*(t      )/T1);   % in [0,1]
    w2 = 0.5 + 0.5 * cos(2*pi*(t - T1/2)/T1);  % out of phase with w1

    % Combine
    D = 0.1 ...
        + 1.0 * w1 .* D1 ...
        + 0.8 * w2 .* D2;

    % (Optional) normalize if you care about total mass:
    % D = D / sum(D);
end
