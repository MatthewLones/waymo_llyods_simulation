function [D, P, X, Y] = setupLloyd(n, Nx, Ny, h)
% n  - number of agents
% Nx - # intersections along x (columns)
% Ny - # intersections along y (rows)
% h  - spacing between intersections
%
% D  - Ny x Nx density matrix
% P  - Ny x Nx agent-ID matrix (0 if empty, k if agent k)
% X  - Ny x Nx matrix of x-coordinates
% Y  - Ny x Nx matrix of y-coordinates
