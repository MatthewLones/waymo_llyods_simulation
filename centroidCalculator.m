function C = centroidCalculator(R, D, X, Y, n)
% R - Ny x Nx Voronoi label matrix
% D - Ny x Nx density matrix
% X - Ny x Nx x-coordinate matrix
% Y - Ny x Nx y-coordinate matrix
% n - number of agents
%
% C - n x 2 matrix; C(k,:) = [cx_k, cy_k] centroid of region k
