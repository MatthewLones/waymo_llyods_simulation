function supervisor()
%SUPERVISOR  Time-stepped Lloyd's algorithm on a grid graph.
% Demand varies with time; traffic (edge weights) is static.

    % ---- Parameters -----------------------------------------------------
    n   = 4;     % number of agents
    Nx  = 20;    % grid in x
    Ny  = 16;    % grid in y
    h   = 1.0;   % spacing
    T   = 50;    % number of time steps to simulate

    % ---- Static setup ---------------------------------------------------
    [G, XY, agentNode] = setupLloyd(n, Nx, Ny, h);

    figure;

    % ---- Time loop ------------------------------------------------------
    for t = 0:T
        % 1) Current demand
        D = demandMap(XY, t);

        % 2) Lloyd "one-step" update using this D and static G
        owner        = voronoiRegions(G, agentNode, n);
        C            = centroidCalculator(owner, D, XY, n);
        agentNodeNew = moveAgents(C, XY, n);

        % 3) Plot current state
        plotState(G, D, XY, agentNodeNew, t);

        % 4) Update positions for next time step
        agentNode = agentNodeNew;
    end
end
