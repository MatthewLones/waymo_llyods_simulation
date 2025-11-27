function D_base = torontoDensity(XY, neighShapefile, profileCsv)
%TORONTODENSITY  Static node demand based on neighbourhood *density*.
%
% Inputs
%   XY             - N x 2 node coordinates [lon, lat]
%   neighShapefile - path to Toronto neighbourhood polygons (.shp)
%   profileCsv     - path to "neighbourhood-profiles-2021.csv" (or .xlsx)
%
% Output
%   D_base         - N x 1 base demand (proportional to population density)

    % ===============================================================
    % 1) Load neighbourhood polygons (struct array)
    % ===============================================================
    S = shaperead(neighShapefile);   % needs Mapping TB

    if isempty(S)
        error('torontoDensity:EmptyShape', ...
              'Shapefile "%s" returned no features.', neighShapefile);
    end

    nameField = pickNameFieldFromStruct(S);  % choose area-name field

    % Cleaned keys for shapefile neighbourhood names
    shpNamesRaw = string({S.(nameField)});   % 1 x nNeigh cell/char -> string
    shpKeys     = normalizeKey(shpNamesRaw); % same length

    % ===============================================================
    % 2) Load profiles CSV and extract population row
    %    - Col 1: row labels (descriptions)
    %    - Col 2..end: one column per neighbourhood
    % ===============================================================
    T = readtable(profileCsv, 'VariableNamingRule','preserve');

    varNames = string(T.Properties.VariableNames);
    nVars    = numel(varNames);

    % Treat the first column as the row-label column
    rowLabelVar = varNames(1);
    rowLabels   = string(T.(rowLabelVar));

    % Find row with total population per neighbourhood
    popRowIdx = find(startsWith(rowLabels, ...
        "Total - Age groups of the population", 'IgnoreCase', true), 1);

    if isempty(popRowIdx)
        error('torontoDensity:NoPopRow', ...
             ['Could not find "Total - Age groups of the population..." ', ...
              'row in profiles CSV.']);
    end

    % Build map: cleanedNeighbourhoodKey -> population
    popMap = containers.Map('KeyType','char','ValueType','double');

    for j = 2:nVars   % skip row-label column
        colName = varNames(j);            % e.g., "West Humber-Clairville"
        key     = char(normalizeKey(colName));

        val = T{popRowIdx, j};
        if isnumeric(val) && ~isnan(val)
            popMap(key) = double(val);
        end
    end

    % ===============================================================
    % 3) Attach population and area to each polygon
    % ===============================================================
    nNeigh   = numel(S);
    polys    = polyshape.empty(nNeigh, 0);
    popNeigh = zeros(nNeigh, 1);
    polyArea = zeros(nNeigh, 1);   % NEW: polygon areas

    for k = 1:nNeigh
        % -------- Geometry -> polyshape --------
        if isfield(S, 'X') && isfield(S, 'Y')
            lon = S(k).X;
            lat = S(k).Y;
        elseif isfield(S, 'Lon') && isfield(S, 'Lat')
            lon = S(k).Lon;
            lat = S(k).Lat;
        else
            error('torontoDensity:NoXY', ...
                  'Shape struct has no X/Y or Lon/Lat fields.');
        end

        % Remove NaNs before building a polyshape
        mask = ~(isnan(lon) | isnan(lat));
        lon  = lon(mask);
        lat  = lat(mask);

        polys(k)    = polyshape(lon, lat, 'Simplify', false);
        polyArea(k) = area(polys(k));     % area in coordinate units^2

        % -------- Name -> key -> population --------
        key = char(shpKeys(k));
        if isKey(popMap, key)
            popNeigh(k) = popMap(key);
        else
            popNeigh(k) = 0;   % will fill later
        end
    end

    % Fill any zero-pop neighbourhoods with mean of non-zero pops
    missing = (popNeigh == 0);
    if any(~missing)
        popNeigh(missing) = mean(popNeigh(~missing));
    else
        warning('torontoDensity:AllZeroPop', ...
                'All neighbourhood populations are zero; check CSV mapping.');
    end

    % ===============================================================
    % 4) Paint population density onto XY nodes
    % ===============================================================
    N      = size(XY, 1);
    D_base = zeros(N, 1);

    for k = 1:nNeigh
        if popNeigh(k) <= 0, continue; end
        if polyArea(k) <= 0, continue; end

        in = isinterior(polys(k), XY(:,1), XY(:,2));  % logical N x 1
        if ~any(in), continue; end

        % Population density for this neighbourhood:
        % people per (coordinate-unit)^2
        dens_k = popNeigh(k) / polyArea(k);

        % Assign same density to all nodes in this neighbourhood
        D_base(in) = dens_k;
    end

    % Nodes not in any neighbourhood get a tiny baseline
    zeroNodes = (D_base == 0);
    if any(zeroNodes)
        D_base(zeroNodes) = 0.1 * mean(D_base(~zeroNodes));
    end

    % ===============================================================
    % 5) Normalise for use as a demand distribution
    % ===============================================================
    s = sum(D_base);
    if s > 0
        D_base = D_base / s;   % sum(D_base) = 1
    else
        warning('torontoDensity:ZeroMass', ...
                'Total mass is zero; using uniform density.');
        D_base = ones(N,1) / N;
    end
end

% =====================================================================
function nameField = pickNameFieldFromStruct(S)
% Pick a reasonable "name" field from the neighbourhood struct array.

    vars = string(fieldnames(S));

    % Toronto-specific shortcut: AREA_NA7 is the official neighbourhood name.
    if any(strcmpi(vars, "AREA_NA7"))
        nameField = "AREA_NA7";
        return;
    end

    % Otherwise, heuristic: text-like field that looks name-ish
    scores = zeros(size(vars));

    for i = 1:numel(vars)
        nm = vars(i);

        % Gather values across all features
        vals = {S.(nm)};
        s    = lower(string(vals));

        % If conversion gives all missing, skip
        if all(ismissing(s))
            continue;
        end

        score = 0;
        if contains(lower(nm), "name"), score = score + 3; end
        if contains(lower(nm), "area"), score = score + 1; end

        % If many values contain spaces, likely a human-readable name
        if mean(contains(s, " ")) > 0.3
            score = score + 2;
        end

        lenVals = strlength(s);
        lenVals = lenVals(~isnan(lenVals));
        if ~isempty(lenVals) && median(lenVals) < 40
            score = score + 1;
        end

        scores(i) = score;
    end

    [mx, idx] = max(scores);
    if mx == 0
        error('torontoDensity:NoNameField', ...
              'Could not find a text-like name/ID field in neighbourhood shapefile.');
    end

    nameField = vars(idx);
end

% =====================================================================
function key = normalizeKey(strIn)
% Normalise a name to a simple key:
%   - lower case
%   - remove spaces, underscores, hyphens and punctuation

    s = lower(string(strIn));

    % Replace underscores and hyphens with spaces first
    s = replace(s, ["_", "-", "’", "'", "’"], " ");

    % Keep only letters and digits
    s = regexprep(s, '[^a-z0-9]', '');

    key = s;
end