function D = demandMap(XY, t)
%DEMANDMAP  Time-varying demand based on neighbourhood population.

    persistent D_base initialized

    if isempty(initialized)
        [thisPath, ~, ~] = fileparts(mfilename('fullpath'));

        neighShp   = fullfile(thisPath, 'data', 'toronto', 'neighbourhoods.shp');
        profileCsv = fullfile(thisPath, 'data', 'toronto', 'neighbourhood-profiles-2021.csv');

        D_base = buildBaseDemand_population(XY, neighShp, profileCsv);
        initialized = true;
    end

    % ---- simple time-of-day modulation (t in "hours") ----
    hour = mod(t, 24);

    % busy daytime around 13:00
    dayFactor    = 0.4 + 0.6 * max(0, cos((hour - 13)/12 * pi));
    % evening bump around 21:00
    eveningBump  = 0.2 * exp(-0.5 * ((hour - 21)/2).^2);

    temporal = 0.5 + 0.5*dayFactor + eveningBump;   % ~[0.5, 1.5]

    D = D_base * temporal;

    % If you want strict total mass conservation:
    % D = D / sum(D);
end


