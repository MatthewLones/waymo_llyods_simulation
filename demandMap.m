function D = demandMap(XY, t, modeFlag)
%DEMANDMAP  Time-varying demand based on neighbourhood population or grid.
%
%   D = demandMap(XY, t)                      % default: Toronto density
%   D = demandMap(XY, t, 'build toronto density')
%   D = demandMap(XY, t, 'build grid density')

    if nargin < 3
        modeFlag = "city";   % default behaviour
    end

    % Separate cached bases for each mode
    persistent D_base_toronto D_base_grid ...
               initialized_toronto initialized_grid

    % ---------- choose base spatial density ----------
    switch lower(string(modeFlag))
        case "city"
            if isempty(initialized_toronto)
                [thisPath, ~, ~] = fileparts(mfilename('fullpath'));

                neighShp   = fullfile(thisPath, 'data', 'toronto', ...
                                       'neighbourhoods.shp');
                profileXls = fullfile(thisPath, 'data', 'toronto', ...
                                       'neighbourhood-profiles-2021.xlsx');

                D_base_toronto = torontoDensity(XY, ...
                                        neighShp, profileXls);
                D_base_toronto = D_base_toronto(:);   % make sure column
                initialized_toronto = true;
            end
            D_base = D_base_toronto;

        case "grid"
            if isempty(initialized_grid)
                % Simple Gaussian over the XY grid

                x = XY(:,1);
                y = XY(:,2);

                % Normalise coords to roughly [0,1] so sigma is meaningful
                xN = (x - min(x)) ./ max(eps, (max(x) - min(x)));
                yN = (y - min(y)) ./ max(eps, (max(y) - min(y)));

                % Centre of Gaussian and width (tweak if you like)
                cx = 0.5;
                cy = 0.5;
                sigma = 0.20;

                r2 = (xN - cx).^2 + (yN - cy).^2;
                D_base_grid = exp(-r2 ./ (2*sigma^2));

                % Optional: normalise total mass
                D_base_grid = D_base_grid / sum(D_base_grid);

                initialized_grid = true;
            end
            D_base = D_base_grid;

        otherwise
            error('demandMap:UnknownMode', ...
                  'Unknown modeFlag "%s".', modeFlag);
    end

    % ---------- time-of-day modulation (t in "hours") ----------
    hour = mod(t, 24);

    % busy daytime around 13:00
    dayFactor   = 0.4 + 0.6 * max(0, cos((hour - 13)/12 * pi));
    % evening bump around 21:00
    eveningBump = 0.2 * exp(-0.5 * ((hour - 21)/2).^2);

    temporal = 0.5 + 0.5*dayFactor + eveningBump;   % ~[0.5, 1.5]

    % ---------- final demand vector ----------
    D = D_base .* temporal;     % elementwise scaling

    % If you want strict total mass conservation:
    % D = D / sum(D);
end