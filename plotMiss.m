tic

animation = true;

close all;
B = csvread('CountyBoundaries.csv');
A = B(:,1);
B = B(:,2:end);
plotbound = false;
plotcities = true;
plotclosestcity = false;
plotdensityoverlay = true;
plotgrid = false;
miles = true;
plotriskoverlay = true;
redo_grid = false;

D = csvread('PopulationDistribution.csv');
densities = D(:,3);
densities_n = densities / max(densities);

citylocs = csvread('city_locations.csv',1,1);
cityfile = fopen('city_locations.csv');
citynames = textscan(cityfile,'%s %s %s','Delimiter',',');
citynames = citynames{1};
citynames = citynames(2:end);
fclose(cityfile);
roadgraph = csvread('roads.csv',1,1);

d = 0.1; % grid size

bounds = [-92 -88 30 35]; % min and max longitude and min and max latitude
if (miles)
    d = 7;
    bounds = [0 ceil(latLongToMiles(30,-92,30,-88)/d/2)*d*2 0 ceil(latLongToMiles(30,-92,35,-92)/d/2)*d*2];
    citylocs(:,1) = latLongToMiles(30, citylocs(:,1), 30, -92);
    citylocs(:,2) = latLongToMiles(citylocs(:,2), -92, 30, -92);
end
xmin = bounds(1);
xmax = bounds(2);
ymin = bounds(3);
ymax = bounds(4);

num_roads = 0;
roads_from = zeros(length(roadgraph),1);
%roads_to
road_startcities = zeros(1,length(roadgraph));
road_endcities = zeros(1,length(roadgraph));
road_xstarts = zeros(1,length(roadgraph));
road_ystarts = zeros(1,length(roadgraph));
road_xends = zeros(1,length(roadgraph));
road_yends = zeros(1,length(roadgraph));
road_lengths = zeros(1,length(roadgraph));
roads = zeros(num_roads, max(road_lengths));

for i=1:length(roadgraph)
    count = 1;
    for j=i+1:length(roadgraph)
        if (roadgraph(i,j) < 1)
            continue
        end
        num_roads = num_roads + 1;
        road_startcities(num_roads) = i;
        road_endcities(num_roads) = j;
        road_xstarts(num_roads) = citylocs(i,1);
        road_ystarts(num_roads) = citylocs(i,2);
        road_xends(num_roads) = citylocs(j,1);
        road_yends(num_roads) = citylocs(j,2);
        road_lengths(num_roads) = roadgraph(i, j)*350;
        roads_from(i,count) = num_roads;
        count = count + 1;
    end
end

boundaries = cell(2,size(B,1));
allboundaries = [];
for i=1:size(B,1)
    temp = B(i,:);
    boundaries{1,i} = temp(1:A(i))';
    boundaries{2,i} = temp((A(i)+1):(2*A(i)))';
    if (miles)
        boundaries{1,i} = latLongToMiles(30, boundaries{1,i}, 30, -92);
        boundaries{2,i} = latLongToMiles(boundaries{2,i}, -92, 30, -92);
    end
    allboundaries = [allboundaries; boundaries{1,i}, boundaries{2,i}];
end

lon = mean(allboundaries(:,1));
lat = mean(allboundaries(:,2));
xlen = latLongToMiles(lat,lon-0.5,lat,lon+0.5);
ylen = latLongToMiles(lat-0.5,lon,lat+0.5,lon);
xfrac = xlen/ylen;
if (miles)
    xfrac = bounds(2) / bounds(4);
end
fig = figure('units','inches','position',[8 10 8*xfrac 8]);
if (miles)
    axis equal
end
hold on
if (plotbound)
    for i=1:size(B,1)
        p = plot(boundaries{1,i},boundaries{2,i},'-.');
    end
end

if (plotcities)
    scatter(citylocs(:,1), citylocs(:,2), 'r', 'filled');
    citynames = cellstr(citynames);
    for i=1:length(roadgraph)
        for j=i+1:length(roadgraph)
            if (roadgraph(i,j) < 1)
                continue
            end
            plot([citylocs(i,1); citylocs(j,1)], [citylocs(i,2); citylocs(j,2)], 'b')
        end
    end
    dx = 0.1; dy = 0.1; % displacement so the text does not overlay the data points
    buffer = 0.5;
    if (miles)
        dx = 5;
        dy = 5;
        buffer = 25;
    end
    % citytext = text(citylocs(:,1)+dx, citylocs(:,2)-dy, citynames);
    % for i=1:length(citytext)
        % citytext(i).Color = 'red';
    % end
    xlim([min(citylocs(:,1))-buffer, max(citylocs(:,1))+buffer])
    ylim([min(citylocs(:,2))-buffer, max(citylocs(:,2))+buffer])
