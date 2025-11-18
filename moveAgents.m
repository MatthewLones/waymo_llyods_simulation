function agentNodeNew = moveAgents(C, XY, n)
%MOVEAGENTS  Move each agent to nearest node to its centroid.
%
% Inputs
%   C   - n x 2 centroids; C(k,:) = [cx_k, cy_k]
%   XY  - N x 2 node coordinates
%   n   - number of agents
%
% Output
%   agentNodeNew - n x 1 vector, new node index for each agent

    N = size(XY, 1);
    agentNodeNew = zeros(n, 1);

    for k = 1:n
        cx = C(k,1);
        cy = C(k,2);

        if isnan(cx) || isnan(cy)
            % Fallback: leave agent undefined for now
            agentNodeNew(k) = NaN;
            continue;
        end

        % squared distance to all nodes
        dx = XY(:,1) - cx;
        dy = XY(:,2) - cy;
        dist2 = dx.^2 + dy.^2;

        [~, idx] = min(dist2);
        agentNodeNew(k) = idx;  % node index
    end
end
