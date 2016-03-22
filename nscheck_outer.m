tic
%Parameters
vmax = 6;
p = 0.6;
%road_length = 70000;
num_samples = 1;%100;
%safe_cutoff = 60000;
dummy = false;

if (dummy)
    num_lanes = 5;
    avgpercar = 2.5; 
    params = [road_length vmax p simulation_steps safe_cutoff];
    populations = ceil([1000 3000 10000] / num_lanes / avgpercar);
    pop_sources = [0 1000 30000];
    starting_times = [38000 0 38000];
    density = 0;
else
    params = [road_length cells_per_second p simulation_steps safe_cutoff];
    num_lanes = 5;
    avgpercar = 2.5;
    newpop = populations;
    newpop = ceil(populations / num_lanes / avgpercar);
    density = 0.9 - 2*days_before;
end

road = zeros(1,road_length);       %Contains occupation state
velocities = zeros(1,road_length); %Contains velocity state

for g=1:num_samples    
    %Generate traffic
    road = zeros(1,road_length);       %Contains occupation state
    road_next = road;
    
    density = 0.3;%g/num_samples;
    %road(1) = 1;
    
    for i=1:road_length
        if rand < density 
            %road(i) = 1;
        end
    end
    
    A = nagelscheck(road, velocities, params, newpop, pop_sources, starting_times);    
end

toc