function test_setup()
    % Parameters
    n  = 4;
    Nx = 10;
    Ny = 8;
    h  = 1.0;

    % Build grid, density, and initial agents
    [D, P, X, Y] = setupLloyd(n, Nx, Ny, h);

    % Plot
    figure;
    plotState(D, P, X, Y);

    % Simple sanity checks in the command window
    fprintf('Total density mass ~ %.3f\n', sum(D(:)));
    fprintf('Number of agents placed: %d\n', nnz(P));
    fprintf('Agent IDs present: %s\n', mat2str(unique(P(P>0))'));
end

