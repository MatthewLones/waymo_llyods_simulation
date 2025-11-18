function w_t = trafficMap(baseG, XY, t)
%TRAFFICMAP  Time-varying edge weights (traffic) for graph baseG.
%
% Inputs
%   baseG - graph object with Edges.BaseLen and Edges.RoadType
%   XY    - N x 2 node coordinates
%   t     - current time step
%
% Output
%   w_t   - M x 1 vector of edge weights (travel times) at time t

    E = baseG.Edges;
    endNodes = E.EndNodes;   % M x 2
    u = endNodes(:,1);
    v = endNodes(:,2);
    baseLen  = E.BaseLen;    % M x 1
    roadType = E.RoadType;   % M x 1, 1 = local, 2 = arterial

    % --- 1) Spatial factor: congestion highest near "city centre" --------
    xMid = (XY(u,1) + XY(v,1)) / 2;
    yMid = (XY(u,2) + XY(v,2)) / 2;

    muT    = [mean(XY(:,1)), mean(XY(:,2))];
    sigmaT = (max(XY(:,1)) - min(XY(:,1))) / 3;

    rTsq = (xMid - muT(1)).^2 + (yMid - muT(2)).^2;
    spatialFactor = exp(-rTsq / (2*sigmaT^2));   % near centre → ~1, far → ~0

    % --- 2) Time factor: simple daily cycle -------------------------------
    Tperiod   = 24;
    timeFactor = 0.5 + 0.5 * cos(2*pi*t / Tperiod);  % in [0,1]

    % --- 3) Combine with road type ---------------------------------------
    % Locals: can get very congested
    localCongestion    = 1 + 2.0 * spatialFactor .* timeFactor;
    % Arterials: designed to handle flow better (less sensitive)
    arterialCongestion = 1 + 0.7 * spatialFactor .* timeFactor;

    congestion = localCongestion;
    isArterial = (roadType == 2);
    congestion(isArterial) = arterialCongestion(isArterial);

    % Final time-varying weights
    w_t = baseLen .* congestion;
end
