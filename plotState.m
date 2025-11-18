function plotState(G, D, XY, agentNode, iter)
%PLOTSTATE  Visualize graph, demand, agents, and traffic-aware edges.
%
% Inputs
%   G         - graph object (uses G.Edges.Weight as current traffic)
%   D         - N x 1 node demand vector
%   XY        - N x 2 node coordinates
%   agentNode - n x 1 vector of agent node indices
%   iter      - iteration/time index (for title)

    clf;
    hold on;

    E = G.Edges.EndNodes;   % M x 2, each row [u v]
    M = size(E,1);

    % --- 1) Edge colors based on current weights -------------------------
    if ismember('Weight', G.Edges.Properties.VariableNames)
        w = G.Edges.Weight;
    else
        % Fallback: use base lengths if no dynamic weights yet
        w = G.Edges.BaseLen;
    end

    wMin = min(w);
    wMax = max(w);
    if wMax > wMin
        wNorm = (w - wMin) / (wMax - wMin);   % scale to [0,1]
    else
        wNorm = zeros(M,1);
    end

    % Colormap for edges: blue (fast) → red (slow)
    edgeMap = jet(256);     % we don't call colormap() here; we just sample

    for e = 1:M
        u = E(e,1);
        v = E(e,2);

        % Map wNorm(e) ∈ [0,1] to a row of edgeMap
        idx = 1 + floor(wNorm(e) * (size(edgeMap,1)-1));
        idx = max(1, min(size(edgeMap,1), idx));
        col = edgeMap(idx, :);

        plot([XY(u,1), XY(v,1)], [XY(u,2), XY(v,2)], ...
             'Color', col, 'LineWidth', 1.5);
    end

    % --- 2) Nodes colored by demand --------------------------------------
    scatter(XY(:,1), XY(:,2), 30, D, 'filled');
    colormap('hot');   % this controls node colors + colorbar
    colorbar;
    axis equal tight;
    xlabel('x');
    ylabel('y');

    % --- 3) Overlay agents -----------------------------------------------
    if ~isempty(agentNode)
        xCar = XY(agentNode, 1);
        yCar = XY(agentNode, 2);
        scatter(xCar, yCar, 80, 'c', 'filled', ...
                'MarkerEdgeColor','k', 'LineWidth', 1.5);
    end

    if nargin >= 5
        title(sprintf('Lloyd on city graph – t = %d', iter));
    else
        title('Lloyd on city graph');
    end

    hold off;
    drawnow;
end
