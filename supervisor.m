function supervisor()
%SUPERVISOR  Run discrete Lloyd iterations on a grid and plot.

    % ---- Parameters -----------------------------------------------------
    n       = 10;    % number of agents
    Nx      = 30;   % grid size along x
    Ny      = 16;   % grid size along y
    h       = 1.0;  % spacing
    maxIter = 30;   % safety cap on iterations

    % ---- Setup ----------------------------------------------------------
    [D, P, X, Y] = setupLloyd(n, Nx, Ny, h);

    figure;

    % Initial plot
    plotState(D, P, X, Y, 0);

    % ---- Lloyd iterations -----------------------------------------------
    for iter = 1:maxIter
        % 1) Build Voronoi regions
        R = voronoiRegions(P, n);

        % 2) Compute density-weighted centroids
        C = centroidCalculator(R, D, X, Y, n);

        % 3) Move agents to nearest nodes
        P_new = moveAgents(C, X, Y, n);

        % 4) Plot state
        plotState(D, P_new, X, Y, iter);

        % 5) Check convergence
        if isequal(P_new, P)
            fprintf('Converged at iteration %d.\n', iter);
            P = P_new;
            break;
        end

        P = P_new;
    end

    if ~isequal(P_new, P)
        fprintf('Reached maxIter = %d without full convergence.\n', maxIter);
    end
end
