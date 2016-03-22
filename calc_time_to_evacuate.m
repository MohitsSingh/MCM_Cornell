mex nagelscheck.cpp;

max_speed_ms = 30;
simulation_steps = 172800;
cell_length = 5;
cells_per_second = max_speed_ms / cell_length;

for i=1:length(paths)
    vec = paths{i};
    lastrd = vec(:,end-1:end);
    a = lastrd(1);
    b = lastrd(2);
    lastdist = roadgraph(a, b);
    for k=0:d:lastdist
        curx = (citylocs(b,1)-citylocs(a,1))*k + citylocs(a,1);
        cury = (citylocs(b,2)-citylocs(a,2))*k + citylocs(a,2);
        sqx = floor(floor((curx-xmin)/d)*d)+1;
        sqy = floor(floor((cury-ymin)/d)*d)+1;
        if (sqx > 0 && sqy > 0 && sqx < size(Q,1) && sqy < size(Q,2) && block_safe(sqx, sqy))
            safe_cutoff = k*1608/cell_length;
        end
    end
    vec = vec(:,1:end-1);
    vecdistances = distances(vec);
    vecdistances = ceil(vecdistances*1608/cell_length);
    pop_sources = max(vecdistances)-vecdistances;
    road_length = max(vecdistances);
    populations = effective_evac_pops(vec);
    max_dist = 0;
    for j=2:length(vec)
        max_dist = max(max_dist, pop_sources(j) - pop_sources(j-1));
    end
    staggertime = max_dist / (max_speed_ms/1608);
    starting_times = (0:(length(vec)-1))*staggertime;
    nscheck_outer
    starting_times = zeros(size(vec));
    nscheck_outer
    starting_times = ((length(vec)-1):-1:0)*staggertime;
    nscheck_outer
end