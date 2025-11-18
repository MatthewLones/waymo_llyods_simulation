function R = voronoiRegions(P, n)
%VORONOIREGIONS  Discrete Voronoi partition on a grid (Manhattan distance).
%
% Inputs
%   P - Ny x Nx matrix of agent IDs:
%           P(i,j) = 0  if no agent at node (i,j)
%           P(i,j) = k  if agent k is at node (i,j), 1 <= k <= n
%   n - number of agents
%
% Output
%   R - Ny x Nx matrix of region labels:
%           R(i,j) = k if node (i,j) is owned by agent k
%
% Distance used is d((i,j),(p,q)) = |i-p| + |j-q| (Manhattan on indices).

    [Ny, Nx] = size(P);

    % ---- 1) Extract row/col position of each agent ----------------------
    agentRow = zeros(n, 1);
    agentCol = zeros(n, 1);

    for k = 1:n
        [rows, cols] = find(P == k);
        if isempty(rows)
            error('Agent %d not found in P.', k);
        end
        % There should be exactly one cell per agent
        agentRow(k) = rows(1);
        agentCol(k) = cols(1);
    end

    % ---- 2) Assign each grid node to nearest agent ----------------------
    R = zeros(Ny, Nx);

    for i = 1:Ny
        for j = 1:Nx
            % Compute distance from (i,j) to each agent
            bestK   = 1;
            bestDis = inf;

            for k = 1:n
                d = abs(i - agentRow(k)) + abs(j - agentCol(k));
                if d < bestDis
                    bestDis = d;
                    bestK   = k;
                end
                % if d == bestDis we keep existing bestK
                % which biases ties to the smaller index k
            end

            R(i,j) = bestK;
        end
    end
end
