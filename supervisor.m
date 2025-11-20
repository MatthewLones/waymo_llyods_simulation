function supervisor()
%SUPERVISOR  Time-stepped Lloyd's algorithm on a grid graph.
% Demand varies with time; traffic (edge weights) is static.

    % ---- Parameters -----------------------------------------------------
    n   = 3;     % number of agents
    Nx  = 20;    % grid in x
    Ny  = 16;    % grid in y
    h   = 1.0;   % spacing
    T   = 15;    % number of time steps to simulate

    % ---- Static setup ---------------------------------------------------
    [G, XY, agentNode] = setupLloyd(n, Nx, Ny, h);

    % ---- Time loop ------------------------------------------------------
    for t = 0:T
        % 1) Current demand
        D = demandMap(XY, t);

        % 2) Lloyd "one-step" update using this D and static G
        owner        = voronoiRegions(G, agentNode, n);   % Voronoi labels
        C            = centroidCalculator(owner, D, XY, n);
        agentNodeNew = moveAgents(C, XY, n);

        % 3) Plot all pieces side by side
        plot(G, D, XY, agentNode, owner, C, agentNodeNew, t);

        % 4) Update positions for next time step
        agentNode = agentNodeNew;
    end
end
