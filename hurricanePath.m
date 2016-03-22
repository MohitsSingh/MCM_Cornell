plot_path = false;

if (animation)
    num_trials = 1;
end

days_before = 4;
landfall = [(xmin+xmax)/2 ymin];
landfall = [xmin+(xmax-xmin)*4/4 (ymin+ymax)/2];
%landfall = [xmin + rand()*(xmax-xmin) ymin];

p_east = 1/3;
p_straight = 1/3;
p_west = 1/3;

factor = 2.5;

radius_maxwind = 0.5;
outer_radius = 4;
avg_speed = 0.02 * factor; % travel speed
speed_stdev = 0.005 * factor;

if (miles)
    radius_maxwind = 29; % 10
    rmaxstdev = radius_maxwind/(16/days_before); % 1/16 for a day before, 1/8 for 2 days before, 1/4 for 4 days
    %radius_maxwind = radius_maxwind + rmaxstdev*randn;
    outer_radius = 200;
    routerstdev = outer_radius/(16/days_before);
    outer_radius = outer_radius + routerstdev*randn;
    avg_speed = 1 * factor;
    speed_stdev = 0.5 * factor;
end
radius = radius_maxwind;
tfinal = 250 / factor;
initwindspeed = 170; % initial speed in mph
initwindspeed_stdev = (10/days_before);
initwindspeed = initwindspeed + initwindspeed_stdev*randn;
initial_theta = 0; % angle with the vertical axis
theta_var = 7/360*2*pi;
initial_theta = initial_theta + theta_var*randn;
initmomentum = [1,1];
initmomentum = [1-rand()*2 1];
%flooding_radius = 50;
%curpos = repmat(landfall, num_trials, 1);
%momentum = zeros(num_trials, 2);

if (animation)
    initmomentum
    landfall
end

d2 = d*2;
xsize = (xmax-xmin)/d2;
ysize = (ymax-ymin)/d2;
visits = zeros(xsize, ysize, tfinal+1, num_trials);
firstcontact = zeros(xsize,ysize,num_trials);
cityvisits = zeros(length(citylocs), tfinal+1, num_trials);
floods = zeros(xsize, ysize, num_trials);

for trial=1:num_trials
    trial
    curpos = landfall;
    lastpos = curpos;
    momentum = initmomentum;
    intensity = 1;
    windspeed = intensity*initwindspeed;
    outerwindspeed = 0.1*intensity*initwindspeed;
    flooding_radius = 5;
    for i=0:tfinal
        if windspeed < 20
            if (animation)% && i ~= tfinal)
                delete(circle_fig);
                drawnow
            end
            break
        end
        %[trial,i]
        circ = [sin(0:0.1:2*pi)', cos(0:0.1:2*pi)'] * radius;
        circ = circ + repmat(curpos, size(circ,1), 1);
        if (animation)
            circle_fig = fill(circ(:,1),circ(:,2),'b');
            set(circle_fig,'facealpha',intensity)
            set(circle_fig,'EdgeColor','None')
            if (plot_path)
                plot([lastpos(1); curpos(1)], [lastpos(2); curpos(2)], 'r-')
            end
            xlim([xmin xmax])
            ylim([ymin ymax])
            pause(0.01);
        end

        hleft = curpos(1) - radius;
        hright = curpos(1) + radius;
        hbot = curpos(2) - radius;
        htop = curpos(2) + radius;

        xstart = max(floor((hleft - xmin)/d2), 1);
        xstop = min(ceil((hright - xmin)/d2) + 1, xsize);
        ystart = max(floor((hbot - ymin)/d2), 1);
        ystop = min(ceil((htop - ymin)/d2) + 1, ysize);
        
        for i1=xstart:xstop
            for i2=ystart:ystop
                sq = [xmin,ymin] + d2*[i1-1,i2-1];
                visits(i1,i2,i+1,trial) = windspeed*damageFunc(curpos, radius, sq, d2);
                if ~firstcontact(i1,i2,trial)
                    firstcontact(i1,i2,trial) = i+1;
                end
            end
        end
        
        for i1=1:length(citylocs)
            if sqrt((curpos(1) - citylocs(i1,1)).^2 + (curpos(2) - citylocs(i1,2)).^2) < radius
                cityvisits(i1,i+1,trial) = windspeed*1; % func of distance
            end
        end

        speed = speed_stdev*randn() + avg_speed;
        x = rand();
        if (x < 1/5)
            dir = [-1,0];
        elseif (x < 2/5)
            dir = [-1,1];
        elseif (x < 3/5)
            dir = [0,1];
        elseif (x < 4/5)
            dir = [1,1];
        else
            dir = [1,0];
        end
        dir = dir/norm(dir);
        lastpos = curpos;
        momentum = momentum + dir;
        if (momentum == 0)
            momentum = [1, 0];
        end
        curpos = curpos + momentum/norm(momentum)*speed;
        intensity = intensity * (0.95 + rand()*0.05);
        windspeed = intensity*initwindspeed;
        
        if (animation)
            delete(circle_fig);
        end
    end
    if (landfall(2) < 30.5 || miles && landfall(2) < 50) % coastal regions
        fleft = curpos(1) - flooding_radius;
        fright = curpos(1) + flooding_radius;
        fbot = curpos(2) - flooding_radius;
        ftop = curpos(2) + flooding_radius;

        xstart = max(floor((fleft - xmin)/d2), 1);
        xstop = min(ceil((fright - xmin)/d2) + 1, xsize);
        ystart = max(floor((fbot - ymin)/d2), 1);
        ystop = min(ceil((ftop - ymin)/d2) + 1, ysize);

        for i1=1:xstart
            for i2=1:ysize
                sq = [xmin,ymin] + d2*[i1-1,i2-1];
                flood = floodingDamageFunc(landfall, radius, sq, d2);
                floods(i1,i2,trial) = flood;
            end
        end
    end
end