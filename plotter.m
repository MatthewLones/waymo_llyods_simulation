function frame = plotter(G, D, XY, agentNodeOld, owner, C, agentNodeNew, t)
% Draw 3  panels in one invisible figure & return frame.

    % Unpack
    n = numel(agentNodeOld);
    N = size(XY,1);
    agentColors = lines(n);

    % Axes limits
    xMin = min(XY(:,1)); 
    xMax = max(XY(:,1));
    yMin = min(XY(:,2)); 
    yMax = max(XY(:,2));

    % Precompute edge geometry once (persistent)
    persistent fig tl xe ye ax1 ax2 ax3
    if isempty(fig) || ~isvalid(fig)
        fig = figure('Visible','off', ...
             'Position',[100 100 1500 800], ...
             'Color','w');     % white background

        tl = tiledlayout(fig, 1, 3, ...
                         'TileSpacing','compact', ...
                         'Padding','compact');

        ax1 = nexttile(tl);  
        ax2 = nexttile(tl);
        ax3 = nexttile(tl);

        % Precompute edges
        E = G.Edges.EndNodes;
        M = size(E,1);

        X1 = XY(E(:,1),1);
        X2 = XY(E(:,2),1);
        Y1 = XY(E(:,1),2);
        Y2 = XY(E(:,2),2);

        xe = [X1.'; X2.'; nan(1,M)];
        ye = [Y1.'; Y2.'; nan(1,M)];
        xe = xe(:);
        ye = ye(:);
    end

    %% PANEL 1: Demand
    cla(ax1); hold(ax1,'on');
    plot(ax1, xe, ye, 'Color',[0.8 0.8 0.8], 'LineWidth',0.5);
    scatter(ax1, XY(:,1), XY(:,2), 20, D, 'filled');
    colormap(ax1,'hot');
    cb = colorbar(ax1); cb.Label.String = 'Demand';
    for k = 1:n
        v = agentNodeOld(k);
        scatter(ax1, XY(v,1), XY(v,2), 40, agentColors(k,:), 'filled', ...
            'MarkerEdgeColor','k','LineWidth',0.8);
    end
    axis(ax1,'equal'); xlim(ax1,[xMin xMax]); ylim(ax1,[yMin yMax]);
    title(ax1, sprintf('Demand + agents (t=%d)',t));
    hold(ax1,'off');

    %% PANEL 2: Ownership
    cla(ax2); hold(ax2,'on');
    plot(ax2, xe, ye, 'Color',[0.9 0.9 0.9], 'LineWidth',0.5);
    nodeColors = agentColors(owner,:);
    scatter(ax2, XY(:,1), XY(:,2), 20, nodeColors, 'filled');
    for k = 1:n
        v = agentNodeOld(k);
        scatter(ax2, XY(v,1), XY(v,2), 40, agentColors(k,:), 'filled', ...
            'MarkerEdgeColor','k','LineWidth',0.8);
    end
    axis(ax2,'equal'); xlim(ax2,[xMin xMax]); ylim(ax2,[yMin yMax]);
    title(ax2, sprintf('Ownership (t=%d)',t));
    hold(ax2,'off');

    %% PANEL 3: Movement
    cla(ax3); hold(ax3,'on');
    plot(ax3, xe, ye, 'Color',[0.9 0.9 0.9], 'LineWidth',0.5);
    scatter(ax3, XY(:,1), XY(:,2), 8, [0.85 0.85 0.85], 'filled');

    for k = 1:n
        col = agentColors(k,:);

        oldPos  = XY(agentNodeOld(k),:);
        newPos  = XY(agentNodeNew(k),:);
        centPos = C(k,:);

        plot(ax3, [oldPos(1) newPos(1)], [oldPos(2) newPos(2)], '--', ...
             'Color', col, 'LineWidth', 1.0);

        scatter(ax3, oldPos(1), oldPos(2), 50, col, 'filled', ...
                'MarkerEdgeColor','k', 'LineWidth', 0.8);
        scatter(ax3, newPos(1), newPos(2), 50, col, ...
                'MarkerEdgeColor','k', 'LineWidth', 0.8);
        scatter(ax3, centPos(1), centPos(2), 60, col, 'x', 'LineWidth', 1.2);
    end

    axis(ax3,'equal'); xlim(ax3,[xMin xMax]); ylim(ax3,[yMin yMax]);
    title(ax3, sprintf('Movement (t=%d)',t));
    hold(ax3,'off');

    %% Capture & return frame using exportgraphics (no screen tearing)
    tmpFile = [tempname, '.png'];              % temporary image file
    exportgraphics(fig, tmpFile, 'Resolution', 150);  % render off-screen
    img = imread(tmpFile);                     % read RGB image
    delete(tmpFile);                           % clean up

    frame = im2frame(img);
end
