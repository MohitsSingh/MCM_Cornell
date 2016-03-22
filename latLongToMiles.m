function d = latLongToMiles(lat1,lon1,lat2,lon2)
    % borrowed from andrew.hedges.name/experiments/haversine/
    R = 3961; % radius of the Earth
    dlon = lon2 - lon1;
    dlat = lat2 - lat1;
    a = (sin(deg2rad(dlat/2))).^2 + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * (sin(deg2rad(dlon/2))).^2;
    c = 2 * atan2(sqrt(a), sqrt(1-a));
    d = R * c;
end