function D = demandMap(X, Y)
%DEMANDMAP  Example static demand field on the grid.
%
% Inputs
%   X, Y - Ny x Nx coordinate matrices
%
% Output
%   D    - Ny x Nx density matrix (nonnegative)

    % You can tweak these to taste. This is just a quick example:
    % - one strong "downtown" blob
    % - one weaker "neighbourhood" blob

    % Center 1 (e.g. downtown)
    mu1 = [mean(X(:)), mean(Y(:))];   % roughly center of the map
    sigma1 = max(X(:)) / 4;          % spread

    % Center 2 (e.g. entertainment district)
    mu2 = [0.25*max(X(:)), 0.7*max(Y(:))];
    sigma2 = max(X(:)) / 6;

    % Compute squared distances to the centers
    r1sq = (X - mu1(1)).^2 + (Y - mu1(2)).^2;
    r2sq = (X - mu2(1)).^2 + (Y - mu2(2)).^2;

    % Gaussian bumps + small baseline everywhere
    D = 0.1 ...
        + 1.0 * exp(-r1sq / (2*sigma1^2)) ...
        + 0.6 * exp(-r2sq / (2*sigma2^2));

    % Optional: normalize so that total mass is 1 if you care
    % D = D / sum(D(:));
end
