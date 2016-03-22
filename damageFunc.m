function d = damageFunc(hpos, r, sqpos, sqdim)
    sq = [sqpos; sqpos + sqdim*[1,0]; sqpos + sqdim*[0,1]; sqpos + sqdim*[1,1]];
    dist = sqrt(sum(((sq - repmat(hpos,4,1)).^2), 2));
    if max(dist) <= r
        d = 1;
    elseif min(dist) >= r
        d = 0;
    else
        d = 0;
        for i=1:10
            for j=1:10
                sq = [sqpos + sqdim/10*[i-1,j-1]; sqpos + sqdim/10*[i,j-1]; sqpos + sqdim/10*[i-1,j]; sqpos + sqdim/10*[i,j]];
                ng = sqrt(sum(((sq - repmat(hpos,4,1)).^2), 2)) <= r;
                d = d + sum(ng)/4/100;
            end
        end
    end
end