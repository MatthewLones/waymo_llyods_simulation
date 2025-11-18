function P_new = moveAgents(C, X, Y, n)
%MOVEAGENTS  Move each agent to nearest grid node to its centroid.
%
% Inputs
%   C - n x 2 matrix of centroids; C(k,:) = [cx_k, cy_k]
%   X - Ny x Nx x-coordinate matrix
%   Y - Ny x Nx y-coordinate matrix
%   n - number of agents
%
% Output
%   P_new - Ny x Nx agent-ID matrix after moving
%           P_new(i,j) = 0 if no agent, or k if agent k at node (i,j)

    [Ny, Nx] = size(X);
    P_new = zeros(Ny, Nx);

    for k = 1:n
        cx = C(k, 1);
        cy = C(k, 2);

        if isnan(cx) || isnan(cy)
            % Fallback: skip moving this agent (should not happen for us)
            continue;
        end

        % Squared Euclidean distance from all nodes to centroid
        dist2 = (X - cx).^2 + (Y - cy).^2;

        % Find closest node
        [~, idx] = min(dist2(:));
        [i, j] = ind2sub([Ny, Nx], idx);

        % Place agent k there
        % Note: this allows multiple agents to snap to same node if centroids
        % are very close. For now we ignore that rare case; we can add
        % tie-breaking logic later if needed.
        P_new(i,j) = k;
    end
end
