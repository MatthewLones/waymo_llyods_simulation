function C = centroidCalculator(owner, D, XY, n)
%CENTROIDCALCULATOR  Density-weighted centroids for each Voronoi cell.
%
% Inputs
%   owner - N x 1 vector, owner(v) in {1,...,n}
%   D     - N x 1 density vector
%   XY    - N x 2 coordinates of nodes
%   n     - number of agents
%
% Output
%   C     - n x 2 matrix; C(k,:) = [cx_k, cy_k]

    C = zeros(n, 2);

    for k = 1:n
        mask = (owner == k);    % logical N x 1

        w = D(mask);
        if isempty(w)
            % No nodes in this region; should be rare
            C(k,:) = [NaN, NaN];
            continue;
        end

        xy_k = XY(mask, :);     % (#nodes_in_region) x 2
        Mk   = sum(w);          % total mass

        cx = (w' * xy_k(:,1)) / Mk;
        cy = (w' * xy_k(:,2)) / Mk;

        C(k,:) = [cx, cy];
    end
end
