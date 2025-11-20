function [G, XY, agentNode] = setupLloyd(n, Nx, Ny, h)
%SETUPLLOYD  Setup Lloyd's algorithm on a simple grid graph.
%
% Inputs
%   n   - number of agents
%   Nx  - # intersections along x (columns)
%   Ny  - # intersections along y (rows)
%   h   - spacing
%
% Outputs
%   G         - graph object
%   XY        - N x 2 node coordinates
%   agentNode - n x 1 vector; agentNode(k) is node index of agent k

    % 1) Build grid graph with constant weights
    [G, XY] = buildGridGraph(Nx, Ny, h);
    N = numnodes(G);

    % 2) Randomly place agents on distinct nodes
    if n > N
        error('n = %d agents > N = %d nodes in graph.', n, N);
    end

    perm = randperm(N, n);
    agentNode = perm(:);   % column vector
end
