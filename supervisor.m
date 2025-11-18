function supervisor()
%SUPERVISOR  Time-stepped Lloyd's algorithm on a grid graph with traffic.

    % ---- Parameters -----------------------------------------------------
    n        = 4;     % number of agents
    Nx       = 20;    % grid in x
    Ny       = 16;    % grid in y
    h        = 1.0;   % spacing
    T        = 50;    % number of time steps in simulation

    % ---- Setup (static pieces) ------------------------------------------
    [G, XY, agentNode] = setupLloyd(n, Nx, Ny, h);

    % Keep an original copy of G to reuse structure; weights change each step.
    baseG = G;

    figure;

    % ---- Time loop ------------------------------------------------------
    for t = 0:T
        % 1) Update demand based on time
        D = demandMap(XY, t);

        % 2) Update traffic (edge weights) based on time
        w_t = trafficMap(baseG, XY, t);
        G.Edges.Weight = w_t;

        % 3) Lloyd "one-step" update at this time
        % 3a) Graph Voronoi partition using current weights
        owner = voronoiRegions(G, agentNode, n);

        % 3b) Centroids of each region (in Euclidean XY space)
        C = centroidCalculator(owner, D, XY, n);

        % 3c) Move agents by snapping centroids to nearest nodes
        agentNodeNew = moveAgents(C, XY, n);

        % 4) Plot current state
        plotState(G, D, XY, agentNodeNew, t);

        % 5) Update agent positions for next time step
        agentNode = agentNodeNew;
    end
end
