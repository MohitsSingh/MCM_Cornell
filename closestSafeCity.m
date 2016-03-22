goals = 1:length(citylocs); % nearest_safe_city
roadgraph2 = max(roadgraph,0);
roadgraph2 = [roadgraph2 zeros(size(roadgraph2,1),1)];
roadgraph2 = [roadgraph2; zeros(1,size(roadgraph2,2))];
for i=1:length(citylocs)
    if city_safe(i)
        roadgraph2(end,i) = 1;
        roadgraph2(i,end) = 1;
    end
end
graph = sparse(roadgraph2);
distances = 10000*ones(1,length(citylocs)+1);
previous = zeros(1,length(citylocs)+1);
unvisited = 1:(length(citylocs)+1);
visited = zeros(1,length(citylocs)+1);
distances(11) = 0;

while ~isempty(unvisited)
    distances2 = distances + 10000*visited;
    [a,i] = min(distances2);
    unvisited = unvisited(unvisited~=i);
    visited(i) = 1;
    for j=1:length(citylocs)
        if roadgraph2(i,j)
            x = a + roadgraph2(i,j);
            if x < distances(j)
                distances(j) = x;
                previous(j) = i;
            end
        end
    end
end

distances = distances(1:end-1) - 1;

goals = previous(1:end-1);

for i=1:length(goals)
    if goals(i) == 11
        goals(i) = i;
    end
end

previous_old = zeros(size(goals));
while previous_old ~= goals
    previous_old = goals;
    goals = goals(goals);
end

remaining = ones(1,length(goals));
paths = {};
count = 1;
for i=1:length(previous)-1
    if previous(i) == 11
        remaining(i) = -1;
    end
end
for i=1:length(previous)-1
    if remaining(i) == -1
        
    else
        j = i;
        accum = [];
        while j ~= 11 && remaining(j) > 0
            accum = [accum j];
            remaining(j) = -count;
            j = previous(j);
        end
        if remaining(j) == -1
            accum = [accum j];
        end
        if j == 11 || remaining(j) == -1
            paths{count} = accum;
            count = count + 1;
        else
            paths{-remaining(j)} = [accum paths{-remaining(j)}];
        end
    end
end