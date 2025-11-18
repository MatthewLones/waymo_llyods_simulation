function w_t = trafficMap(G, XY, t)
%TRAFFICMAP  Time-varying edge weights (traffic) for graph G.
%
% Inputs
%   G   - graph object with M edges
%   XY  - N x 2 node coordinates
%   t   - current time step
%
% Output
%   w_t - M x 1 vector of edge weights (travel times) at time t

    E = G.Edges.EndNodes;  % M x 2, [u v] for each edge
    M = size(E,1);

    % Base lengths: Euclidean distance between endpoints
    u = E(:,1);
    v = E(:,2);

    dx = XY(u,1) - XY(v,1);
    dy = XY(u,2) - XY(v,2);
    baseLen = sqrt(dx.^2 + dy.^2);   % base spatial length

    % Simple congestion model:
    % - traffic factor depends on proximity to a hotspot and on time
    x = (XY(u,1) + XY(v,1))/2;
    y = (XY(u,2) + XY(v,2))/2;

    % One "CBD" hotspot for traffic
    muT = [mean(XY(:,1)), mean(XY(:,2))];
    sigmaT = (max(XY(:,1)) - min(XY(:,1))) / 3;

    rTsq = (x - muT(1)).^2 + (y - muT(2)).^2;
    spatialFactor = exp(-rTsq / (2*sigmaT^2));   % highest near centre

    % Time-of-day pattern (e.g. two rush peaks per period)
    T2 = 24;
    timeFactor = 0.5 + 0.5 * cos(2*pi*(t)/T2);   % ∈ [0,1]

    % Combined congestion multiplier, e.g. 1 to 3
    congestion = 1 + 2 * (spatialFactor .* timeFactor);

    % Final weights = base length * congestion
    w_t = baseLen .* congestion;
end
