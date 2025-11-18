function plotState(D, P, X, Y, iter)
%PLOTSTATE  Visualize density and agent locations on the grid.
%
% Inputs
%   D    - Ny x Nx density matrix
%   P    - Ny x Nx agent-ID matrix
%   X, Y - Ny x Nx coordinate matrices
%   iter - (optional) iteration counter for the title

    if nargin < 5
        iter = [];
    end

    % Get coordinate axes from X,Y
    xCoords = X(1, :);   % x of each column
    yCoords = Y(:, 1);   % y of each row

    clf;                 % clear current figure
    hold on;

    % Plot density as a colored image
    % imagesc(x,y,C) uses xCoords, yCoords as the axes
    imagesc(xCoords, yCoords, D);
    set(gca, 'YDir', 'normal');   % so increasing row index means going up
    axis equal tight;
    colormap('hot');
    colorbar;
    xlabel('x');
    ylabel('y');

    % Overlay agent positions
    [rows, cols, agentIds] = find(P);   % nonzero entries
    if ~isempty(agentIds)
        xCar = X(sub2ind(size(X), rows, cols));
        yCar = Y(sub2ind(size(Y), rows, cols));

        % simple scatter plot of agents
        scatter(xCar, yCar, 80, 'c', 'filled', ...
            'MarkerEdgeColor','k', 'LineWidth', 1.5);
    end

    % Title with iteration count if provided
    if ~isempty(iter)
        title(sprintf('Lloyd iteration %d', iter));
    else
        title('Initial state');
    end

    hold off;
    drawnow;
end
