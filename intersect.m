function d = intersect(p,a,b)
    p1 = p;
    q1 = p;
    q1(1) = 10000;
    p2 = a;
    q2 = b;
    o1 = orientation(p1, q1, p2);
    o2 = orientation(p1, q1, q2);
    o3 = orientation(p2, q2, p1);
    o4 = orientation(p2, q2, q1);
    if (o1 ~= o2 && o3 ~= o4)
        d = 1;
        return
    end
    if (  o1 == 0 && onSegment(p1, p2, q1) ...
       || o2 == 0 && onSegment(p1, q2, q1) ...
       || o3 == 0 && onSegment(p2, p1, q2) ...
       || o4 == 0 && onSegment(p2, q1, q2))
        d = 1;
        return
    end
    d = 0;
end