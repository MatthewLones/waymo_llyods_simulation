function [G, XY] = buildGridGraph(Nx, Ny, h)
%BUILDGRIDGRAPH  Construct a simple Ny-by-Nx grid as a MATLAB graph.
%
% Nodes are intersections on an axis-aligned grid.
% Edges connect 4-neighbours (up/down/left/right) with constant weight h.
%
% Inputs
%   Nx  - # of intersections along x (columns)
%   Ny  - # of intersections along y (rows)
%   h   - spacing between intersections
%
% Outputs
%   G   - graph with N = Nx*Ny nodes and constant edge weights = h
%   XY  - N x 2 matrix; XY(v,:) = [x_v, y_v] coordinates of node v

    % Grid coordinates
    [X, Y] = meshgrid(0:h:(Nx-1)*h, 0:h:(Ny-1)*h);  % Ny x Nx
    XY = [X(:), Y(:)];                              % N x 2

    % Build 4-neighbour edges
    s = [];
    t = [];
    w = [];

    for i = 1:Ny
        for j = 1:Nx
            u = sub2ind([Ny, Nx], i, j);

            % Right neighbour
            if j < Nx
                v = sub2ind([Ny, Nx], i, j+1);
                s(end+1,1) = u;
                t(end+1,1) = v;
                w(end+1,1) = h;
            end

            % Down neighbour
            if i < Ny
                v = sub2ind([Ny, Nx], i+1, j);
                s(end+1,1) = u;
                t(end+1,1) = v;
                w(end+1,1) = h;
            end
        end
    end

    G = graph(s, t, w);   % undirected graph with constant weights
end