end

stateboundary = convhull(allboundaries(:,1), allboundaries(:,2));
statehull = {allboundaries(stateboundary,1),allboundaries(stateboundary,2)};

bsq = [xmin,ymin;xmin,ymin;xmin,ymin;xmin,ymin];

bound2{1}=boundaries{1,1};
bound2{2}=boundaries{2,1};

filename = 'miss_counties.csv';
if (miles)
    filename = 'miss_counties_miles.csv';
end
if (~exist(filename, 'file') || redo_grid)
    Q=gridify(boundaries, statehull, d, bounds, 0, true);
    csvwrite(filename, Q);
else
    Q=csvread(filename);
end

total_density = 0;
miss_pop = 3000000;
for i=1:size(Q,1)
    for j=1:size(Q,2)
        if (Q(i,j))
            total_density = total_density + densities_n(Q(i,j));
        end
    end
end
pop_factor = miss_pop / total_density;

home_cities = zeros(size(Q));
for i=1:size(Q,1)
    for j=1:size(Q,2)
        if (Q(i,j))
            sq = bsq + d*[i-1,j-1;i,j-1;i,j;i-1,j] + d/2;
            sq = mean(sq);
            mindist = 0;
            closest_city = 0;
            for k=1:length(citylocs)
                dist = sqrt(sum((citylocs(k,:) - sq).^2));
                if ~mindist || dist < mindist
                    mindist = dist;
                    closest_city = k;
                end
            end
            home_cities(i,j) = closest_city;
        end
    end
end

if (plotclosestcity)
    for i=1:size(Q,1)
        for j=1:size(Q,2)
            if (home_cities(i,j))
                sq = bsq + d*[i-1,j-1;i,j-1;i,j;i-1,j];
                fl = fill(sq(:,1),sq(:,2),[0,0,1]*home_cities(i,j)/10);%[Q(i,j)/82 1-Q(i,j)/82 Q(i,j)/82]);
                set(fl,'EdgeColor','None');
            end
        end
    end
end

if (plotdensityoverlay)
    for i=1:size(Q,1)
        for j=1:size(Q,2)
            if (Q(i,j))
                sq = bsq + d*[i-1,j-1;i,j-1;i,j;i-1,j];
                fl = fill(sq(:,1),sq(:,2),[0,0.5,0]*(1+densities_n(Q(i,j))));%[Q(i,j)/82 1-Q(i,j)/82 Q(i,j)/82]);
                set(fl,'EdgeColor','None');
            end
        end
    end
    if (~animation)
        map = zeros(51,3);
        for i=0:50
            map(i+1,1) = 0;
            map(i+1,2) = 0.5 + i*0.5/50;
            map(i+1,3) = 0;
        end
        caxis([0 max(densities)])
        colormap(fig, map);
        c = colorbar;
        ylabel(c, 'Population density per square mile')
    end
end

avg_num_cars = zeros(size(Q));

if (plotgrid)
    bsq2 = [xmin,ymin;xmin,ymin;xmin,ymin;xmin,ymin;xmin,ymin];
    for i=1:size(Q,1)
        for j=1:size(Q,2)
            sq = bsq2 + d*[i-1,j-1;i,j-1;i,j;i-1,j;i-1,j-1];
            plot(sq(:,1), sq(:,2), 'k-')
        end
    end
end

