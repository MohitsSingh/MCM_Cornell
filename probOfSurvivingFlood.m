function d = probOfSurvivingFlood(floodIntensity)
    if (floodIntensity == 0)
        d = 1;
    else
        d = 1./(sqrt(floodIntensity)+1);
    end
end