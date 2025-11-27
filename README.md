# Llyods MATLAB Simulation for APSC 200
Uses llyods algorithm to distrbute "idle taxis" (agents) across a node-graph object to minimize user wait time.

Rough code outline (in order of function calls):
* `initMap`: initializes a MATLAB graph object along with (x,y) coords for each node (nodes represent street intersections; we assume taxis are only hailed at intersections). It either generates a grid or uses city of Toronto shapefile data (see data/README.md) to generate the map. `initMap` then assigns n agents randomly to the nodes in the graph. 
* `demandMap`: assignes a density value to each node. Either generates one for the grid map or uses city of toronto neighbourhood population data to generate one for the toronto map. 
* `voronoiRegions`: assignes each node to the closest agent (poor efficiency  - should deffinitley speed up at some point)  
* `centroidCalculator`: sums up the mass of each voroni region and computes their centroids (in R2)
* `moveAgents`: moves agents to the closest node to each centroid
* `plotter`: plots three graphs showing density, voroni assignments, and agents' next move
* `main`: runs everything, exports a .mp4 of the rendered simulation


Fun improvements: use traffic data to assign weightings to each edge, turn into actual simulation with taxis picking up users, taking them to destinations, and idle taxis redistribution around where active cars will be

Screenshots of rendered vids:
