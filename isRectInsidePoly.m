function d = isRectInsidePoly(xs, ys, s)
    a1 = isPointInsidePoly(xs, ys, s{1});
    a2 = isPointInsidePoly(xs, ys, s{2});
    a3 = isPointInsidePoly(xs, ys, s{3});
    a4 = isPointInsidePoly(xs, ys, s{4});
    a5 = isPointInsidePoly(xs, ys, s{5});
    d = a1 + a2 + a3 + a4 + a5;
end