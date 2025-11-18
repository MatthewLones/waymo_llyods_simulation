function [D, P, X, Y] = setupLloyd(n, Nx, Ny, h)
%SETUPLLOYD  Build a rectangular grid, a density field, and initial agents.
%
% Inputs
%   n   - number of agents (cars)
%   Nx  - number of intersections along x (columns)
%   Ny  - number of intersections along y (rows)
%   h   - spacing between intersections (in whatever units)
%
% Outputs
%   D   - Ny x Nx matrix, D(i,j) = density at node (i,j)
%   P   - Ny x Nx matrix, P(i,j) = 0 if empty, k if agent k is at (i,j)
%   X   - Ny x Nx matrix of x-coordinates of each node
%   Y   - Ny x Nx matrix of y-coordinates of each node

    % ---- 1) Build coordinate grids --------------------------------------
    % xCoords is a row vector of x positions of columns
    % yCoords is a column vector of y positions of rows
    xCoords = (0:Nx-1) * h;
    yCoords = (0:Ny-1) * h;
    [X, Y] = meshgrid(xCoords, yCoords);   % X,Y are Ny x Nx

    % ---- 2) Build density field D ---------------------------------------
    % For now we call a helper that takes coordinates and returns D.
    % This is where we can later add time-dependence: demandMap(X,Y,t).
    D = demandMap(X, Y);

    % ---- 3) Place agents randomly on distinct nodes ---------------------
    numCells = Ny * Nx;
    if n > numCells
        error('Number of agents n=%d is larger than number of grid cells=%d', ...
              n, numCells);
    end

    % P(i,j) = 0 means no agent; P(i,j) = k means agent k is there
    P = zeros(Ny, Nx);

    % Choose n distinct cells uniformly at random
    % linIdx(k) is a linear index into the Ny-by-Nx grid
    linIdx = randperm(numCells, n);

    for k = 1:n
        [i, j] = ind2sub([Ny, Nx], linIdx(k));
        P(i, j) = k;
    end
end