if (plotriskoverlay)
    num_trials = 2;
    hurricanePath
    %visits_n = sum(visits,3) / max(max(sum(visits,3)));
    visits_n = sum(sum(visits,4),3);
    visits_n2 = zeros(size(Q));
    prob_surviving = zeros(size(visits_n));
    prob_surviving2 = zeros(size(Q));
    for i=1:size(visits,1)
        for j=1:size(visits,2)
            for k=1:size(visits,4)
                p = 1;
                for l=1:size(visits,3)
                    p = p*probOfSurviving(visits(i,j,l,k), 15);
                end
                %p is probability of surviving in trial k
                prob_surviving(i,j) = prob_surviving(i,j) + p/num_trials;
            end
            prob_surviving(i,j) = prob_surviving(i,j) * probOfSurvivingFlood(floods(i,j,k));
        end
    end
    
    deadline = min(firstcontact, [], 3);
    
    prob_city_surviving = zeros(1,length(citylocs));
    for i=1:size(cityvisits,1)
        for k=1:size(cityvisits,3)
            p = 1;
            for l=1:size(cityvisits,2)
                p = p*probOfSurviving(cityvisits(i,l,k), 15);
            end
            %p is probability of surviving in trial k
            prob_city_surviving(i) = prob_city_surviving(i) + p/num_trials;
        end
    end
    
    city_safe = prob_city_surviving > 0.99;
    goals = 1:length(citylocs); % nearest_safe_city
    for i=1:length(goals)
        if ~city_safe(i)
            mindist = 0;
            closestcity = i;
            for j=1:length(citylocs)
                if city_safe(j)
                    dist = sqrt(sum((citylocs(j,:)-citylocs(i,:)).^2));
                    if ~mindist || dist < mindist
                        mindist = dist;
                        closestcity = j;
                    end
                end
            end
            goals(i) = closestcity; % TEMP... CHANGE!!!
        end
    end
    
    for i=1:size(visits_n2,1)
        for j=1:size(visits_n2,2)
            visits_n2(i,j) = visits_n(floor((i-1)*d/d2)+1,floor((j-1)*d/d2)+1);
            if ~Q(i,j)
                visits_n2(i,j) = 0;
            end
        end
    end
    
    for i=1:size(prob_surviving2,1)
        for j=1:size(prob_surviving2,2)
            prob_surviving2(i,j) = prob_surviving(floor((i-1)*d/d2)+1,floor((j-1)*d/d2)+1);
            if ~Q(i,j)
                prob_surviving2(i,j) = 0;
            end
        end
    end
    
    block_safe = prob_surviving2 > 0.99;
    effective_evac_pops = zeros(1,length(citylocs));
    for i=1:size(Q,1)
        for j=1:size(Q,2)
            if (Q(i,j) && ~block_safe(i,j))
                effective_evac_pops(home_cities(i,j)) = effective_evac_pops(home_cities(i,j)) + pop_factor*densities_n(Q(i,j));
            end
        end
    end
    
    if (max(max(visits_n2)) ~= 0)
        visits_n2 = visits_n2 / max(max(visits_n2));
    end
    
    for i=1:size(visits_n2,1)
        for j=1:size(visits_n2,2)
            if (Q(i, j))
                sq = bsq + d*[i-1,j-1;i,j-1;i,j;i-1,j];
                %fl = fill(sq(:,1),sq(:,2),[1,0,0]*(1 - visits_n2(i, j)));
                fl = fill(sq(:,1),sq(:,2),[1,0,0]*prob_surviving2(i, j));
                set(fl,'EdgeColor','None');
            end
        end
    end
    
    map = zeros(51,3);
    for i=0:50
        map(i+1,1) = 1 - i/50;
        map(i+1,2) = 0;
        map(i+1,3) = 0;
    end
    caxis([0 max(max(visits_n2))])
    colormap(fig, map);
    c = colorbar;
    %ylabel(c, 'Severity of hurricane damage')
    ylabel(c, 'Probability of death per day for people remaining in affected areas')
    closestSafeCity
    %calc_time_to_evacuate
end

if (plotcities)
    scatter(citylocs(:,1), citylocs(:,2), 'r', 'filled');
    citynames = cellstr(citynames);
    for i=1:length(roadgraph)
        for j=i+1:length(roadgraph)
            if (roadgraph(i,j) < 1)
                continue
            end
            plot([citylocs(i,1); citylocs(j,1)], [citylocs(i,2); citylocs(j,2)], 'b')
        end
    end
    dx = 0.1; dy = 0.1; % displacement so the text does not overlay the data points
    buffer = 0.5;
    if (miles)
        dx = 5;
        dy = 5;
        buffer = 25;
    end
%     citytext = text(citylocs(:,1)+dx, citylocs(:,2)-dy, citynames);
%     for i=1:length(citytext)
%         if (plotriskoverlay)
%             citytext(i).Color = 'green';
%         else
%             citytext(i).Color = 'red';
%         end
%     end
    xlim([min(citylocs(:,1))-buffer, max(citylocs(:,1))+buffer])
    ylim([min(citylocs(:,2))-buffer, max(citylocs(:,2))+buffer])
end
   
if (miles)
    xlabel('Miles - X')
    ylabel('Miles - Y')
else
    xlabel('Longitude')
    ylabel('Latitude')
end



toc