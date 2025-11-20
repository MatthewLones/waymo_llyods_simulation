function plotter(G, D, XY, agentNodeOld, owner, C, agentNodeNew, t)
%PLOTDIAGNOSTICS  Show Lloyd iteration pieces in 3 separate windows.
%
% Fig 1: demand + current agents
% Fig 2: Voronoi ownership (which agent owns which node)
% Fig 3: movement: old agents, centroids, new agents, dotted paths
%
% Inputs
%   G             - graph object
%   D             - N x 1 node demand vector at time t
%   XY            - N x 2 node coordinates
%   agentNodeOld  - n x 1 vector of agent node indices at start of step
%   owner         - N x 1 vector, owner(v) = k (Voronoi region labels)
%   C             - n x 2 centroids; C(k,:) = [cx_k, cy_k]
%   agentNodeNew  - n x 1 vector of agent node indices after move
%   t             - current time step / iteration index

    n = numel(agentNodeOld);
    N = size(XY, 1);
    agentColors = lines(n);      % distinct RGB color per agent
    E = G.Edges.EndNodes;        % M x 2

    % Consistent axes ranges across all three windows
    xMin = min(XY(:,1)); xMax = max(XY(:,1));
    yMin = min(XY(:,2)); yMax = max(XY(:,2));

    %% --------- Figure 1: Demand + current agents -----------------------
    figure(1); clf;
    set(gcf, 'Name', 'Demand + agents');
    hold on;

    % Edges in light grey
    for e = 1:size(E,1)
        u = E(e,1); v = E(e,2);
        plot([XY(u,1), XY(v,1)], [XY(u,2), XY(v,2)], ...
             'Color', [0.8 0.8 0.8], 'LineWidth', 1.0);
    end

    % Nodes colored by demand
    scatter(XY(:,1), XY(:,2), 40, D, 'filled');
    colormap('hot');
    cb = colorbar;
    cb.Label.String = 'Demand';

    % Agents (current positions)
    for k = 1:n
        v = agentNodeOld(k);
        scatter(XY(v,1), XY(v,2), 80, agentColors(k,:), 'filled', ...
                'MarkerEdgeColor','k', 'LineWidth', 1.0);
    end

    axis equal; xlim([xMin-0.5, xMax+0.5]); ylim([yMin-0.5, yMax+0.5]);
    xlabel('x'); ylabel('y');
    title(sprintf('Demand + current agents (t = %d)', t));
    hold off;

    %% --------- Figure 2: Voronoi ownership -----------------------------
    figure(2); clf;
    set(gcf, 'Name', 'Voronoi ownership');
    hold on;

    % Edges in light grey
    for e = 1:size(E,1)
        u = E(e,1); v = E(e,2);
        plot([XY(u,1), XY(v,1)], [XY(u,2), XY(v,2)], ...
             'Color', [0.9 0.9 0.9], 'LineWidth', 1.0);
    end

    % Each node colored by its owning agent
    nodeColors = zeros(N, 3);
    for v = 1:N
        k = owner(v);                % 1..n
        nodeColors(v, :) = agentColors(k,:);
    end
    scatter(XY(:,1), XY(:,2), 40, nodeColors, 'filled');

    % Agents highlighted
    for k = 1:n
        v = agentNodeOld(k);
        scatter(XY(v,1), XY(v,2), 80, agentColors(k,:), 'filled', ...
                'MarkerEdgeColor','k', 'LineWidth', 1.0);
    end

    axis equal; xlim([xMin-0.5, xMax+0.5]); ylim([yMin-0.5, yMax+0.5]);
    xlabel('x'); ylabel('y');
    title(sprintf('Voronoi ownership (t = %d)', t));
    hold off;

    %% --------- Figure 3: Movement: old → centroid → new ----------------
    figure(3); clf;
    set(gcf, 'Name', 'Movement step');
    hold on;

    % Background grid lightly
    for e = 1:size(E,1)
        u = E(e,1); v = E(e,2);
        plot([XY(u,1), XY(v,1)], [XY(u,2), XY(v,2)], ...
             'Color', [0.9 0.9 0.9], 'LineWidth', 1.0);
    end

    % Optional faint nodes
    scatter(XY(:,1), XY(:,2), 10, [0.85 0.85 0.85], 'filled');

    % For each agent: old pos, centroid, new pos, dotted line old→new
    for k = 1:n
        col = agentColors(k,:);

        oldNode = agentNodeOld(k);
        newNode = agentNodeNew(k);
        oldPos  = XY(oldNode, :);
        newPos  = XY(newNode, :);
        centPos = C(k, :);

        % Dotted line from old to new
        plot([oldPos(1), newPos(1)], [oldPos(2), newPos(2)], ...
             '--', 'Color', col, 'LineWidth', 1.0);

        % Old position: filled circle
        scatter(oldPos(1), oldPos(2), 70, col, 'filled', ...
                'MarkerEdgeColor','k', 'LineWidth', 1.0);

        % New position: open circle
        scatter(newPos(1), newPos(2), 70, col, ...
                'MarkerEdgeColor','k', 'LineWidth', 1.0);

        % Centroid: x-marker
        scatter(centPos(1), centPos(2), 70, col, 'x', 'LineWidth', 1.5);
    end

    axis equal; xlim([xMin-0.5, xMax+0.5]); ylim([yMin-0.5, yMax+0.5]);
    xlabel('x'); ylabel('y');
    title(sprintf('Movement towards centroids (t = %d)', t));
    hold off;

    drawnow;
end
