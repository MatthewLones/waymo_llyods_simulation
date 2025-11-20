function owner = voronoiRegions(G, agentNode, n)
%VORONOIREGIONS  Voronoi partition on a graph using shortest-path distance.
%
% Inputs
%   G         - graph object with N nodes
%   agentNode - n x 1 vector, agentNode(k) is node index of agent k
%   n         - number of agents
%
% Output
%   owner     - N x 1 vector; owner(v) = k if node v belongs to agent k

    N = numnodes(G);

    % Multi-source shortest paths:
    % Dmat(k,v) = shortest path distance from agent k to node v
    Dmat = distances(G, agentNode, 1:N);    % n x N

    % For each node v, find agent k with minimal distance
    [~, ownerRow] = min(Dmat, [], 1);      % 1 x N
    owner = ownerRow(:);                   % N x 1
end
