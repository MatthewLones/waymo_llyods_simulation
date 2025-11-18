function plotState(G, D, XY, agentNode, iter)
%PLOTSTATE  Visualize graph, demand, and agents.
%
% Inputs
%   G         - graph object
%   D         - N x 1 density vector
%   XY        - N x 2 node coordinates
%   agentNode - n x 1 vector of agent node indices
%   iter      - iteration count (for title)

    clf;
    hold on;

    % 1) Plot edges (roads)
    E = G.Edges.EndNodes;   % M x 2, each row [u v]
    for e = 1:size(E,1)
        u = E(e,1);
        v = E(e,2);
        plot([XY(u,1), XY(v,1)], [XY(u,2), XY(v,2)], 'Color', [0.5 0.5 0.5]);
    end

    % 2) Plot nodes colored by demand
    scatter(XY(:,1), XY(:,2), 30, D, 'filled');   % node heatmap
    colormap('hot');
    colorbar;
    axis equal tight;
    xlabel('x');
    ylabel('y');

    % 3) Overlay agents
    if ~isempty(agentNode)
        xCar = XY(agentNode, 1);
        yCar = XY(agentNode, 2);
        scatter(xCar, yCar, 80, 'c', 'filled', ...
                'MarkerEdgeColor','k', 'LineWidth', 1.5);
    end

    if nargin >= 5
        title(sprintf('Lloyd on graph - iteration %d', iter));
    else
        title('Lloyd on graph - initial state');
    end

    hold off;
    drawnow;
end
