function d = probOfSurviving(windspeed, timestep)
    if (windspeed == 0 || timestep == 0)
        d = 1;
    else
        f = timestep / 15;
        % probability of dying in a 15 minute period
        prob_dying_15min = sigmoid((windspeed-120)/10)*0.2;
        d = (1-prob_dying_15min)^f;
    end
end

function y = sigmoid(x)
    y = 1./(1+exp(-x));
end