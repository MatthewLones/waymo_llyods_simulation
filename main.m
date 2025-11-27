function main()
    n   = 10;      % number of agents
    Nx  = 20;     % passed through to setupLloyd if needed; x and y dim for grid graph
    Ny  = 16;
    h   = 1.0;
    T   = 15;     % num of iterations

    videoFile  = 'llyod_sim.mp4';
    frameRate  = 2;    % playback fps


    % pass either "city" or "grid"
    [G, XY, agentNode] = initMap(n, Nx, Ny, h, "city");

    frames = {};   % cell array of frames

    % ---- Time loop:
    for t = 0:T
        fprintf('Iteration %d / %d\n', t, T);
        iterTimer = tic;

        % 1 Current demand
        D = demandMap(XY, t, "city");

        % 2 Lloyd one step update
        owner        = voronoiRegions(G, agentNode, n);
        C            = centroidCalculator(owner, D, XY, n);
        agentNodeNew = moveAgents(C, XY, n);

        % 3 Draw into invisible figure and grab frame
        frames{end+1} = plotter(G, D, XY, agentNode, owner, C, ...
                                     agentNodeNew, t);

        % 4 prep next step
        agentNode = agentNodeNew;

        fprintf('  iteration time: %.2f s\n', toc(iterTimer));
    end

    % ---- Save the video:
    v = VideoWriter(videoFile, 'MPEG-4');

    v.FrameRate = frameRate;

    open(v);

    % Use the first frame to define the size
    [im0, ~] = frame2im(frames{1});
    [H, W, ~] = size(im0);

    for k = 1:numel(frames)
        [im, ~] = frame2im(frames{k});   % struct -> RGB image

        % If this frames size is off by a pixel or two, fix it:
        if size(im,1) ~= H || size(im,2) ~= W
            im = imresize(im, [H, W]);    % pad/scale to match
        end

        writeVideo(v, im);
    end

    close(v);
    fprintf('Saved video to %s (size %d x %d, %.1f fps)\n', ...
            videoFile, W, H, v.FrameRate);

end
