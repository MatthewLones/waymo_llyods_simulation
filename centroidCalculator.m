function C = centroidCalculator(R, D, X, Y, n)
%CENTROIDCALCULATOR  Density-weighted centroids for each Voronoi region.
%
% Inputs
%   R - Ny x Nx matrix of region labels, R(i,j) = k
%   D - Ny x Nx density matrix
%   X - Ny x Nx x-coordinate matrix
%   Y - Ny x Nx y-coordinate matrix
%   n - number of agents
%
% Output
%   C - n x 2 matrix of centroids; C(k,:) = [cx_k, cy_k]

    C = zeros(n, 2);

    for k = 1:n
        mask = (R == k);        % logical Ny x Nx
        w = D(mask);            % density weights in region k

        if isempty(w)
            % Region has no cells (should not happen if grid is full).
            % As a fallback, return NaN and handle in moveAgents if needed.
            C(k,:) = [NaN, NaN];
            continue;
        end

        % Extract coordinates in region k
        xk = X(mask);
        yk = Y(mask);

        Mk = sum(w);            % total mass in region k

        % If density is strictly positive everywhere (as in our demandMap),
        % Mk > 0 and this is safe.
        cx = sum(w .* xk) / Mk;
        cy = sum(w .* yk) / Mk;

        C(k,:) = [cx, cy];
    end
end
