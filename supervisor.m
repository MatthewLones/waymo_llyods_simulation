function supervisor()
%SUPERVISOR_ANIM  Lloyd iterations on (e.g.) Toronto graph, recorded offline.
%
% Uses plotter_anim to build frames, then optionally saves to MP4.

    % ---- Parameters -----------------------------------------------------
    n   = 4;      % number of agents
    Nx  = 20;     % passed through to setupLloyd if needed
    Ny  = 16;
    h   = 1.0;
    T   = 15;     % number of iterations

    videoFile  = 'llyod_sim.mp4';
    frameRate  = 2;    % playback fps

    % ---- Static setup (this is where you swap grid vs Toronto) ---------
    % For Toronto, have setupLloyd call buildTorontoGraph instead of buildGridGraph
    [G, XY, agentNode] = initMap(n, Nx, Ny, h);

    frames = {};   % cell array of frames

    % ---- Time loop ------------------------------------------------------
    for t = 0:T
        fprintf('Iteration %d / %d\n', t, T);
        iterTimer = tic;

        % 1) Current demand
        D = demandMap(XY, t);

        % 2) Lloyd "one-step" update
        owner        = voronoiRegions(G, agentNode, n);
        C            = centroidCalculator(owner, D, XY, n);
        agentNodeNew = moveAgents(C, XY, n);

        % 3) Draw into invisible figure and grab frame
        frames{end+1} = plotter(G, D, XY, agentNode, owner, C, ...
                                     agentNodeNew, t);

        % 4) Prepare next step
        agentNode = agentNodeNew;

        fprintf('  iteration time: %.2f s\n', toc(iterTimer));
    end

    % ---- Save the video ------------------------------------------
    v = VideoWriter(videoFile, 'MPEG-4');

    % 1 frame per second => each Lloyd iteration shows for ~1 s
    v.FrameRate = frameRate;

    open(v);

    % Use the first frame to define the canonical size
    [im0, ~] = frame2im(frames{1});
    [H, W, ~] = size(im0);

    for k = 1:numel(frames)
        [im, ~] = frame2im(frames{k});   % struct -> RGB image

        % If this frame's size is off by a pixel or two, fix it:
        if size(im,1) ~= H || size(im,2) ~= W
            im = imresize(im, [H, W]);    % pad/scale to match
        end

        writeVideo(v, im);
    end

    close(v);
    fprintf('Saved video to %s (size %d x %d, %.1f fps)\n', ...
            videoFile, W, H, v.FrameRate);

end
