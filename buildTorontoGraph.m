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

    % 1b) Filter to road features only using FEATURE35
    %     Toronto Centreline feature codes:
    %       201100–2017xx  = streets / highways / arterials / locals / laneways
    %       202xxx–208xxx  = non-road (rail, rivers, boundaries, etc.)
    codes = GT.FEATURE35;
    roadMin = 201100;
    roadMax = 201799;
    isRoad  = (codes >= roadMin) & (codes <= roadMax);

    GT = GT(isRoad, :);

    if height(GT) == 0
        error('buildTorontoGraph:NoRoadsAfterFilter', ...
              'No road segments remained after FEATURE35 filtering.');
    end

    % 2) Convert to normal table with coordinate columns.
    %    For line data, Latitude/Longitude come out as *cell arrays*
    %    of numeric vectors (one vector of vertices per row).
    T = geotable2table(GT, ["Latitude" "Longitude"]);

    pts = [];

    % 3) Collect endpoints of each polyline (road centreline)
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

        p1 = [lon(1),  lat(1) ];
        p2 = [lon(end), lat(end)];

        pts = [pts; p1; p2];
    end

    if isempty(pts)
        error('buildTorontoGraph:NoPoints', ...
              'No segment endpoints found after processing road centrelines.');
    end

    % 4) Snap coordinates a bit so nearly-identical intersections merge
    snapTol    = 1e-5;
    ptsSnapped = round(pts / snapTol) * snapTol;

    % XY: unique node coordinates
    % idx: for each row in ptsSnapped, index into XY
    [XY, ~, idx] = unique(ptsSnapped, 'rows');  % XY is N x 2

    N      = size(XY,1);
    nEdges = length(idx) / 2;

    s = zeros(nEdges,1);
    t = zeros(nEdges,1);
    w = zeros(nEdges,1);

    % 5) Build edges + weights
    % Each original road segment contributes exactly one edge
    % between its two snapped endpoints.
    for k = 1:nEdges
        s(k) = idx(2*k - 1);   % start node index
        t(k) = idx(2*k);       % end node index

        dx = XY(t(k),1) - XY(s(k),1);
        dy = XY(t(k),2) - XY(s(k),2);

        w(k) = hypot(dx, dy);  % straight-line length in coord units
    end

    % 6) Undirected road graph
    G = graph(s, t, w);
end