function [G, XY] = buildGridGraph(Nx, Ny, h)
%BUILDGRIDGRAPH  Construct a Ny-by-Nx grid as a MATLAB graph.
%
% Nodes are intersections; edges connect 4-neighbours.
%
% Inputs
%   Nx  - # of nodes along x (columns)
%   Ny  - # of nodes along y (rows)
%   h   - spacing between intersections
%
% Outputs
%   G   - graph object with N = Nx*Ny nodes
%   XY  - N x 2 matrix; XY(v,:) = [x_v, y_v] coordinates of node v

    N = Nx * Ny;
    XY = zeros(N, 2);

    % Map (i,j) -> node index v
    % v = sub2ind([Ny, Nx], i, j)
    for i = 1:Ny
        for j = 1:Nx
            v = sub2ind([Ny, Nx], i, j);
            x = (j - 1) * h;
            y = (i - 1) * h;
            XY(v, :) = [x, y];
        end
    end

    % Build edge lists for 4-neighbour grid (right and down)
    s = [];
    t = [];
    w = [];

    for i = 1:Ny
        for j = 1:Nx
            v = sub2ind([Ny, Nx], i, j);

            % Right neighbour (i, j+1)
            if j < Nx
                vRight = sub2ind([Ny, Nx], i, j+1);
                s(end+1,1) = v;
                t(end+1,1) = vRight;
                w(end+1,1) = h;
            end

            % Down neighbour (i+1, j)
            if i < Ny
                vDown = sub2ind([Ny, Nx], i+1, j);
                s(end+1,1) = v;
                t(end+1,1) = vDown;
                w(end+1,1) = h;
            end
        end
    end

    % Undirected graph; graph(s,t,w) treats edges as undirected
    G = graph(s, t, w);
end
