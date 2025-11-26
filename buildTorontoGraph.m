function [G, XY] = buildTorontoGraph(shapefile)
%BUILDTORONTOGRAPH  Build a simple road graph from a Toronto centreline shapefile.
%
% Inputs
%   shapefile - path to .shp (e.g. 'street_data/toronto/centreline.shp')
%
% Outputs
%   G   - graph object, edges weighted by straight-line length (in coord units)
%   XY  - N x 2 node coordinates [lon, lat] (or [x, y] if projected)

    % 1) Read as geospatial table
    GT = readgeotable(shapefile);

    % 2) Convert to normal table with coordinate columns.
    %    For line data, Latitude/Longitude come out as *cell arrays*
    %    of numeric vectors (one vector of vertices per row).
    T = geotable2table(GT, ["Latitude" "Longitude"]);

    s = [];
    t = [];
    pts = [];

    % 3) Collect endpoints of each polyline
    for k = 1:height(T)
        lat = T.Latitude{k};
        lon = T.Longitude{k};

        if isempty(lat) || isempty(lon)
            continue;
        end

        % Remove NaN separators between parts
        lon = lon(~isnan(lon));
        lat = lat(~isnan(lat));

        if numel(lon) < 2
            continue;
        end

        p1 = [lon(1), lat(1)];
        p2 = [lon(end), lat(end)];

        pts = [pts; p1; p2];
    end

    % 4) Snap coordinates a bit so nearly-identical intersections merge
    snapTol = 1e-5;
    ptsSnapped = round(pts / snapTol) * snapTol;

    [XY, ~, idx] = unique(ptsSnapped, 'rows');  % XY is N x 2

    N = size(XY,1);
    nEdges = length(idx)/2;

    s = zeros(nEdges,1);
    t = zeros(nEdges,1);
    w = zeros(nEdges,1);

    % 5) Build edges + weights
    for k = 1:nEdges
        s(k) = idx(2*k - 1);
        t(k) = idx(2*k);

        dx = XY(t(k),1) - XY(s(k),1);
        dy = XY(t(k),2) - XY(s(k),2);

        w(k) = hypot(dx, dy);   % straight-line length in coord units
    end

    % 6) Undirected road graph
    G = graph(s, t, w);
end
