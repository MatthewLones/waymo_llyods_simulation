function D = demandMap(XY, t, modeFlag)
%DEMANDMAP  Simple dynamic demand map with slightly shifting hotspots.
%
%   D = demandMap(XY, t)          % default: Toronto density
%   D = demandMap(XY, t, 'city')
%   D = demandMap(XY, t, 'grid')

    if nargin < 3
        modeFlag = "city";
    end

    % Cache only the base densities
    persistent D_base_toronto D_base_grid ...
               init_toronto init_grid

    N = size(XY, 1);

    % ---- Static base density:
    switch lower(string(modeFlag))
        case "city"
            if isempty(init_toronto)
                [thisPath, ~, ~] = fileparts(mfilename('fullpath'));

                neighShp   = fullfile(thisPath, 'data', 'toronto', ...
                                       'neighbourhoods.shp');
                profileXls = fullfile(thisPath, 'data', 'toronto', ...
                                       'neighbourhood-profiles-2021.xlsx');

                D_base_toronto = torontoDensity(XY, neighShp, profileXls);
                D_base_toronto = D_base_toronto(:);   % force column
                s = sum(D_base_toronto);
                if s > 0
                    D_base_toronto = D_base_toronto / s;
                end
                init_toronto = true;
            end
            D_base = D_base_toronto;

        case "grid"
            if isempty(init_grid)
                x = XY(:,1);
                y = XY(:,2);

                xN = (x - min(x)) ./ max(eps, (max(x) - min(x)));
                yN = (y - min(y)) ./ max(eps, (max(y) - min(y)));

                cx = 0.5; cy = 0.5; sigma = 0.25;
                r2 = (xN - cx).^2 + (yN - cy).^2;
                D_base_grid = exp(-r2 ./ (2*sigma^2));

                s = sum(D_base_grid);
                if s > 0
                    D_base_grid = D_base_grid(:) / s;   % column + normalise
                else
                    D_base_grid = ones(N,1) / N;
                end
                init_grid = true;
            end
            D_base = D_base_grid;

        otherwise
            error('demandMap:UnknownMode', 'Unknown modeFlag "%s".', modeFlag);
    end

    D_base = D_base(:);          % make sure column, length N

    % -- Build moving Gaussian
    x = XY(:,1);
    y = XY(:,2);

    % Normalise to [0,1] for geometry
    xN = (x - min(x)) ./ max(eps, (max(x) - min(x)));
    yN = (y - min(y)) ./ max(eps, (max(y) - min(y)));

    % Two moving centres; t is in "hours" here
    sigma = 0.18;

    cx1 = 0.25 + 0.25 * sin(2*pi*t/6);         % moves left-right
    cy1 = 0.30 + 0.25 * cos(2*pi*t/7);         % moves up-down

    cx2 = 0.70 + 0.20 * sin(2*pi*t/5 + 1.0);
    cy2 = 0.65 + 0.20 * cos(2*pi*t/4 - 0.5);

    r2_1 = (xN - cx1).^2 + (yN - cy1).^2;
    r2_2 = (xN - cx2).^2 + (yN - cy2).^2;

    g1 = exp(-r2_1 ./ (2*sigma^2));
    g2 = exp(-r2_2 ./ (2*sigma^2));

    % Combine bumps, zero-mean, scale to |bump| <= 1
    bump = g1 + 0.8*g2;
    bump = bump - mean(bump);
    m = max(abs(bump));
    if m > 0
        bump = bump / m;
    end

    bump = bump(:);              % column, length N

    % -----
    epsPerturb = 0.5;            % 0.3 subtle, 0.5 obvious

    D = D_base .* (1 + epsPerturb * bump);

    D = max(D, 0);
    s = sum(D);
    if s > 0
        D = D / s;
    else
        D = D_base;              % fallback
    end
end