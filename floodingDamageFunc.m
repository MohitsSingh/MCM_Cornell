function d = floodingDamageFunc(hpos, r, sqpos, sqdim)
    sq = [sqpos; sqpos + sqdim*[1,0]; sqpos + sqdim*[0,1]; sqpos + sqdim*[1,1]];
    dist = sqrt(sum(((sq - repmat(hpos,4,1)).^2), 2));
    if min(dist) >= r
        d = 0;
    else
        d = 0.8*abs(r-mean(mean(dist)))/r;
    end
end