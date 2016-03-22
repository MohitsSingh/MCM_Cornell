function d = isPointInsidePoly(xs, ys, p)
    polygon = [xs,ys];
    n = size(polygon, 1);
    count = 0;
    for i = 1:n
        next = mod(i+1,n);
        if (next == 0)
            next = n;
        end
        if (intersect(p, polygon(i,:), polygon(next,:)))
            if (orientation(polygon(i,:), p, polygon(next,:)) == 0)
               d = onSegment(polygon(i,:), p, polygon(next,:));
               return
            end
            count = count + 1;
        end
    end
    d = mod(count,2);
end